# select+set_keepalive组合操作引起的数据读写错误

在高并发编程中，我们必须要使用连接池技术，通过减少建连、拆连次数来提高通讯速度。

错误示例代码：

```
local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

ok, err = red:select(1)
if not ok then
    ngx.say("failed to select db: ", err)
    return
end

ngx.say("select result: ", ok)

ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

-- put it into the connection pool of size 100,
-- with 10 seconds max idle time
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
```


如果单独执行这个用例，没有任何问题，用例是成功的。但是这段“没问题”的代码，却导致了诡异的现象。

我们的大部分redis请求的代码应该是类似这样的：

```
local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

ok, err = red:set("cat", "an animal too")
if not ok then
    ngx.say("failed to set cat: ", err)
    return
end

ngx.say("set result: ", ok)

-- put it into the connection pool of size 100,
-- with 10 seconds max idle time
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
```
这时候第二个示例代码在生产运行中，会出现cat偶会被写入到数据库1上，且几率大约1%左右。出错的原因在于错误示例代码使用了select(1)操作，并且使用了长连接，那么她就会潜伏在连接池中。当下一个请求刚好从连接池中把他选出来，又没有重置select(0)操作，那么后面所有的数据操作就都会默认触发在数据库1上了。怎么解决，不用我说了吧？

#set_keepalive位置使用不当事例
```
--为了方便使用redis我们构建了一个函数用于返回redis连接
function get_redis_handle()
    local redis_handle = m_redis:new()
    if redis_handle == nil then
        ngx.log(ngx.ERR, "init redis server failed")
        return nil
    end

    redis_handle:set_timeout(30000)

    local ok,err = redis_handle:connect(host,port)
    if not ok then
        ngx.log(ngx.ERR, "connect redis server failed")
        return nil
    end

    redis_handle:set_keepalive(30000, 100)  --错误使用，此处使用set_keepalive导致redis提前退出，应该屏蔽
 
    return redis_handle
end

--使用上面我们构建的redis连接函数
local redis_handle = get_redis_handle()
if redis_handle == nil then
    ngx.say(m_cjson.encode(response))
    ngx.exit(200)
end

redis_handle:set('test', 'test')

redis_handle:set_keepalive(30000, 100)  --正确使用

ngx.say('ok')
ngx.exit(200)
```
