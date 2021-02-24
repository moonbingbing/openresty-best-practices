# 局部变量

`局部变量`，也称内部变量，是指在一个函数内部或复合语句内部定义的变量。局部变量的作用域是定义该变量的函数或定义该变量的复合语句。局部变量的生存期是从函数被调用的时刻算起到函数返回调用处的时刻结束。同样地，在 Lua 中，局部变量如果不加`local`修饰也是全局变量。

Lua 的设计有一点很奇怪，在一个块（block）中的变量，如果之前没有定义过，那么认为它是一个 **全局变量**，而不是这个块的局部变量。这一点和别的语言不同。容易造成不小心覆盖了同名全局变量的错误。

#### 定义

Lua 中的局部变量要用 **local** 关键字来显式定义，不使用 local 显式定义的变量就是全局变量：

```lua
g_var = 1         -- global var
local l_var = 2   -- local var
```

#### 作用域

局部变量的生命周期是有限的，它的作用域仅限于声明它的块（block）。一个块是一个控制结构的执行体、或者是一个函数的执行体再或者是一个程序块（chunk）。我们可以通过下面这个例子来理解一下局部变量作用域的问题：

> 示例代码 test.lua

```lua
x = 10
local i = 1           -- 程序块中的局部变量 i

while i <=x do
    local x = i * 2   -- while 循环体中的局部变量 x
    print(x)          -- output： 2, 4, 6, 8, ...
    i = i + 1
end

if i > 20 then
    local x           -- then 中的局部变量 x
    x = 20
    print(x + 2)      -- 如果 i > 20 将会打印 22，此处的 x 是局部变量
else
    print(x)          -- 打印 10，这里 x 是全局变量
end

print(x)              -- 打印 10
```

#### 使用局部变量的好处

- 1、 局部变量可以避免因为命名问题污染了全局环境。
- 2、 local 变量的访问比全局变量更快。
- 3、 由于局部变量出了作用域之后生命周期结束，这样可以被垃圾回收器及时释放。

常见实现如：`local print = print`

在 Lua 中，应该尽量让定义变量的语句靠近使用变量的语句，这也可以被看做是一种良好的编程风格。在 C 这样的语言中，强制程序员在一个块（或一个过程）的起始处声明所有的局部变量，所以有些程序员认为在一个块的中间使用声明语句是一种不良好地习惯。

实际上，在需要时才声明变量并且赋予有意义的初值，这样可以提高代码的可读性。对于程序员而言，相比在块中的任意位置顺手声明自己需要的变量，和必须跳到块的起始处声明，大家应该能掂量出哪种做法比较方便了吧？

**尽量使用局部变量** 是一种良好的编程风格。然而，初学者在使用 Lua 时，在定义局部变量时很容易忘记加上 local，这时变量就会自动变成全局变量，很可能导致程序出现意想不到的问题。

那么我们怎么检测哪些变量是全局变量呢？如何防止全局变量导致的影响呢？下面给出一段代码，利用元表的方式来自动检查全局变量，并打印必要的调试信息。

#### 检查模块的函数使用全局变量

> 把下面代码保存在 `foo.lua` 文件中。

```lua
local _M = { _VERSION = '0.01' }

function _M.add(a, b)     --两个 number 型变量相加
    return a + b
end

function _M.update_A()    --更新变量值
    A = 365
end

return _M
```

> 把下面代码保存在 `use_foo.lua` 文件中。该文件和 `foo.lua` 在相同目录。

```lua
A = 360     --定义全局变量
local foo = require("foo")

local b = foo.add(A, A)
print("b = ", b)

foo.update_A()
print("A = ", A)
```

> 输出结果：

```lua
#  luajit use_foo.lua
b =   720
A =   365
```

无论是做基础模块或是上层应用，肯定都不愿意这类灰色情况存在，因为它给我们的系统带来很多不确定性（注意 OpenResty 会限制请求过程中全局变量的使用）。 生产中我们是要尽力避免这种情况的出现。

#### 检测代码中的全局变量

**Lua 上下文中应当严格避免使用自己定义的全局变量**。
可以使用一个 `lj-releng` 工具来扫描 Lua 代码，定位使用 Lua 全局变量的地方。`lj` 是 `LuaJIT` 的缩写，所以`lj-releng` 仅支持扫描 `LuaJIT 2.1` 的代码。`lj-releng` 的相关链接：<https://github.com/openresty/openresty-devel-utils/blob/master/lj-releng>

- 如果使用 macOS 或者 Linux，可以使用下面命令安装 `lj-releng`:

    ```bash
    # curl -L https://raw.githubusercontent.com/openresty/openresty-devel-utils/master/lj-releng > /usr/local/bin/lj-releng
    # sudo chmod +x /usr/local/bin/lj-releng
    ```

- Windows 用户请把 `lj-releng` 文件所在目录的绝对路径添加进 `PATH` 环境变量。

然后进入你自己的 Lua 文件所在的工作目录，执行 `lj-releng` 命令，结果如下：

```
#  lj-releng
foo.lua: 0.01 (0.01)
Checking use of Lua global variables in file foo.lua...
op no.  line  instruction args  ; code
2  [8] SETGLOBAL 0 -1  ; A
Checking line length exceeding 80...
WARNING: No "_VERSION" or "version" field found in `use_foo.lua`.
Checking use of Lua global variables in file use_foo.lua...
op no.  line  instruction args  ; code
2  [1] SETGLOBAL 0 -1  ; A
7  [4] GETGLOBAL 2 -1  ; A
8  [4] GETGLOBAL 3 -1  ; A
18 [8] GETGLOBAL 4 -1  ; A
Checking line length exceeding 80...
```

> 结果显示：

在 `foo.lua` 文件中，第 8 行设置了一个全局变量 A ；
在 `use_foo.lua` 文件中，没有版本信息，并且第 1 行设置了一个全局变量 A ，第 4、8 行使用了全局变量 A 。

当然，更推荐采用 `luacheck` 来检查项目中全局变量，之后的“代码静态分析”一节，我们还会讲到如何使用 `luacheck`。
