# json解析的异常捕获

首先来看最最普通的一个json解析的例子（被解析的json字符串是错误的，缺少一个双引号）：
```lua
-- http://www.kyne.com.au/~mark/software/lua-cjson.php
-- version: 2.1 devel

local json = require("cjson")
local str  = [[ {"key:"value"} ]]

local t    = json.decode(str)
ngx.say(" --> ", type(t))


-- ... do the other things
ngx.say("all fine")
```

代码执行错误日志如下：
```
2015/06/27 00:01:42 [error] 2714#0: *25 lua entry thread aborted: runtime error: ...ork/git/github.com/lua-resty-memcached-server/t/test.lua:8: Expected colon but found invalid token at character 9
stack traceback:
coroutine 0:
    [C]: in function 'decode'
    ...ork/git/github.com/lua-resty-memcached-server/t/test.lua:8: in function <...ork/git/github.com/lua-resty-memcached-server/t/test.lua:1>, client: 127.0.0.1, server: localhost, request: "GET /test HTTP/1.1", host: "127.0.0.1:8001"
```

这可不是我们期望的，decode失败，居然500错误直接退了。改良了一下我们的代码：
```lua
local json = require("cjson")

function json_decode( str )
    local json_value = nil
    pcall(function (str) json_value = json.decode(str) end, str)
    return json_value
end
```

如果需要在Lua中处理错误，必须使用函数pcall（protected call）来包装需要执行的代码。
pcall接收一个函数和要传递给后者的参数，并执行，执行结果：有错误、无错误；返回值true或者或false, errorinfo。pcall以一种"保护模式"来调用第一个参数，因此pcall可以捕获函数执行中的任何错误。有兴趣的同学，请更多了解下Lua中的异常处理。

另外，可以使用CJSON 2.1.0，该版本新增一个cjson.safe模块接口，该接口兼容cjson模块，并且在解析错误时不抛出异常，而是返回nil。
```lua
local json = require("cjson.safe")
local str  = [[ {"key:"value"} ]]

local t    = json.decode(str)
if t then
    ngx.say(" --> ", type(t))
end
```