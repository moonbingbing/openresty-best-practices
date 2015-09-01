#表达式

####算术运算符

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
print(num%2)       -->打印 1
print((num % 2) == 1)) -->打印 true。 判断num是否为奇数
print((num % 5) == 0)  -->打印 false。判断num是否能被5整数
```

####关系运算符

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
print (a == b)  -->打印 false
```

**注意：Lua语言中不等于运算符的写法为：~=**

>在使用“==”做等于判断时，要注意对于table,userdate和函数，Lua是作引用比较的。也就是说，只有当两个变量引用同一个对象时，才认为它们相等。可以看下面的例子：

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


####逻辑运算符

| 逻辑运算符   | 说明  |
|:-----------:| ----:|
|   and   | 逻辑与    |
|   or    | 逻辑或    |
|   not   | 逻辑非    |

Lua中的and和or是不同于c语言的。在c语言中，and和or只得到两个值1和0，其中1表示真，0表示假。而Lua中and的执行过程是这样的：

- a and b 如果a为nil，则返回a，否则返回b;
- a or b 如果a为nil，则返回b，否则返回a。

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

**注意：所有逻辑操作符将false和nil视作假，其他任何值视作真，对于and和or，“短路求值”，对于not，永远只返回true或者false**

####字符串连接

在Lua中连接两个字符串，可以使用操作符“..”（两个点）。如果其任意一个操作数是数字的话，Lua会将这个数字转换成字符串。注意，连接操作符只会创建一个新字符串，而不会改变原操作数。也可以使用string库函数string.format连接字符串。

```lua
print("Hello " .. "World")    -->打印 Hello World
print(0 .. 1)                 -->打印 01

str1 = string.format("%s-%s","hello","world")
print(str1)              -->打印 hello-world

str2 = string.format("%d-%s-%.2f",123,"world",1.21)
print(str2)              -->打印 123-world-1.21
```

####优先级

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
