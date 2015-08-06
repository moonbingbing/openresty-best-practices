#模块

从Lua5.1版本开始，就对模块和包添加了新的支持，可是使用require和module来定义和使用模块和包。require用于使用模块，module用于创建模块。简单的说，一个模块就是一个程序库，可以通过require来加载。然后便得到了一个全局变量，表示一个table。这个table就像是一个命名空间，其内容就是模块中导出的所有东西，比如函数和常量，一个符合规范的模块还应使require返回这个table。

####require函数
Lua提供了一个名为require的函数用来加载模块。要加载一个模块，只需要简单地调用require "file"就可以了，file指模块所在的文件名。这个调用会返回一个由模块函数组成的table，并且还会定义一个包含该table的全局变量。

在Lua中创建一个模块最简单的方法是：创建一个table，并将所有需要导出的函数放入其中，最后返回这个table就可以了。相当于将导出的函数作为table的一个字段，在Lua中函数是第一类值，提供了天然的优势。下面写一个自己的模块。

> 把下面的代码保存在文件mod1.lua中。

```lua
complex = {}    -- 全局的变量，模块名称

function complex.new(r, i)
   return {r = r, i = i}
end

complex.i = complex.new(0, 1)  -- 定义一个table型常量i

function complex.add(c1, c2)
    return complex.new(c1.r + c2.r, c1.i + c2.i)
end

function complex.sub(c1, c2)
    return complex.new(c1.r - c2.r, c1.i - c2.i)
end

return complex  -- 返回模块的table
```

> 把下面代码保存在文件main.lua中，然后执行main.lua，调用上述模块。

```lua
require "mod1"

com1 = complex.new(0, 1)
com2 = complex.new(1, 2)

ans = complex.add(com1, com2)
print(ans.r, ans.i)      -->output  1     3
```

>换一种调用方法，把下面代码保存在文件main.lua中，然后执行main.lua。

```lua
local mod = require "mod1"

com1 = mod.new(0, 1)
com2 = mod.new(1, 2)

ans = mod.add(com1, com2)
print(ans.r, ans.i)      -->output  1     3
```

mod1中包含了一个最简单的模块。但是模块名是一个全局变量，用这种定义模块是非常危险的，因为引入了全局变量，在引用模块时非常容易覆盖外面的变量。安全的做法是，把模块名称定义成一个局部变量。
> 把mod1.lua文件改成如下代码。

```lua
local complex = {}    -- 局部变量，模块名称

function complex.new(r, i)
   return {r = r, i = i}
end

complex.i = complex.new(0, 1)  -- 定义一个table型常量i

function complex.add(c1, c2)
    return complex.new(c1.r + c2.r, c1.i + c2.i)
end

function complex.sub(c1, c2)
    return complex.new(c1.r - c2.r, c1.i - c2.i)
end

return complex  -- 返回模块的table
```

此时，模块名是一个局部变量，引用模块时不会覆盖外面的变量，只能使用 *local mod = require "mod1"* 这种方式来引用模块。

在编写代码的过程中，会发现必须显式地将模块名放到每个函数定义中；而且，一个函数在调用同一个模块中的另一个函数时，必须限定被调用函数的名称，然而我们可以稍作变通，在模块中定义一个局部的table类型的变量，通过这个局部的变量来定义和调用模块内的函数，然后将这个局部名称赋予模块的最终的名称。

> 把mod1.lua文件改成如下代码。

```lua
local M = {}    -- 局部的变量
local complex = M     -- 将这个局部变量最终赋值给模块名

function M.new(r, i)
    return {r = r, i = i}
end

M.i = M.new(0, 1)  -- 定义一个table型常量i

function M.add(c1, c2)
    return M.new(c1.r + c2.r, c1.i + c2.i)
end

function M.sub(c1, c2)
    return M.new(c1.r - c2.r, c1.i - c2.i)
end

return complex  -- 返回模块的table
```

现在再去执行main.lua文件，得到的结果和之前是一样的。实际上，可以完全避免写模块名，因为require会将模块名作为参数传给模块。

> 把mod1.lua文件改成如下代码。

```lua
local moduleName = ...      --用... 接收参数

for i = 1, select('#', ...) do
     print(select(i, ...))     -- 打印require函数的参数
end

local M = {}           -- 局部的变量
_G[moduleName] = M     -- 将这个局部变量最终赋值给模块名
local complex = M

function M.new(r, i)
    return {r = r, i = i}
end

M.i = M.new(0, 1)

function M.add(c1, c2)
    return M.new(c1.r + c2.r, c1.i + c2.i)
end

function M.sub(c1, c2)
    return M.new(c1.r - c2.r, c1.i - c2.i)
end

return complex  -- 返回模块的table
```

> 把main.lua文件改成如下代码。然后执行main.lua文件。

```lua
local mod1 = require "mod1"

com1 = mod1.new(0, 1)
com2 = mod1.new(1, 2)

ans = mod1.add(com1, com2)
print(ans.r, ans.i)

-->output  
mod1
1     3
```

####module函数

在Lua5.1中提供了一个新函数module。module(..., package.seeall) 这一行代码会创建一个新的table，将其赋予给模块名对应的全局字段和loaded table，还会将这个table设为主程序块的环境，并且模块还能提供外部访问。但这种写法是不提倡的，官方给出了两点原因：

1. package.seeall 这种方式破坏了模块的高内聚，原本引入"filename"模块只想调用它的内部函数，但是它却可以读写全局属性，例如 "filename.os"。

2. module 函数压栈操作引发的副作用，污染了全局环境变量。例如 module("filename") 会创建一个 filename 的 table*，并将这个 table 注入全局环境变量中，这样使得没有引用它的文件也能调用 filename 模块的方法。


> 把mod1.lua文件改成如下代码。然后执行main.lua，调用该模块也是可以的。（不提倡）

```lua
module(..., package.seeall)

function new(r, i)
    return {r = r, i = i}
end

i = new(0, 1)

function add(c1, c2)
    return new(c1.r + c2.r, c1.i + c2.i)
end

function sub(c1, c2)
    return new(c1.r - c2.r, c1.i - c2.i)
end
```
>[参考资料](http://www.jellythink.com/archives/526)
