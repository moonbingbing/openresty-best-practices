# ngx.shared.DICT

ngx.shared.DICT 是基于红黑树结构和 LRU 算法的 KV 存储，不支持数据持久化，提供有限的数据类型的支持。

适用范围：内存 cache，不同 worker 之间同步数据；  
不适用：数据持久化，日志记录，大容量数据，队列性质的暂存；

OpenResty 中 [lua-resty-lock](https://github.com/openresty/lua-resty-lock) 组件也是基于 shared.DICT 实现的。

主要函数和执行阶段请参考文档 [HttpLuaModule#ngx.shared.DICT](https://github.com/openresty/lua-nginx-module#ngxshareddict) 。
