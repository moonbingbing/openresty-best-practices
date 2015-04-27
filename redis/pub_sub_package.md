# redis接口的二次封装（发布订阅）

其实这一小节完全可以放到上一个小结，只是这里用了完全不同的玩法，所以我还是决定单拿出来分享一下这个小细节。

上一小结有关订阅部分的代码，请看：
```
function _M.subscribe( self, channel )
    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end

    local ok, err = self:connect_mod(redis)
    if not ok or err then
        return nil, err
    end

    local res, err = redis:subscribe(channel)
    if not res then
        return nil, err
    end

    res, err = redis:read_reply()
    if not res then
        return nil, err
    end

    redis:unsubscribe(channel)
    self.set_keepalive_mod(redis)

    return res, err
end
```

其实这里是不