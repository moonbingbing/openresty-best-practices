# 函数在调用代码前定义
Lua里面的函数必须放在调用的代码之前，下面的代码是一个常见的错误：

```
local i = 100
i = add_one(i)

local function add_one(i)
	return i + 1
end
```

你会得到一个错误提示：

>
[error] 10514#0: *5 lua entry thread aborted: runtime error: attempt to call global 'add_one' (a nil value)

---

为什么放在调用后面就找不到呢？原因是Lua里的function 定义本质上是变量赋值，即

    function foo() ... end

等价于

    foo = function () ... end

因此在函数定义之前使用函数相当于在变量赋值之前使用变量，自然会得到nil的错误。

---

一般地，由于全局变量是每请求的生命期，因此以此种方式定义的函数的生命期也是每请求的。为了避免每请求创建和销毁Lua closure的开销，建议将函数的定义都放置在自己的Lua module中，例如：

    -- my_module.lua
    module("my_module", package.seeall)
    function foo() ... end

然后，再在content\_by\_lua\_file指向的.lua文件中调用它：

    local my_module = require "my_module"
    my_module:foo()

因为Lua module只会在第一次请求时加载一次（除非显式禁用了lua\_code\_cache配置指令），后续请求便可直接复用。

