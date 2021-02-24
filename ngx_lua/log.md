# 正确的记录日志

看过本章第一节的同学应该还记得，`log_by_lua*` 是一个请求经历的最后阶段。由于记日志跟应答内容无关，Nginx 通常在结束请求之后才更新访问日志。由此可见，如果我们有日志输出的情况，最好统一到 `log_by_lua*` 阶段。如果我们把记日志的操作放在 `content_by_lua*` 阶段，那么将线性的增加请求处理时间。

在公司某个定制化项目中，Nginx 上的日志内容都要输送到 syslog 日志服务器。我们使用了 [lua-resty-logger-socket](https://github.com/cloudflare/lua-resty-logger-socket) 这个库。

> 调用示例代码如下（有问题的）：


```lua
-- lua_package_path "/path/to/lua-resty-logger-socket/lib/?.lua;;";
--
--    server {
--        location / {
--            content_by_lua_file lua/log.lua;
--        }
--    }

-- lua/log.lua
local logger = require "resty.logger.socket"
if not logger.initted() then
    local ok, err = logger.init{
        host = 'xxx',
        port = 1234,
        flush_limit = 1,   --日志长度大于 flush_limit 的时候会将 msg 信息推送一次
        drop_limit = 99999,
    }
    if not ok then
        ngx.log(ngx.ERR, "failed to initialize the logger: ", err)
        return
    end
end

local msg = string.format(.....)
local bytes, err = logger.log(msg)
if err then
    ngx.log(ngx.ERR, "failed to log message: ", err)
    return
end
```


在实测过程中我们发现了些问题：

* 缓存无效：如果 `flush_limit` 的值稍大一些（例如 2000），会导致某些体积比较小的日志出现莫名其妙的丢失，所以我们只能把 `flush_limit` 调的很小
* 自己拼写 msg 所有内容，比较辛苦

那么我们来看 [lua-resty-logger-socket](https://github.com/cloudflare/lua-resty-logger-socket) 这个库的 `log` 函数是如何实现的呢，代码如下：
```lua
function _M.log(msg)
    ...

    if (debug) then
        ngx.update_time()
        ngx_log(DEBUG, ngx.now(), ":log message length: " .. #msg)
    end

    local msg_len = #msg

    if (is_exiting()) then
        exiting = true
        _write_buffer(msg)
        _flush_buffer()
        if (debug) then
            ngx_log(DEBUG, "Nginx worker is exiting")
        end
        bytes = 0
    elseif (msg_len + buffer_size < flush_limit) then  -- 历史日志大小+本地日志大小小于推送上限
        _write_buffer(msg)
        bytes = msg_len
    elseif (msg_len + buffer_size <= drop_limit) then
        _write_buffer(msg)
        _flush_buffer()
        bytes = msg_len
    else
        _flush_buffer()
        if (debug) then
            ngx_log(DEBUG, "logger buffer is full, this log message will be " .. "dropped")
        end
        bytes = 0
        --- this log message doesn't fit in buffer, drop it

        ...
```

由于在 `content_by_lua*` 阶段变量的生命周期会随着请求的终结而终结，所以当日志量小于 `flush_limit` 的情况下这些日志就不能被累积，也不会触发 `_flush_buffer` 函数，所以小日志会丢失。

这些坑回头来看是这么明显，所有的问题都是因为我们把 `lua/log.lua` 用错阶段了，应该放到 `log_by_lua*` 阶段，所有的问题都不复存在。

> 修正后：

```
lua_package_path "/path/to/lua-resty-logger-socket/lib/?.lua;;";

server {
    location / {
        content_by_lua_file lua/content.lua;
        log_by_lua_file lua/log.lua;
    }
}
```

这里有个新问题，如果我的 log 里面需要输出一些 content 的临时变量，两阶段之间如何传递参数呢？

> 方法肯定有，推荐下面这个：

```
location /test {
    rewrite_by_lua_block {
        ngx.say("foo = ", ngx.ctx.foo)
        ngx.ctx.foo = 76
    }
    access_by_lua_block {
        ngx.ctx.foo = ngx.ctx.foo + 3
    }
    content_by_lua_block {
        ngx.say(ngx.ctx.foo)
    }
}
```

更多有关 ngx.ctx 信息，请看[这里](https://github.com/openresty/lua-nginx-module#ngxctx)。
