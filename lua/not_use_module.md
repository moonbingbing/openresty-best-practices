# 抵制使用 module() 定义模块

旧式的模块定义方式是通过 `module("filename"[,package.seeall])*`来显示声明一个包，现在官方不推荐再使用这种方式。这种方式将会返回一个由 `filename` 模块函数组成的 `table` ，并且还会定义一个包含该 `table` 的全局变量。

`module("filename", package.seeall)` 这种写法是不提倡的，官方给出了两点原因：

1. `package.seeall` 这种方式破坏了模块的高内聚，原本引入 "filename" 模块只想调用它的 *foobar()* 函数，但是它却可以读写全局属性，例如 `"filename.os"`。
2. `module` 函数压栈操作引发的副作用，污染了全局环境变量。例如 `module("filename")` 会创建一个 `filename` 的 `table` ，并将这个 `table` 注入全局环境变量中，这样使得没有引用它的文件也能调用 `filename` 模块的方法。

比较推荐的模块定义方法是：

```lua
-- square.lua 长方形模块
local _M = {}           -- 局部的变量
_M._VERSION = '1.0'     -- 模块版本

local mt = { __index = _M }

function _M.new(self, width, height)
    return setmetatable({ width=width, height=height }, mt)
end

function _M.get_square(self)
    return self.width * self.height
end

function _M.get_circumference(self)
    return (self.width + self.height) * 2
end

return _M
```

> 引用示例代码：

```lua
local square = require "square"

local s1 = square:new(1, 2)
print(s1:get_square())          --output: 2
print(s1:get_circumference())   --output: 6
```

另一个跟 lua 的 module 模块相关需要注意的点是，当 lua_code_cache on 开启时，require 加载的模块是会被缓存下来的，这样我们的模块就会以最高效的方式运行，直到被显式地调用如下语句（这里有点像模块卸载）：

```lua
package.loaded["square"] = nil
```

我们可以利用这个特性代码来做一些高阶玩法，比如代码热更新等。
