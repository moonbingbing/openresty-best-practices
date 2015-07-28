#Lua基础数据类型
#### nil

nil是一种类型，Lua将nil用于表示“无效值”。一个变量在第一次赋值前的默认值是nil，将nil赋予给一个全局变量就等同于删除它。

```lua
local num
print(nil)        -->output:nil

num = 100
print(num)        -->output:100
```

#### boolean

布尔类型，可选值true/false；Lua中nil和false为“假”，其它所有值均为“真”。

```lua
local a = true
local b = 0
local c = nil
if a then
    print("a")
else
    print("not a")
end

if b then
    print("b")
else
    print("not b")
end

if c then
    print("c")
else
    print("not c")
end

------output:
a
b
not c
```


####number

数字，包括整数与浮点数

```lua
local order = 3
local score = 98.5
```

####string

字符串

```lua
local website = "www.google.com"
```

####table

表，关联数组，索引可为字符串string或(整)数number类型

```lua
local corp = {
    web = "www.example.com",
    telephone = "12345678",
    staff = {"Jack", "Scott", "Gary"},
    100876,
    100191,
    ["City"] = "Beijing"
}

print(corp.web)               -->output:www.google.com
local key = "telephone"
print(corp[key])              -->output:12345678
print(corp[2])                -->output:100191
print(corp["City"])           -->output:"Beijing"
print(corp.staff[1])          -->output:Jack

```

####function

在Lua中，**函数**也是一种数据类型，函数可以存储在变量中，可以通过参数传递给其他函数，还可以作为其他函数的返回值。
> 示例

```lua
function foo()
    print("in the function")
    --dosomething()
    local x = 10
    local y = 20
    return x + y
end
```
