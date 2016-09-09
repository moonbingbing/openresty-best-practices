# KeepAlive

在OpenResty中，连接池在使用上如果不加以注意，容易产生数据写错地方，或者得到的应答数据异常以及类似的问题，当然使用短连接可以规避这样的问题，但是在一些企业用户环境下，短连接+高并发对企业内部的防火墙是一个巨大的考验，因此，长连接自有其用武之地，使用它的时候要记住，长连接一定要保持其连接池中所有连接的正确性。

```lua
-- 错误的代码
local function send()
	for i = 1, count do
		local ssdb_db, err = ssdb:new()
		local ok, err = ssdb_db:connect(SSDB_HOST, SSDB_PORT)
		if not ok then
    		ngx.log(ngx.ERR, "create new ssdb failed!")
		else
   			local key,err = ssdb_db:qpop(something)
 			if not key then
   				ngx.log(ngx.ERR, "ssdb qpop err:", err)
   			else
   				local data, err = ssdb_db:get(key[1])
   				-- other operations
   			end
		end 
	end
	ssdb_db:set_keepalive(SSDB_KEEP_TIMEOUT, SSDB_KEEP_COUNT)
end  
-- 调用
while true do
    local ths = {}
    for i=1,THREADS do
        ths[i] = ngx.thread.spawn(send)       ----创建线程
    end 
    for i = 1, #ths do 
        ngx.thread.wait(ths[i])               ----等待线程执行
    end  
    ngx.sleep(0.020)
end
```
以上代码在测试中发现，应该得到get(key)的返回值有一定几率为key。

原因即是在ssdb创建连接时可能会失败，但是当得到失败的结果后依然调用ssdb_db：set_keepalive将此连接并入连接池中。


正确地做法是如果连接池出现错误，则不要将该连接加入连接池。

```lua
local function send()
	for i = 1, count do
		local ssdb_db, err = ssdb:new()
		local ok, err = ssdb_db:connect(SSDB_HOST, SSDB_PORT)
		if not ok then
    		ngx.log(ngx.ERR, "create new ssdb failed!")
    		return
		else
   			local key,err = ssdb_db:qpop(something)
 			if not key then
   				ngx.log(ngx.ERR, "ssdb qpop err:", err)
   			else
   				local data, err = ssdb_db:get(key[1])
   				-- other operations
   			end
   			ssdb_db:set_keepalive(SSDB_KEEP_TIMEOUT, SSDB_KEEP_COUNT)
		end 
	end
end
```
所以，当你使用长连接操作db出现结果错乱现象时，首先应该检查下是否存在长连接使用不当的情况。

