# 定时任务

在 [请求返回后继续执行](../ngx_lua/continue_after_eof.md) 章节中，我们介绍了一种实现的方法，这里我们介绍一种更优雅更通用的方法：[ngx.timer.at()](https://github.com/openresty/lua-nginx-module#ngxtimerat)。
`ngx.timer.at` 会创建一个 Nginx timer。在事件循环中，Nginx 会找出到期的 timer，并在一个独立的协程中执行对应的 Lua 回调函数。
有了这种机制，`ngx_lua` 的功能得到了非常大的扩展，我们有机会做一些更有想象力的功能出来。比如批量提交和 cron 任务。随便一提，官方的 `resty-cli` 工具，也是基于 `ngx.timer.at` 来运行指定的代码块。

比较典型的用法，如下示例：
```lua
local delay = 5    -- 单位:秒（最多精确到毫秒）
local handler
-- do some routine job in Lua just like a cron job
handler = function (premature)
    if premature then
        return
    end
    local ok, err = ngx.timer.at(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
end

local ok, err = ngx.timer.at(delay, handler)
if not ok then
    ngx.log(ngx.ERR, "failed to create the timer: ", err)
    return
end
```

从示例代码中我们可以看到，`ngx.timer.at` 创建的回调是一次性的。如果要实现“定期”运行，需要在回调函数中重新创建 timer 才行。不过当前主线上的 OpenResty 已经引入了新的 `ngx.timer.every` 接口，允许直接创建定期执行的 timer。

`ngx.timer.at` 的 delay 参数，指定的是 **以秒为单位** 的延迟触发时间。跟 OpenResty 的其他函数一样，指定的时间 **最多精确到毫秒**。如果你想要的是一个当前阶段结束后立刻执行的回调，可以直接设置 `delay` 为 0。
`handler` 回调第一个参数 premature，则是用于标识触发该回调的原因是否由于 timer 的到期。Nginx worker 的退出，也会触发当前所有有效的 timer。这时候 premature 会被设置为 `true`。回调函数需要正确处理这一参数（通常直接返回即可）。

**需要特别注意的是**：有一些 `ngx_lua` 的 API 不能在这里调用，比如子请求、`ngx.req.*`和向下游输出的 API (`ngx.print`、`ngx.flush` 之类)，**原因是这些调用需要依赖具体的请求**。但是 `ngx.timer.at` 自身的运行，与当前的请求并没有关系的。

再说一遍，`ngx.timer.at` 的执行是 **在独立的协程里完成的**。千万不能忽略这一点。有人可能会犯这样的错误：
```lua
local tcpsock = create_tcp_client() -- 创建一个 cosocket 连接
local ok, err = ngx.timer.at(delay, function()
    tcpsock:send() -- bad request!
end)
```
cosocket 跟某个特定的 `ngx_http_request_t*` 绑定在一起的。虽然由于闭包，在回调函数中我们依旧可以访问 `tcpsock`，但整个上下文已经不一样了。
