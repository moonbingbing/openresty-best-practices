#ngx.shared.DICT

ngx.shared.DICT是基于黑红树结构和LRU算法的kv存储，不支持数据持久化，提供有限的数据类型的支持。

适用范围：cache，会话间同步数据；  
不适用：数据持久化，日志记录，大容量数据，队列性质的暂存；

OpenResty中[lua-resty-lock](https://github.com/openresty/lua-resty-lock)组件也是基于shared.DICT实现的

*如果你使用的是由奇虎公司提供的windows平台下的[mul-worker](https://github.com/LomoX-Offical/nginx-openresty-windows)版本，那么在使用ngx.shared.DICT的时候需要注意的是每一个Key占用的最小内存是4K，即是1M内存只能存储256个key-value对*。

主要函数和执行阶段请参考维基百科[HttpLuaModule#ngx.shared.DICT](http://wiki.nginx.org/HttpLuaModule#ngx.shared.DICT)
