# Redis 接口的二次封装（发布订阅）

其实这一小节完全可以放到上一个小节，只是这里用了完全不同的玩法，所以我还是决定单拿出来分享一下这方面的小细节。

上一小节有关订阅部分的代码，请看：

```lua
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

其实这里的实现是有问题的，各位看官，你能发现这段代码的问题么？给个提示，在高并发订阅场景下，极有可能存在漏掉部分订阅信息。原因在于每次订阅到内容后，都会把 Redis 对象进行释放，处理完订阅信息后再次去连接 Redis，在这个时间差里面，很可能有消息已经漏掉了。

通过下面的代码可以解决这个问题：

```lua
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

    local function do_read_func ( do_read )
        if do_read == nil or do_read == true then
            res, err = redis:read_reply()
            if not res then
                return nil, err
            end
            return res
        end

        redis:unsubscribe(channel)
        self.set_keepalive_mod(redis)
        return
    end

    return do_read_func
end
```

调用示例代码：

```lua
local red = redis:new({timeout=1000})
local func = red:subscribe( "channel" )
if not func then
  return nil
end

while true do
    local res, err = func()
    if err then
        func(false)
    end
    ... ...
end

return cbfunc
```

另一个潜在的问题是，调用了 `unsubscribe` 之后，Redis 对象里面有可能还遗留没被读取的数据。在这种情况下，无法直接通过 `set_keepalive_mod` 复用连接。什么时候会发生这样的情况呢？

当 Redis 对象处于 subscribe 状态时，Redis 会给它推送订阅的消息，然后我们通过 `read_reply` 把消息读出来。调用 `unsubscribe` 的时候，只是退订了对应的频道，并不会把当前接收到的数据清空。如果要想复用该连接，我们就需要保证清空当前读取到的数据，保证它是干净的。就像这样：

```lua
local res, err = red:unsubscribe("ch")
if not res then
    ngx.log(ngx.ERR, err)
    return
else
    -- redis 推送的消息格式，可能是
    -- {"message", ...} 或
    -- {"unsubscribe", $channel_name, $remain_channel_num}
    -- 如果返回的是前者，说明我们还在读取 Redis 推送过的数据
    if res[1] ~= "unsubscribe" then
        repeat
            -- 需要抽空已经接收到的消息
            res, err = red:read_reply()
            if not res then
                ngx.log(ngx.ERR, err)
                return
            end
        until res[1] == "unsubscribe"
    end
    -- 现在再复用连接，就足够安全了
    self.set_keepalive_mod(redis)
end
```
