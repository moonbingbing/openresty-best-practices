##函数的参数

####按值传递

Lua函数的参数大部分是按值传递的。值传递就是调用函数时，实参把它的值通过赋值运算传递给形参，然后形参的改变和实参就没有关系了。在这个过程中，实参是通过它在参数表中的位置与形参匹配起来的。

>示例代码：

```lua
local function swap(a, b) --定义函数swap,函数内部进行交换两个变量的值
   local temp = a
   a = b
   b = temp
   print(a, b)
end

local x = "hello"
local y = 20
print(x, y)
swap(x, y) --调用swap函数
print(x, y) --调用swap函数后，x和y的值并没有交换

-->output
hello 20
20  hello
hello 20
```

在调用函数的时候，若形参个数和实参个数不同时，Lua会自动调整实参个数。调整规则：若实参个数大于形参个数，从左向右，多余的实参被忽略；
若实参个数小于形参个数，从左向右，没有被实参初始化的形参会被初始化为nil。

>示例代码：

```lua
local function fun1(a, b)  --两个形参，多余的实参被忽略掉
   print(a, b)
end

local function fun2(a, b, c, d) --四个形参，没有被实参初始化的形参，用nil初始化
   print(a, b, c, d)
end

local x = 1
local y = 2
local z = 3

fun1(x, y, z)  -- z被函数fun1忽略掉了，参数变成 x, y

fun2(x, y, z)  -- 后面自动加上一个nil，参数变成 x, y, z, nil

-->output
1   2
1   2   3   nil
```

####变长参数

上面函数的参数都是固定的，其实Lua还支持变长参数。若形参为 ... ,表示该函数可以接收不同长度的参数。访问参数的时候也要使用 ... 。

>示例代码：

```lua
local function func(...)  --形参为 ... ,表示函数采用变长参数

   local temp = {...}   --访问的时候也要使用 ...
   local ans = table.concat(temp, " ")  --使用table.concat库函数，对数组内容使用" "拼接成字符串。
   print(ans)
end

func(1, 2)      --传递了两个参数
func(1, 2, 3, 4)  --传递了四个参数

-->output
1 2

1 2 3 4
```

值得一提的是，LuaJIT 2 尚不能 JIT 编译这种变长参数的用法，只能解释执行。所以对性能敏感的代码，应当避免使用此种形式。

####具名参数

Lua 还支持通过名称来指定实参，这时候要把所有的实参组织到一个table中，并将这个table作为唯一的实参传给函数。

>示例代码：

```lua
local function change(arg) --change函数，改变长方形的长和宽，使其各增长一倍
  arg.width = arg.width * 2
  arg.height = arg.height * 2
  return arg
end

local rectangle = { width = 20, height = 15 }
print("before change:", "width =", rectangle.width, "height =", rectangle.height)
rectangle = change(rectangle)
print("after change:", "width =", rectangle.width, "height =", rectangle.height)

-->output
before change:  width = 20  height =  15
after change: width = 40  height =  30
```

####按引用传递

当函数参数是 table 类型时，传递进来的是 实际参数的引用，此时在函数内部对该 table 所做的修改，会直接对调用者所传递的实际参数生效，而无需自己返回结果和让调用者进行赋值。
我们把上面改变长方形长和宽的例子修改一下。

>示例代码：

```lua
function change(arg) --change函数，改变长方形的长和宽，使其各增长一倍
  arg.width = arg.width * 2  --表arg不是表rectangle的拷贝，他们是同一个表
  arg.height = arg.height * 2
end                  -- 没有return语句了

local rectangle = { width = 20, height = 15 }
print("before change:", "width = ", rectangle.width, " height = ", rectangle.height)
change(rectangle)
print("after change:", "width = ", rectangle.width, " height =", rectangle.height)

-->output
before change:  width = 20  height = 15
after change: width = 40  height = 30
```

在常用基本类型中，除了table是按址传递类型外，其它的都是按值传递参数。

用全局变量来代替函数参数的不好编程习惯应该被抵制，良好的编程习惯应该是减少全局变量的使用。
