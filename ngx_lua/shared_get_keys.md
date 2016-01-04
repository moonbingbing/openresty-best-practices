# ngx.shared.DICT 非队列性质
===========

执行阶段和主要函数请参考[维基百科 HttpLuaModule#ngx.shared.DICT](http://wiki.nginx.org/HttpLuaModule#ngx.shared.DICT)

非队列性质
------------
ngx.shared.DICT的实现是采用红黑树实现，当申请的缓存被占用完后如果有新数据需要存储则采用LRU算法淘汰掉“多余”数据。


这样数据结构的在带有队列性质的业务逻辑下会出现的一些问题：

我们用shared作为缓存，接纳终端输入并存储，然后在另外一个线程中按照固定的速度去处理这些输入，代码如下:

```

-- [ngx.thread.spawn](http://wiki.nginx.org/HttpLuaModule#ngx.thread.spawn) #1 存储线程 理解为生产者

	....
	local cache_str = string.format([[%s&%s&%s&%s&%s&%s&%s]], net, name, ip,
                    mac, ngx.var.remote_addr, method, md5)
	local ok, err = ngx_nf_data:safe_set(mac, cache_str, 60*60)  --这些是缓存数据
	if not ok then
		ngx.log(ngx.ERR, "stored nf report data error: "..err)
	end
	....


-- [ngx.thread.spawn](http://wiki.nginx.org/HttpLuaModule#ngx.thread.spawn) #2 取线程 理解为消费者

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

在上述业务逻辑下会出现由生产者生产的某些key-val对永远不会被消费者取出并消费，原因就是shared.DICT不是队列，ngx_shared:get_keys(n)函数不能保证返回的n个键值对是满足FIFO规则的，从而导致问题发生。

问题解决
------------
问题的原因已经找到，解决方案有如下几种：
1.修改暂存机制，采用redis的队列来做暂存；
2.调整消费者的消费速度，使其远远大于生产者的速度；
3.修改ngx_shared:get_keys()的使用方法，即是不带参数；

方法3和2本质上都是一样的，由于业务已经上线，方法1周期太长，于是采用方法2解决，在后续的业务中不再使用shared.DICT来暂存队列性质的数据
