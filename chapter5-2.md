# redis接口的二次封装
先看一下官方的调用示例代码：
'''
  local redis = require "resty.redis"

    redis.add_commands("foo", "bar")

    local red = redis:new()

    red:set_timeout(1000) -- 1 sec

    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end

    local res, err = red:foo("a")
    if not res then
        ngx.say("failed to foo: ", err)
    end

    res, err = red:bar()
    if not res then
        ngx.say("failed to bar: ", err)
    end
'''

