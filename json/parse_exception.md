# json 解析的异常捕获

首先来看最最普通的一个 json 解析的例子（被解析的 json 字符串是错误的，缺少一个双引号）：

```lua
-- http://www.kyne.com.au/~mark/software/lua-cjson.php
-- version: 2.1 devel

local json = require("cjson")
local str  = [[ {"key:"value"} ]]  -- json 串中缺少一个双引号

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

这可不是期望结果：decode 失败，500 错误直接退了。改良了一下代码：

```lua
local decode = require("cjson").decode

function json_decode( str )
    local ok, t = pcall(decode, str)
    if not ok then
        return nil
    end

    return t
end
```

### pcall 函数
如果需要在 Lua 中处理错误，必须使用函数 `pcall`（protected call）来包装需要执行的代码。

`pcall` 接收一个函数和要传递给那个函数的参数，并执行。

**语法格式如下：**
```lua
local status, res = pcall(function_name, params)
if status then
    -- 没有错误
    -- 返回 res
else
    -- 有一些错误
    -- 处理错误的代码
end
```
**接收的参数 (两个)：**
- 第一个参数：被调用的函数，(可以是函数名或完整的函数体)；
- 第二个参数：传给被调用函数的参数。

**执行结果 (两种情况)：**
- 有错误；
- 无错误。

**返回值 (两个)：**
- 第一个是 `pcall` 函数的运行状态：`true` 或者 `false`；
- 第二个是被调用函数的返回值： 正常执行结果或者报错信息 (`errorinfo`)。

**示例**
- 1、 没有错误的情况，`test_pcall_good.lua`
    ```lua
    local function foo(str)
        print("test pcall" .. str)
        return str
    end

    local str = 'hello'
    status, res = pcall(foo, str)

    print(status)
    print(res)
    ```
    执行结果：
    ```lua
    -- output:
    test pcall: hello
    true
    hello
    ```

- 2、 发生错误的情况，`test_pcall_bad.lua`
    ```lua
    local function bar(str)
        print("test pcall" .. st)  -- 这里传入的变量名写错了
        return str
    end

    local str = 'hello'
    status, res = pcall(bar, str)

    print(status)
    print(res)
    ```
    执行结果：
    ```lua
    -- output:
    false
    test_pcall_bad.lua:2: attempt to concatenate global 'st' (a nil value)
    ```

`pcall` 以一种 **“保护模式”** 来调用第一个参数，因此 `pcall` 可以捕获函数执行中的任何错误。
通常在错误发生时，总希望可以得到更多的调试信息，而不只是发生错误的位置。但 `pcall`返回时，它已经销毁了调用栈的部分内容。

Lua 还提供了 `xpcall` 函数，`xpcall` 接收的第二个参数——一个错误处理函数，当错误发生时，Lua 会在调用栈展开（unwind）之前调用错误处理函数，于是就可以在这个函数中使用`debug` 库来获取关于错误的额外信息了。
有兴趣的同学，请更多了解下 Lua 中的异常处理。


### cjson.safe 模块接口
另外，可以使用 `CJSON 2.1.0`，该版本新增一个 `cjson.safe` 模块接口，该接口兼容 `cjson` 模块，并且在解析错误时不抛出异常，而是返回 `nil`。

```lua
local json = require("cjson.safe")
local str  = [[ {"key:"value"} ]]  -- json 串中缺少一个双引号

local t    = json.decode(str)
if t then
    ngx.say(" --> ", type(t))
end
```
