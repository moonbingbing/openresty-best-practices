##变长参数
lua 函数的参数是按值传递的。值传递就是调用函数时，实参把它的值通过赋值运算传递给形参，然后形参的改变和实参就没有关系了。在这个过程中，实参是通过它在参数表中的位置与形参匹配起来的。
例：
```lua
function swap(a,b) --定义函数swap,函数内部进行交换两个变量的值
   local temp = a
   a = b
   b = temp
   print(a,b)
end

local x = "hello"
local y = 20
print(x,y)
swap(x,y) --调用swap函数
print(x,y) --调用swap函数后，x和y的值并没有交换

-->output
hello 20
20  hello
hello 20
```
在调用函数的时候，若形参个数和实参个数不同时，lua会自动调整实参个数。调整规则：若实参个数大于形参个数，从左向右，多余的实参被忽略；
若实参个数小于形参个数，从左向右，没有被实参初始化的形参会被初始化为nil。
例：
```lua
function fun1(a,b)  --两个形参，多余的实参被忽略掉
   print(a,b)
end

function fun2(a,b,c,d) --四个形参，没有被实参初始化的形参，用nil初始化
   print(a,b,c,d)
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
上面函数的参数都是固定的，其实lua还支持变长参数。若形参为 ... ,表示该函数可以接收不同长度的参数。访问参数的时候也要使用 ... 。
例：
```lua
function func(...)  --形参为 ... ,表示函数采用变长参数

   local temp = {...}   --访问的时候也要使用 ...
   local ans = table.concat(temp, " ")  --使用table.concat库函数，后面会详细介绍
   print(ans)
end

func(1,2,"\n")      --传递了两个参数
func(1,2,3,4)  --传递了四个参数

-->output
1 2

1 2 3 4
```
lua 还支持通过名称来指定实参，这时候要把所有的实参组织到一个table中，并将这个table作为唯一的实参传给函数。
例：
```lua
function change(arg) --change函数，改变长方形的长和宽，使其各增长一倍
  arg.width = arg.width * 2
  arg.height = arg.height * 2
  return arg
end

local rectangle = { width = 20, height = 15 }
print("before change:", "width =",rectangle.width, "height =",rectangle.height)
rectangle = change(rectangle)
print("after change:", "width =",rectangle.width, "height =",rectangle.height)

-->output
before change:  width = 20  height =  15
after change: width = 40  height =  30
```