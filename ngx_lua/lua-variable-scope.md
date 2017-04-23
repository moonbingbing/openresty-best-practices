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

self.jsonp 变量一不留神全局共享了，而这肯定不是作者期望的。所以导致了高并发应用场景下偶尔出现异常错误的情况。

每个请求的数据在传递和存储时须特别小心，只应通过你自己的函数参数来传递，或者通过 ngx.ctx 表。前者是推荐的玩法，因为效率高得多。

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

Then GET /test will yield the output

### ngx_lua 的三种变量范围

##### 进程间

所有 Nginx 的工作进程共享变量，使用指令 lua_shared_dict 定义

##### 进程内

Lua 源码中声明为全局变量，就是声明变量的时候不使用 local 关键字，这样的变量在同一个进程内的所有请求都是共享的

##### 每个请求

Lua 源码中声明变量的时候使用 local 关键字，和 ngx.ctx 类似，变量的生命周期只存在同一个请求中

关于进程的变量，有两个前提条件，一是 ngx_lua 使用 LuaJIT 编译，二是声明全局变量的模块是 require 引用。LuaJIT 会缓存模块中的全局变量，下面用一个例子来说明这个问题。

nginx.conf

```
location /index {
    content_by_lua_file conf/lua/web/index.lua;
}
```

index.lua

```
local ngx = require "ngx"
local var = require "var"


if var.calc() == 100 then
    ngx.say("ok")
else
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say("error")
end
```

var.lua
```
local ngx = require "ngx"

count = 100

local _M = {}

local function add()
    count = count + 1
end

local function sub()
    ngx.update_time()
    ngx.sleep(ngx.time()%0.003) --模拟后端阻塞时间
    count = count - 1
end

function _M.calc()
    add()
    sub()
    return count
end

return _M
```

测试结果
```
➜  web git:(master) ab -c 1 -n 10 http://127.0.0.1:/index
...
HTML transferred:       30 bytes
...
➜  web git:(master) ab -c 3 -n 10 http://127.0.0.1:10982/index
...
HTML transferred:       48 bytes
...
```

并发请求等于 1 的时候，返回的 html 文件的大小为 30 字节；并发等于 3 的时候，返回的 html 文件的大小为 48 字节。说明 30 次请求中有多次请求失败，返回了“error”。这个例子可以说明，如果在模块中使用了全局变量，在高并发的情况下可能发生不可知的结果。

建议不要使用模块中的全局变量，最好使用 ngx.ctx 或 shared dict 替代。如果由于业务需求，非要使用的话，建议该变量的值在也是在一个有限集合内，比方说只有 ture 和 false 两个状态。
> 79
