# 缓存

###缓存的原则

缓存是一个大型系统中非常重要的一个组成部分。在硬件层面，大部分的计算机硬件都会用缓存来提高速度，比如CPU会有多级缓存、RAID卡也有读写缓存。在软件层面，我们用的数据库就是一个缓存设计非常好的例子，在SQL语句的优化、索引设计、磁盘读写的各个地方，都有缓存，建议大家在设计自己的缓存之前，先去了解下MySQL里面的各种缓存机制，感兴趣的可以去看下[High Permance MySQL](http://www.highperfmysql.com/)这本非常有价值的书。

一个生产环境的缓存系统，需要根据自己的业务场景和系统瓶颈，来找出最好的方案，这是一门平衡的艺术。

一般来说，缓存有两个原则。**一是越靠近用户的请求越好**，比如能用本地缓存的就不要发送HTTP请求，能用CDN缓存的就不要打到web服务器，能用nginx缓存的就不要用数据库的缓存；**二是尽量使用本进程和本机的缓存解决**，因为跨了进程和机器甚至机房，缓存的网络开销就会非常大，在高并发的时候会非常明显。

###OPenResty的缓存

我们介绍下在OpenResty里面，有哪些缓存的方法。

####使用[lua shared dict](http://wiki.nginx.org/HttpLuaModule#ngx.shared.DICT)

我们看下面这段代码：

```lua
function get_from_cache(key)
    local cache_ngx = ngx.shared.my_cache
    local value = cache_ngx:get(key)
    return value
end

function set_to_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end

    local cache_ngx = ngx.shared.my_cache
    local succ, err, forcible = cache_ngx:set(key, value, exptime)
    return succ
end
```

这里面用的就是ngx shared dict cache。你可能会奇怪，ngx.shared.my_cache是从哪里冒出来的？没错，少贴了nginx.conf里面的修改：

```
lua_shared_dict my_cache 128m;
```


如同它的名字一样，这个cache是nginx所有worker之间共享的，内部使用的LRU算法（最近经常使用）来判断缓存是否在内存占满时被清除。

####使用[lua LRU cache](https://github.com/openresty/lua-resty-lrucache)

直接复制下春哥的示例代码：

```lua
local _M = {}

-- alternatively: local lrucache = require "resty.lrucache.pureffi"
local lrucache = require "resty.lrucache"

-- we need to initialize the cache on the lua module level so that
-- it can be shared by all the requests served by each nginx worker process:
local c = lrucache.new(200)  -- allow up to 200 items in the cache
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

function _M.go()
    c:set("dog", 32)
    c:set("cat", 56)
    ngx.say("dog: ", c:get("dog"))
    ngx.say("cat: ", c:get("cat"))

    c:set("dog", { age = 10 }, 0.1)  -- expire in 0.1 sec
    c:delete("dog")
end

return _M
```

可以看出来，这个cache是worker级别的，不会在nginx wokers之间共享。并且，它是预先分配好key的数量，而shared dcit需要自己用key和value的大小和数量，来估算需要把内存设置为多少。

####如何选择？

shared.dict 使用的是共享内存，每次操作都是全局锁，如果高并发环境，不同worker之间容易引起竞争。所以单个shared.dict的体积不能过大。lrucache是worker内使用的，由于nginx是单进程方式存在，所以永远不会触发锁，效率上有优势，并且没有shared.dict的体积限制，内存上也更弹性，但不同worker之间数据不同享，同一缓存数据可能被冗余存储。

你需要考虑的，一个是lua lru cache提供的API比较少，现在只有get、set和delete，而ngx shared dict还可以add、replace、incr、get_stale（在key过期时也可以返回之前的值）、get_keys（获取所有key，虽然不推荐，但说不定你的业务需要呢）；第二个是内存的占用，由于ngx shared dict是workers之间共享的，所以在多worker的情况下，内存占用比较少。
