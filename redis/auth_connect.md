# 访问有授权验证的 Redis

对于有授权验证的 redis ，正确的认证方法，请参考下面例子：

```nginx
server {
    location /test {
        content_by_lua_block {
            local redis = require "resty.redis"
            local red = redis:new()

            red:set_timeout(1000) -- 1 sec

            local ok, err = red:connect("127.0.0.1", 6379)
            if not ok then
                ngx.say("failed to connect: ", err)
                return
            end

            -- 请注意这里 auth 的调用过程
            local count
            count, err = red:get_reused_times()
            if 0 == count then
                ok, err = red:auth("password")
                if not ok then
                    ngx.say("failed to auth: ", err)
                    return
                end
            elseif err then
                ngx.say("failed to get reused times: ", err)
                return 
            end

            ok, err = red:set("dog", "an animal")
            if not ok then
                ngx.say("failed to set dog: ", err)
                return
            end

            ngx.say("set result: ", ok)

            -- 连接池大小是100个，并且设置最大的空闲时间是 10 秒
            local ok, err = red:set_keepalive(10000, 100)
            if not ok then
                ngx.say("failed to set keepalive: ", err)
                return
            end
        }
    }
}
```

这里我们需要解释一下 `tcpsock:getreusedtimes()` 方法，如果当前连接不是从内建连接池中获取的，该方法总是返回 0 ，也就是说，该连接还没有被使用过。如果连接来自连接池，那么返回值永远都是非零。所以这个方法可以用来确认当前连接是否来自池子。

对于 Redis 授权，实际上我们只需要建立连接后，首次认证一下，后面只需直接使用即可。换句话说，从连接池中获取的连接都是经过授权认证的，只有新创建的连接才需要进行授权认证。所以大家就看到了 `count, err = red:get_reused_times()` 这段代码，并有了下面 `if 0 == count then` 的判断逻辑。

