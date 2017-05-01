# 动态限速

在应用开发中，经常会有对请求进行限速的需求。

通常意义上的限速，其实可以分为以下三种:
1. limit_rate  限制响应速度
2. limit_conn  限制连接数
3. limit_req   限制请求数

接下来让我们看看，这三种限速在 OpenResty 中分别怎么实现。

### 限制响应速度

Nginx 有一个 `$limit_rate`，这个变量反映的是当前请求每秒能响应的字节数。该字节数默认为配置文件中 `limit_rate` 指令的设值。
一如既往，通过 OpenResty，我们可以直接在 Lua 代码中动态设置它。

```
access_by_lua_block {
    -- 设定当前请求的响应上限是 每秒 300K 字节
    ngx.var.limit_rate = "300K"
}
```

### 限制连接数和请求数

对于连接数和请求数的限制，我们可以求助于 OpenResty 官方的 [lua-resty-limit-traffic](https://github.com/openresty/lua-resty-limit-traffic)
需要注意的是，`lua-resty-limit-traffic` 要求 OpenResty 版本在 `1.11.2.2` 以上（对应的 `lua-nginx-module` 版本是 `0.10.6`）。
如果要配套更低版本的 OpenResty 使用，需要修改源码。比如把代码中涉及 `incr(key, value, init)` 方法，改成 `incr(key, value)` 和 `set(key, init)` 两步操作。这么改会增大有潜在 race condition 的区间。

`lua-resty-limit-traffic` 这个库是作用于所有 Nginx worker 的。
由于数据同步上的局限，在限制请求数的过程中 `lua-resty-limit-traffic` 有一个 race condition 的区间，可能多放过几个请求。误差大小取决于 Nginx worker 数量。
如果要求“宁可拖慢一千，不可放过一个”的精确度，恐怕就不能用这个库了。你可能需要使用 `lua-resty-lock` 或外部的锁服务，只是性能上的代价会更高。

`lua-resty-limit-traffic` 的限速实现基于[漏桶原理](https://en.wikipedia.org/wiki/Leaky_bucket#Concept_of_Operation)。
通俗地说，就是小学数学中，蓄水池一边注水一边放水的问题。
这里注水的速度是新增请求/连接的速度，而放水的速度则是配置的限制速度。
当注水速度快于放水速度（表现为池中出现蓄水），则返回一个数值 delay。调用者通过 `ngx.sleep(delay)` 来减慢注水的速度。
当蓄水池满时（表现为当前请求/连接数超过设置的 burst 值），则返回错误信息 `rejected`。调用者需要丢掉溢出来的这部份。

下面是限制连接数的示例：
```
# nginx.conf
lua_code_cache on;
# 注意 limit_conn_store 的大小需要足够放置限流所需的键值。
# 每个 $binary_remote_addr 大小不会超过 16K，算上 lua_shared_dict 的节点大小，总共不到 64 字节。
# 100M 可以放 1.6M 个键值对
lua_shared_dict limit_conn_store 100M;
server {
    listen 8080;
    location / {
        access_by_lua_file src/access.lua;
        content_by_lua_file src/content.lua;
        log_by_lua_file src/log.lua;
    }
}
```

```lua
-- utils/limit_conn.lua
local limit_conn = require "resty.limit.conn"

-- new 的第四个参数用于估算每个请求会维持多长时间，以便于应用漏桶算法
local limit, limit_err = limit_conn.new("limit_conn_store", 10, 2, 0.05)
if not limit then
    error("failed to instantiate a resty.limit.conn object: ", limit_err)
end

local _M = {}

function _M.incoming()
    local key = ngx.var.binary_remote_addr
    local delay, err = limit:incoming(key, true)
    if not delay then
        if err == "rejected" then
            return ngx.exit(503)
        end
        ngx.log(ngx.ERR, "failed to limit req: ", err)
        return ngx.exit(500)
    end

    if limit:is_committed() then
        local ctx = ngx.ctx
        ctx.limit_conn_key = key
        ctx.limit_conn_delay = delay
    end

    if delay >= 0.001 then
        ngx.log(ngx.WARN, "delaying conn, excess ", delay,
                "s per binary_remote_addr by limit_conn_store")
        ngx.sleep(delay)
    end
end

function _M.leaving()
    local ctx = ngx.ctx
    local key = ctx.limit_conn_key
    if key then
        local latency = tonumber(ngx.var.request_time) - ctx.limit_conn_delay
        local conn, err = limit:leaving(key, latency)
        if not conn then
            ngx.log(ngx.ERR,
            "failed to record the connection leaving ",
            "request: ", err)
        end
    end
end

return _M
```

```lua
-- src/access.lua
local limit_conn = require "utils.limit_conn"


-- 对于内部重定向或子请求，不进行限制。因为这些并不是真正对外的请求。
if ngx.req.is_internal() then
    return
end
limit_conn.incoming()
```

```
-- src/log.lua
local limit_conn = require "utils.limit_conn"


limit_conn.leaving()
```

注意在限制连接的代码里面，我们用 `ngx.ctx` 来存储 `limit_conn_key`。这里有一个坑。内部重定向（比如调用了 `ngx.exec`）会销毁 `ngx.ctx`，导致 `limit_conn:leaving()` 无法正确调用。
如果需要限连业务里有用到 `ngx.exec`，可以考虑改用 `ngx.var` 而不是 `ngx.ctx`，或者另外设计一套存储方式。只要能保证请求结束时能及时调用 `limit:leaving()` 即可。

限制请求数的实现差不多，这里就不赘述了。
