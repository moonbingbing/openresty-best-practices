# 变量的共享范围

> 本章内容来自openresty讨论组 [这里](https://groups.google.com/forum/#!topic/openresty/3ylMdtvUJqg)

先看两段代码：

```lua
-- index.lua
local uri_args = ngx.req.get_uri_args()
local mo = require('mo')
mo.args = uri_args
```

```lua
-- mo.lua

local showJs = function(callback, data)
    local cjson = require('cjson')
    ngx.say(callback .. '(' .. cjson.encode(data) .. ')')
end
local self.jsonp = self.args.jsonp
local keyList = string.split(self.args.key_list, ',')
for i=1, #keyList do
    -- do something
    ngx.say(self.args.kind)
end
showJs(self.jsonp, valList)
```

大概代码逻辑如上，然后出现这种情况：

生产服务器中，如果没有用户访问，自己几个人测试，一切正常。

同样生产服务器，我将大量的用户请求接入后，我不停刷新页面的时候会出现部分情况（概率也不低，几分之一，大于 10%），输出的 callback（也就是来源于 self.jsonp，即 URL 参数中的 jsonp 变量）和 url 地址中不一致（我自己测试的值是 `?jsonp=jsonp1435220570933`，而用户的请求基本上都是 `?jsonp=jquery....`）。错误的情况都是会出现用户请求才会有的 `jquery....` 这种字符串。另外 URL 参数中的 kind 是 1 ，我在循环中输出会有“1”或“nil”的情况。不仅这两种参数，几乎所有 url 中传递的参数，都有可能变成其他请求链接中的参数。

基于以上情况，个人判断会不会是在生产服务器大量用户请求中，不同请求参数串掉了，但是如果这样，是否应该会出现我本次的获取参数是某个其他用户的值，那么 for 循环中的值也应该固定的，而不会是一会儿是我自己请求中的参数值，一会儿是其他用户请求中的参数值。

### 问题在哪里？

Lua module 是 VM 级别共享的，见[这里](https://github.com/openresty/lua-nginx-module#data-sharing-within-an-nginx-worker)。

`mo.args` 变量一不留神全局共享了，而这肯定不是作者期望的。所以导致了高并发应用场景下偶尔出现异常错误的情况。

每个请求的数据在传递和存储时须特别小心，只应通过你自己的函数参数来传递，或者通过 ngx.ctx 表。前者效率显然较高，而后者胜在能跨阶段使用。

贴一个 ngx.ctx 的例子：

```lua
    location /test {
        rewrite_by_lua_block {
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

### OpenResty 中 Lua 变量的范围

##### 全局变量

在 OpenResty 里面，只有在 `init_by_lua*` 和 `init_worker_by_lua*` 阶段才能定义真正的全局变量。
这是因为其他阶段里面，OpenResty 会设置一个隔离的全局变量表，以免在处理过程污染了其他请求。
即使在上述两个可以定义全局变量的阶段，也尽量避免这么做。全局变量能解决的问题，用模块变量也能解决，
而且会更清晰、更干净。

##### 模块变量

这里把定义在模块里面的变量称为模块变量。无论定义变量时有没有加 `local`，有没有通过 `_M` 把变量引用起来，
定义在模块里面的变量都是模块变量。

由于 Lua VM 会把 require 进来的模块缓存到 `package.loaded` 表里，除非设置了 `lua_code_cache off`，
模块里定义的变量都会被缓存起来。而且重要的是，模块变量在每个请求中是共享的。
模块变量的跨请求特性，可以有很多用途。比如在变量间共享值，或者在 `init_worker_by_lua*` 中初始化全局用到的数值。
作为硬币的反面，无视这一特性也会带来许多问题。下面让我们看看一个例子。

nginx.conf
```
location = /index {
    content_by_lua_file conf/lua/web/index.lua;
}
```

index.lua
```
local var = require "var"


if var.calc() == 1 then
    ngx.say("ok")
else
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say("error")
end
```

var.lua
```
local count = 1

local _M = {}

local function add()
    count = count + 1
end

local function sub()
    count = count - 1
end

function _M.calc()
    add()
    -- 模拟协程调度
    ngx.sleep(ngx.time()%0.003)
    sub()
    return count
end

return _M
```

分别用单个客户端和两个客户端请求之:
```
~/test/openresty wrk --timeout 10s -t 1 -c 1 -d 1s http://localhost:6699/index
Running 1s test @ http://localhost:6699
  1 threads and 1 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.22ms  291.09us   3.48ms   77.30%
    Req/Sec   822.64    175.27     1.01k    54.55%
  900 requests in 1.10s, 153.76KB read
~/test/openresty wrk --timeout 10s -t 2 -c 2 -d 1s http://localhost:6699/index
Running 1s test @ http://localhost:6699
  2 threads and 2 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.18ms  387.03us   7.92ms   85.98%
    Req/Sec     0.86k   168.12     1.02k    60.00%
  1709 requests in 1.00s, 310.29KB read
  Non-2xx or 3xx responses: 852
```

对于那些返回 500 状态码的请求，其调度过程大概是这样的:
```
coroutine A | coroutine B | count
add         |             | 2
sleep       |             | 2
            | add         | 3
            | sleep       | 3
sub         |             | 2

(2 != 1) => HTTP_INTERNAL_SERVER_ERROR!
```

同样道理，如果在模块级别共享 TCP/UDP Client，比如在模块开头 `local httpc = http.new()`，高并发下难免
会有奇怪的问题。把 `httpc:send` 看作 `add`；`httpc:receive` 看作 `sub`，几乎就是上述的例子。
运气好的话，你可能只会碰到一个 `bad request` 的异常；运气不好，就是一个潜在的坑。

##### 本地变量

跟全局变量、模块变量相对，这里我们姑且把 `*_by_lua*` 里面定义的变量称之为本地变量。
本地变量仅在当前阶段有效，如果要跨阶段使用，需要借助 `ngx.ctx` 或者附加在模块变量里。

值得注意的是 `ngx.timer.*`。虽然 timer 代码占的是别的上下文的位置，但是每个 timer 都是运行在自己的协程里面，
里面定义的变量都是协程内部的。

举个例子，让我们在 `init_worker_by_lua_block` 里面定义一个 timer。
```
init_worker_by_lua_block {
    local delay = 5
    local handler
    handler = function()
        counter = counter or 0
        counter = counter + 1
        ngx.log(ngx.ERR, counter)
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
}
```

counter 变量初看是定义在 `init_worker_by_lua*` 的全局变量。定义在 `init_worker_by_lua*` 阶段，没有 `local` 修饰，
根据前面的讨论，它肯定是个全局变量嘛。

运行一下，你会发现，每次 counter 的输出都是 1。

其实 counter 实际的定义域是 handler 这个函数内部。由于每个 timer 都运行在独立的协程里，timer 的每次触发，
都会重新把 `counter` 定义一遍。如果要在 timer 的每次触发中共享变量，你有两个选择:

1. 通过函数参数，把每个变量都传递一遍。
2. 把要共享的变量当作模块变量。

（当然也可以选择在 `init_worker_by_lua*` 里面、`ngx.timer.*` 外面定义真正的全局变量，不过不太推荐罢了）
