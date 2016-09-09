# 调用代码前先定义函数

Lua 里面的函数必须放在调用的代码之前，下面的代码是一个常见的错误：

```lua
-- test.lua 文件
local i = 100
i = add_one(i)

function add_one(i)
	return i + 1
end
```

我们将得到如下错误：

```shell
# luajit test.lua
luajit: test.lua:2: attempt to call global 'add_one' (a nil value)
stack traceback:
    test.lua:2: in main chunk
    [C]: at 0x0100002150
```

为什么放在调用后面就找不到呢？原因是 Lua 里的 function 定义本质上是变量赋值，即

```lua
function foo() ... end
```

等价于

```lua
foo = function () ... end
```

因此在函数定义之前使用函数相当于在变量赋值之前使用变量，Lua 世界对于没有赋值的变量，默认都是 nil，所以这里也就产生了一个 nil 的错误。

一般地，由于全局变量是每个请求的生命期，因此以此种方式定义的函数的生命期也是每个请求的。为了避免每个请求创建和销毁 Lua closure 的开销，建议将函数的定义都放置在自己的 Lua module 中，例如：

```lua
-- my_module.lua
local _M = {_VERSION = "0.1"}

function _M.foo()
    -- your code
    print("i'm foo")
end

return _M
```

然后，再在 content\_by\_lua\_file 指向的 `.lua` 文件中调用它：

```lua
local my_module = require "my_module"
my_module.foo()
```

因为 Lua module 只会在第一次请求时加载一次（除非显式禁用了 lua\_code\_cache 配置指令），后续请求便可直接复用。
