# `ngx.shared.DICT` 非队列性质

执行阶段和主要函数请参考 [`HttpLuaModule#ngx.shared.DICT`](https://github.com/openresty/lua-nginx-module#ngxshareddict)

### 非队列性质
`ngx.shared.DICT` 是采用 **红黑树** 实现的，当申请的缓存空间被用完后，如果又有新数据需要存储，则采用 LRU 算法淘汰掉“多余”数据。

这样的数据结构在带有队列性质的业务逻辑下会出现的一些问题：

我们用 shared 作为缓存，接纳终端输入并存储，然后在另外一个线程中按照固定的速度去处理这些输入，代码如下:

```lua
-- [ngx.thread.spawn](https://github.com/openresty/lua-nginx-module#ngxthreadspawn) #1 存储线程，理解为生产者

    ....
    local cache_str = string.format([[%s&%s&%s&%s&%s&%s&%s]], net, name, ip,
                    mac, ngx.var.remote_addr, method, md5)
    local ok, err = ngx_nf_data:safe_set(mac, cache_str, 60*60)  --这些是缓存数据
    if not ok then
        ngx.log(ngx.ERR, "stored nf report data error: "..err)
    end
    ....

-- [ngx.thread.spawn](https://github.com/openresty/lua-nginx-module#ngxthreadspawn) #2 读取线程，理解为消费者

    while not ngx.worker.exiting() do
        local keys = ngx_share:get_keys(50)  -- 一秒处理50个数据

        for index, key in pairs(keys) do
            str = ((nil ~= str) and str..[[#]]..ngx_share:get(key)) or ngx_share:get(key)
            ngx_share:delete(key)  --干掉这个key
        end
        .... --一些消费过程，看官不要在意
        ngx.sleep(1)
    end
```

在上述业务逻辑下会出现由生产者生产的某些 **“key-val”** 对，永远不会被消费者取出并消费。

原因就是 `shared.DICT` **不是队列**，`ngx_shared:get_keys(n)` 函数不能保证返回的 n 个键值对是满足 FIFO 规则的，从而导致问题发生。

### 问题解决
问题的原因已经找到，解决方案有如下几种：
- 1、修改暂存机制，采用 Redis 的队列来做暂存；
- 2、调整消费者的消费速度，使其远远大于生产者的速度；
- 3、修改 `ngx_shared:get_keys()` 的使用方法，即不带参数；

方法 2 和 3 本质上都是一样的，由于业务已经上线，方法 1 周期太长，于是采用方法 2 解决，在后续的业务中不再使用 `shared.DICT` 来暂存队列性质的数据。
