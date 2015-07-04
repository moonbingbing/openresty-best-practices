# 缓存
###缓存的原则
缓存是一个大型系统中非常重要的一个组成部分。在硬件层面，大部分的计算机硬件都会用缓存来提高速度，比如CPU会有多级缓存、RAID卡也有读写缓存。在软件层面，我们用的数据库就是一个缓存设计非常好的例子，在SQL语句的优化、索引设计、磁盘读写的各个地方，都有缓存，建议大家在设计自己的缓存之前，先去了解下MySQL里面的各种缓存机制，感兴趣的可以去看下[High Permance MySQL](http://www.highperfmysql.com/)这本非常有价值的书。

一个生产环境的缓存系统，需要根据自己的业务场景和系统瓶颈，来找出最好的方案，这是一门平衡的艺术。

一般来说，缓存有两个原则。**一是越靠近用户的请求越好**，比如能用用户本地缓存的就不要发送HTTP请求，能用CDN缓存的就不要打到web服务器，能用nginx缓存的就不要用数据库的缓存；**二是尽量本进程和本机的缓存解决**，因为跨了进程和机器甚至机房，缓存的网络开销就会非常大，在高并发的时候会非常明显。

###OPenResty的缓存
我们介绍下在OpenResty里面，有哪些缓存的方法。

* 使用[lua shared dict](http://wiki.nginx.org/HttpLuaModule#lua_shared_dict)

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
```lua
lua_shared_dict my_cache 128m;
```
