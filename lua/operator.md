# 表达式

#### 算术运算符

Lua的算术运算符如下表所示：

| 算术运算符   | 说明   |
|:-----------:| -----:|
| + | 加法 |
| - | 减法 |
| * | 乘法 |
| / | 除法 |
| ^ | 指数 |
| % | 取模 |

>示例代码：test1.lua

```lua
print(1 + 2)       -->打印 3
print(5 / 10)      -->打印 0.5。 这是Lua不同于c语言的
print(5.0 / 10)    -->打印 0.5。 浮点数相除的结果是浮点数
-- print(10 / 0)   -->注意除数不能为0，计算的结果会出错
print(2 ^ 10)      -->打印 1024。 求2的10次方

local num = 1357
print(num % 2)       -->打印 1
print((num % 2) == 1) -->打印 true。 判断num是否为奇数
print((num % 5) == 0)  -->打印 false。判断num是否能被5整数
```

#### 关系运算符

| 关系运算符   | 说明   |
|:-----------:| -----:|
|   <    | 小于     |
|   >    | 大于     |
|   <=   | 小于等于  |
|   >=   | 大于等于  |
|   ==   | 等于     |
|   ~=   | 不等于   |

>示例代码：test2.lua

```lua
print(1 < 2)    -->打印 true
print(1 == 2)   -->打印 false
print(1 ~= 2)   -->打印 true
local a, b = true, false
print(a == b)  -->打印 false
```

**注意：Lua 语言中“不等于”运算符的写法为：~=**

>在使用“==”做等于判断时，要注意对于 table , userdate 和函数， Lua 是作引用比较的。也就是说，只有当两个变量引用同一个对象时，才认为它们相等。可以看下面的例子：

```lua
local a = { x = 1, y = 0}
local b = { x = 1, y = 0}
if a == b then
  print("a==b")
else
  print("a~=b")
end

---output:
a~=b
```

由于 Lua 字符串总是会被“内化”，即相同内容的字符串只会被保存一份，因此 Lua 字符串之间的相等性比较可以简化为其内部存储地址的比较。这意味着 Lua 字符串的相等性比较总是为 O(1). 而在其他编程语言中，字符串的相等性比较则通常为 O(n)，即需要逐个字节（或按若干个连续字节）进行比较。

#### 逻辑运算符

| 逻辑运算符   | 说明  |
|:-----------:| ----:|
|   and   | 逻辑与    |
|   or    | 逻辑或    |
|   not   | 逻辑非    |

Lua 中的 and 和 or 是不同于 c 语言的。在 c 语言中，and 和 or 只得到两个值 1 和 0，其中 1 表示真，0 表示假。而 Lua 中 and 的执行过程是这样的：

- `a and b` 如果 a 为 nil，则返回 a，否则返回 b;
- `a or b` 如果 a 为 nil，则返回 b，否则返回 a。

>示例代码：test3.lua

```lua
local c = nil
local d = 0
local e = 100
print(c and d)  -->打印 nil
print(c and e)  -->打印 nil
print(d and e)  -->打印 100
print(c or d)   -->打印 0
print(c or e)   -->打印 100
print(not c)    -->打印 true
print(not d)    -->打印 false
```

**注意：所有逻辑操作符将 false 和 nil 视作假，其他任何值视作真，对于 and 和 or，“短路求值”，对于not，永远只返回 true 或者 false。**

#### 字符串连接

在Lua中连接两个字符串，可以使用操作符“..”（两个点）。如果其任意一个操作数是数字的话，Lua 会将这个数字转换成字符串。注意，连接操作符只会创建一个新字符串，而不会改变原操作数。也可以使用 string 库函数 `string.format` 连接字符串。

```lua
print("Hello " .. "World")    -->打印 Hello World
print(0 .. 1)                 -->打印 01

str1 = string.format("%s-%s","hello","world")
print(str1)              -->打印 hello-world

str2 = string.format("%d-%s-%.2f",123,"world",1.21)
print(str2)              -->打印 123-world-1.21
```

由于 Lua 字符串本质上是只读的，因此字符串连接运算符几乎总会创建一个新的（更大的）字符串。这意味着如果有很多这样的连接操作（比如在循环中使用 .. 来拼接最终结果），则性能损耗会非常大。在这种情况下，推荐使用 table 和 `table.concat()` 来进行很多字符串的拼接，例如：

```lua
local pieces = {}
for i, elem in ipairs(my_list) do
    pieces[i] = my_process(elem)
end
local res = table.concat(pieces)
```

当然，上面的例子还可以使用 LuaJIT 独有的 `table.new` 来恰当地初始化 `pieces` 表的空间，以避免该表的动态生长。
这个特性我们在后面还会详细讨论。

#### 优先级

Lua操作符的优先级如下表所示(从高到低)：

| 优先级      |
|:----------:|
|   ^        |
|   not &emsp; #&emsp;-  |
|   * &emsp; / &emsp; %    |
|   + &emsp; -      |
|   ..       |
|   <&emsp;>&emsp;<=&emsp; >= &emsp;==&emsp; ~=   |
|   and      |
|   or       |

>示例：

```lua
local a, b = 1, 2
local x, y = 3, 4
local i = 10
local res = 0
res = a + i < b/2 + 1  -->等价于res =  (a + i) < ((b/2) + 1)
res = 5 + x^2*8        -->等价于res =  5 + ((x^2) * 8)  
res = a < y and y <=x  -->等价于res =  (a < y) and (y <= x)
```

**若不确定某些操作符的优先级，就应显示地用括号来指定运算顺序。这样做还可以提高代码的可读性。**
