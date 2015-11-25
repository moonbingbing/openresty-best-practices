#模块

从Lua5.1版本开始，就对模块和包添加了新的支持，可以使用require和module来定义和使用模块和包。require用于使用模块，module用于创建模块。简单的说，一个模块就是一个程序库，可以通过require来加载。然后便得到了一个全局变量，表示一个table。这个table就像是一个命名空间，其内容就是模块中导出的所有东西，比如函数和常量，一个符合规范的模块还应使require返回这个table。

####require函数
Lua提供了一个名为require的函数用来加载模块。要加载一个模块，只需要简单地调用require "file"就可以了，file指模块所在的文件名。这个调用会返回一个由模块函数组成的table，并且还会定义一个包含该table的全局变量。

在Lua中创建一个模块最简单的方法是：创建一个table，并将所有需要导出的函数放入其中，最后返回这个table就可以了。相当于将导出的函数作为table的一个字段，在Lua中函数是第一类值，提供了天然的优势。下面写一个实现复数加法和减法的模块。

> 把下面的代码保存在文件complex.lua中。

```lua
local _M = {}   -- 局部变量，模块名称

function _M.new(r, i)
   return {r = r, i = i}
end

 _M.i =  _M.new(0, 1)     -- 定义一个table型常量i

function  _M.add(c1, c2)  --复数加法
    return  _M.new(c1.r + c2.r, c1.i + c2.i)
end

function  _M.sub(c1, c2)  --复数减法
    return  _M.new(c1.r - c2.r, c1.i - c2.i)
end

return  _M  -- 返回模块的table
```

> 把下面代码保存在文件main.lua中，然后执行main.lua，调用上述模块。

```lua
local complex = require "complex"

local com1 = complex.new(0, 1)
local com2 = complex.new(1, 2)

local ans = complex.add(com1, com2)
print(ans.r, ans.i)      -->output  1     3
```

下面定义和使用模块的习惯是极不好的。用这种定义模块是非常危险的，因为引入了全局变量，在引用模块时非常容易覆盖外面的变量。为了引起读者的注意，每行代码前加了一个'?'。

> 把下面的代码保存在文件complex.lua中。(执行代码要去掉前面的'?')

```lua
? complex = {}   -- 全局变量，模块名称

? function complex.new(r, i)
?     return {r = r, i = i}
? end

? complex.i =complex.new(0, 1)  -- 定义一个table型常量i

? function complex.add(c1, c2)  --复数加法
?     return M.new(c1.r + c2.r, c1.i + c2.i)
? end

? function complex.sub(c1, c2)  --复数减法
?     return M.new(c1.r - c2.r, c1.i - c2.i)
? end

? return complex  -- 返回模块的table
```

> 把下面代码保存在文件main.lua中，然后执行main.lua，调用上述模块。(执行代码要去掉前面的'?')

```lua
? require "complex"

? local com1 = complex.new(0, 1)
? local com2 = complex.new(1, 2)

? local ans = complex.add(com1, com2)
? print(ans.r, ans.i)      -->output  1     3
```

####module函数（不推荐使用）

在Lua5.1中提供了一个新函数module。module(..., package.seeall) 这一行代码会创建一个新的table，将其赋予给模块名对应的全局字段和loaded table，还会将这个table设为主程序块的环境，并且模块还能提供外部访问。但这种写法是不提倡的，官方给出了两点原因：

1. package.seeall 这种方式破坏了模块的高内聚，原本引入"filename"模块只想调用它的内部函数，但是它却可以读写全局属性，例如 "filename.os"。

2. module 函数压栈操作引发的副作用，污染了全局环境变量。例如 module("filename") 会创建一个 filename 的 table*，并将这个 table 注入全局环境变量中，这样使得没有引用它的文件也能调用 filename 模块的方法。


> 把mod1.lua文件改成如下代码。

```lua
module(..., package.seeall)

function new(r, i)
    return {r = r, i = i}
end

local i = new(0, 1)

function add(c1, c2)
    return new(c1.r + c2.r, c1.i + c2.i)
end

function sub(c1, c2)
    return new(c1.r - c2.r, c1.i - c2.i)
end

function update( )
   A = A + 1
end

getmetatable(mod1).__newindex = function (table, key, val) --防止模块更改全局变量
    error('attempt to write to undeclared variable "' .. key .. '": ' .. debug.traceback())
end
```

>把main.lua文件改成如下代码。

```lua
A = 2
require "mod1"

local com1 = mod1.new(0, 1)
local com2 = mod1.new(1, 2)

mod1.update()

local ans = mod1.add(com1, com2)
print(ans.r, ans.i)
```

运行main.lua，会报错：

```lua
lua: .\mod1.lua:22: attempt to write to undeclared variable "A": stack traceback:
	.\mod1.lua:22: in function <.\mod1.lua:21>
	.\mod1.lua:18: in function 'update'
	my.lua:9: in main chunk
	[C]: ?
stack traceback:
	[C]: in function 'error'
	.\mod1.lua:22: in function <.\mod1.lua:21>
	.\mod1.lua:18: in function 'update'
	my.lua:9: in main chunk
	[C]: ?
```

> 把mod1.lua文件改成如下代码。

```lua
module(..., package.seeall)

function new(r, i)
    return {r = r, i = i}
end

local i = new(0, 1)

function add(c1, c2)
    return new(c1.r + c2.r, c1.i + c2.i)
end

function sub(c1, c2)
    return new(c1.r - c2.r, c1.i - c2.i)
end

function update( )
   A = A + 1
end
```

运行main.lua，得到结果：

```lua
1	 3
```
