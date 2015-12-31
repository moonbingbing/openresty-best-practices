# Lua基础数据类型

函数type能够返回一个值或一个变量所属的类型。

```lua
print(type("hello world")) -->output:string
print(type(print))         -->output:function
print(type(true))          -->output:boolean
print(type(360.0))         -->output:number
print(type(nil))           -->output:nil
```

#### nil（空）

nil是一种类型，Lua将nil用于表示“无效值”。一个变量在第一次赋值前的默认值是nil，将nil赋予给一个全局变量就等同于删除它。

```lua
local num
print(num)        -->output:nil

num = 100
print(num)        -->output:100
```

#### boolean（布尔）

布尔类型，可选值true/false；Lua中nil和false为“假”，其它所有值均为“真”。

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

number类型用于表示实数，和c/c++里面的double类型一样。可以使用数学函数math.floor（向下取整）和math.ceil（向上取整）进行取整操作。

```lua
local order = 3.0
local score = 98.5
print(math.floor(order))   -->output:3
print(math.ceil(score))    -->output:99
```

#### string（字符串）

Lua中有三种方式表示字符串:

1、使用一对匹配的单引号。例：'hello'。

2、使用一对匹配的双引号。例："abclua"。

3、字符串还可以用一种长括号（即[[ ]]）括起来的方式定义。 我们把两个正的方括号（即[[ ）间插入 n 个等号定义为第 n 级正长括号。 就是说，0 级正的长括号写作 [[ ， 一级正的长括号写作 [=[ ，如此等等。 反的长括号也作类似定义； 举个例子，4 级反的长括号写作 ]====] 。 一个长字符串可以由任何一级的正的长括号开始，而由第一个碰到的同级反的长括号结束。 整个词法分析过程将不受分行限制，不处理任何转义符，并且忽略掉任何不同级别的长括号。 这种方式描述的字符串可以包含任何东西，当然本级别的反长括号除外。 例：[[abc\nbc]]，里面的"\n"不会被转义。

另外，Lua的字符串是不可改变的值，不能像在c语言中那样直接修改字符串的某个字符，而是根据修改要求来创建一个新的字符串。Lua也不能通过下标来访问字符串的某个字符。想了解更多关于字符串的操作，请查看[String库](lua/string_library.md)章节。

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

#### table(表)

table类型实现了“关联数组”。“关联数组” 是一种具有特殊索引方式的数组，索引可为字符串string或(整)数number类型。

```lua
local corp = {
    web = "www.google.com",   --索引为字符串，key = "web", value = "www.google.com"
    telephone = "12345678",   --索引为字符串
    staff = {"Jack", "Scott", "Gary"}, --索引为字符串，值也是一个表
    100876,              --相当于 [1] = 100876，此时索引为数字,key = 1, value = 100876
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

想了解更多关于table的操作，请查看[Table库](table_library.md)章节。

#### function(函数)

在Lua中，**函数** 也是一种数据类型，函数可以存储在变量中，可以通过参数传递给其他函数，还可以作为其他函数的返回值。
> 示例

```lua
function foo()
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
