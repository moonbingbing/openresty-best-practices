# Lua 基础数据类型

函数 type 能够返回一个值或一个变量所属的类型。

```lua
print(type("hello world")) -->output:string
print(type(print))         -->output:function
print(type(true))          -->output:boolean
print(type(360.0))         -->output:number
print(type(nil))           -->output:nil
```

#### nil（空）

nil 是一种类型，Lua 将 nil 用于表示“无效值”。一个变量在第一次赋值前的默认值是 nil，将 nil 赋予给一个全局变量就等同于删除它。

```lua
local num
print(num)        -->output:nil

num = 100
print(num)        -->output:100
```

值得一提的是，OpenResty 的 Lua 接口还提供了一种特殊的空值，即 `ngx.null`，用来表示不同于 nil 的“空值”。后面在讨论 OpenResty 的 Redis 库的时候，我们还会遇到它。

#### boolean（布尔）

布尔类型，可选值 true/false；Lua 中 nil 和 false 为“假”，其它所有值均为“真”。比如 0 和空字符串就是“真”；C 或者 Perl 程序员或许会对此感到惊讶。

```lua
local a = true
local b = 0
local c = nil
if a then
    print("a")        -->output:a
else
    print("not a")    --这个没有执行
end

if b then
    print("b")        -->output:b
else
    print("not b")    --这个没有执行
end

if c then
    print("c")        --这个没有执行
else
    print("not c")    -->output:not c
end
```

#### number（数字）

Number 类型用于表示实数，和 C/C++ 里面的 double 类型很类似。可以使用数学函数 math.floor（向下取整）和 math.ceil（向上取整）进行取整操作。

```lua
local order = 3.99
local score = 98.01
print(math.floor(order))   -->output:3
print(math.ceil(score))    -->output:99
```

一般地，Lua 的 number 类型就是用双精度浮点数来实现的。值得一提的是，LuaJIT 支持所谓的“dual-number”（双数）模式，即 LuaJIT 会根据上下文用整型来存储整数，而用双精度浮点数来存放浮点数。

另外，LuaJIT 还支持“长长整型”的大整数（在 x86_64 体系结构上则是 64 位整数）。例如

```lua
print(9223372036854775807LL - 1)  -->output:9223372036854775806LL
```

#### string（字符串）

Lua 中有三种方式表示字符串:

1、使用一对匹配的单引号。例：'hello'。

2、使用一对匹配的双引号。例："abclua"。

3、字符串还可以用一种长括号（即[[ ]]）括起来的方式定义。我们把两个正的方括号（即[[）间插入 n 个等号定义为第 n 级正长括号。就是说，0 级正的长括号写作 [[ ，一级正的长括号写作 [=[，如此等等。反的长括号也作类似定义；举个例子，4 级反的长括号写作 ]====]。一个长字符串可以由任何一级的正的长括号开始，而由第一个碰到的同级反的长括号结束。整个词法分析过程将不受分行限制，不处理任何转义符，并且忽略掉任何不同级别的长括号。这种方式描述的字符串可以包含任何东西，当然本级别的反长括号除外。例：[[abc\nbc]]，里面的 "\n" 不会被转义。

另外，Lua 的字符串是不可改变的值，不能像在 c 语言中那样直接修改字符串的某个字符，而是根据修改要求来创建一个新的字符串。Lua 也不能通过下标来访问字符串的某个字符。想了解更多关于字符串的操作，请查看[String 库](lua/string_library.md)章节。

```lua
local str1 = 'hello world'
local str2 = "hello lua"
local str3 = [["add\name",'hello']]
local str4 = [=[string have a [[]].]=]

print(str1)    -->output:hello world
print(str2)    -->output:hello lua
print(str3)    -->output:"add\name",'hello'
print(str4)    -->output:string have a [[]].
```

在 Lua 实现中，Lua 字符串一般都会经历一个“内化”（intern）的过程，即两个完全一样的 Lua 字符串在
Lua 虚拟机中只会存储一份。每一个 Lua 字符串在创建时都会插入到 Lua 虚拟机内部的一个全局的哈希表中。
这意味着

1. 创建相同的 Lua 字符串并不会引入新的动态内存分配操作，所以相对便宜（但仍有全局哈希表查询的开销），
2. 内容相同的 Lua 字符串不会占用多份存储空间，
3. 已经创建好的 Lua 字符串之间进行相等性比较时是 `O(1)` 时间度的开销，而不是通常见到的 `O(n)`.

#### table (表)

Table 类型实现了一种抽象的“关联数组”。“关联数组”是一种具有特殊索引方式的数组，索引通常是字符串（string）或者 number 类型，但也可以是除 `nil` 以外的任意类型的值。

```lua
local corp = {
    web = "www.google.com",   --索引为字符串，key = "web",
                              --            value = "www.google.com"
    telephone = "12345678",   --索引为字符串
    staff = {"Jack", "Scott", "Gary"}, --索引为字符串，值也是一个表
    100876,              --相当于 [1] = 100876，此时索引为数字
                         --      key = 1, value = 100876
    100191,              --相当于 [2] = 100191，此时索引为数字
    [10] = 360,          --直接把数字索引给出
    ["city"] = "Beijing" --索引为字符串
}

print(corp.web)               -->output:www.google.com
print(corp["telephone"])      -->output:12345678
print(corp[2])                -->output:100191
print(corp["city"])           -->output:"Beijing"
print(corp.staff[1])          -->output:Jack
print(corp[10])               -->output:360

```

在内部实现上，table 通常实现为一个哈希表、一个数组、或者两者的混合。具体的实现为何种形式，动态依赖于具体的 table 的键分布特点。

想了解更多关于 table 的操作，请查看 [Table 库](table_library.md) 章节。

#### function (函数)

在 Lua 中，**函数** 也是一种数据类型，函数可以存储在变量中，可以通过参数传递给其他函数，还可以作为其他函数的返回值。
> 示例

```lua
local function foo()
    print("in the function")
    --dosomething()
    local x = 10
    local y = 20
    return x + y
end

local a = foo    --把函数赋给变量

print(a())

--output:
in the function
30
```

有名函数的定义本质上是匿名函数对变量的赋值。为说明这一点，考虑

```lua
function foo()
end
```

等价于

```lua
foo = function ()
end
```

类似地，

```lua
local function foo()
end
```

等价于

```lua
local foo = function ()
end
```
