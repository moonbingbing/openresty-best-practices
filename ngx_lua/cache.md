# 缓存

### 缓存的原则

缓存是一个大型系统中非常重要的一个组成部分。在硬件层面，大部分的计算机硬件都会用缓存来提高速度，比如 CPU 会有多级缓存、RAID 卡也有读写缓存。在软件层面，我们用的数据库就是一个缓存设计非常好的例子，在 SQL 语句的优化、索引设计、磁盘读写的各个地方，都有缓存，建议大家在设计自己的缓存之前，先去了解下 MySQL 里面的各种缓存机制，感兴趣的可以去看下[High Performance MySQL](http://www.highperfmysql.com/)这本非常有价值的书。

一个生产环境的缓存系统，需要根据自己的业务场景和系统瓶颈，来找出最好的方案，这是一门平衡的艺术。

一般来说，缓存有两个原则。
- **一是越靠近用户的请求越好**，比如能用本地缓存的就不要发送 HTTP 请求，能用 CDN 缓存的就不要打到 Web 服务器，能用 Nginx 缓存的就不要用数据库的缓存；
- **二是尽量使用本进程和本机的缓存解决**，因为跨了进程和机器甚至机房，缓存的网络开销就会非常大，在高并发的时候会非常明显。

### OpenResty 的缓存

我们介绍下在 OpenResty 里面，有哪些缓存的方法。

#### 使用 [Lua shared dict](https://github.com/openresty/lua-nginx-module#ngxshareddict)

我们看下面这段代码：

```lua
function get_from_cache(key)
    local cache_ngx = ngx.shared.my_cache
    local value     = cache_ngx:get(key)
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

这里面用的就是 ngx shared dict cache。你可能会奇怪，`ngx.shared.my_cache` 是从哪里冒出来的？没错，少贴了 nginx.conf 里面的修改：

```
lua_shared_dict my_cache 128m;
```


如同它的名字一样，这个 cache 是 Nginx 所有 worker 之间共享的，内部使用的 LRU 算法（最近最少使用）来判断缓存是否在内存占满时被清除。

#### 使用 [Lua LRU cache](https://github.com/openresty/lua-resty-lrucache)

直接复制下春哥的示例代码：

```lua
local _M = {}

-- alternatively: local lrucache = require "resty.lrucache.pureffi"
local lrucache = require "resty.lrucache"

-- we need to initialize the cache on the Lua module level so that
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

可以看出来，这个 cache 是 worker 级别的，不会在 Nginx wokers 之间共享。并且，它是预先分配好 key 的数量，而 shared dict 需要自己用 key 和 value 的大小和数量，来估算需要把内存设置为多少。

#### 如何选择？

`shared.dict` 使用的是共享内存，每次操作都是全局锁，如果高并发环境，不同 worker 之间容易引起竞争。所以单个 `shared.dict` 的体积不能过大。
`lrucache` 是 worker 内使用的，由于 Nginx 是单进程方式存在，所以永远不会触发锁，效率上有优势，并且没有 `shared.dict` 的体积限制，内存上也更弹性，但不同 worker 之间数据不同享，同一缓存数据可能被冗余存储。

你需要考虑的是以下两点：
- 一个是 Lua LRU cache 提供的 API 比较少，现在只有 `get`、`set` 和 `delete`，而 ngx shared dict 还可以 `add`、`replace`、`incr`、`get_stale`（在 key 过期时也可以返回之前的值）、`get_keys`（获取所有 key，虽然不推荐，但说不定你的业务需要呢）；
- 第二个是内存的占用，由于 ngx shared dict 是 workers 之间共享的，所以在多 worker 的情况下，内存占用比较少。
