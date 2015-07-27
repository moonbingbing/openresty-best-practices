#function
####函数定义
lua 使用关键字*function*定义函数，语法如下：  

*function 函数名 ([参数列表])    
   代码块  
end*  

[ ] 里面的内容是可选的。

例：定义一个求两数最大值的函数，并返回最大值
```lua
function max(a,b) --定义函数max，用来求两个数的最大值
   local maxx = nil
   if(a>b) then
      maxx = a
   else
      maxx = b
   end
   return maxx   --返回最大值
end

local m = max(-12,20)  --调用函数max，找去-12和20中的最大值
print(m) -->output 20
```
注意：函数的定义一定要放在函数调用前。如果参数列表为空，必须使用()表明是函数调用。


####参数传递
lua 函数的参数是按值传递的。值传递就是调用函数时，实参把它的值通过赋值运算传递给形参，然后形参的改变和实参就没有关系了。
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

fun1(x,y,z)  -->output 1   2

fun2(x,y,z)  -->output 1   2   3   nil
```
上面函数的参数都是固定的，其实lua还支持变长参数。若形参为 ... ,表示该函数可以接收不同长度的参数。访问参数的时候也要使用 ... 。
例：
```lua
function func(...)  --形参为 ... ,表示函数采用变长参数
     for i, v in ipairs{...} do  --访问的时候也要使用 ...
          print(v)
     end
end

func(1,2)      --传递了两个参数
print("\n")
func(1,2,3,4)  --传递了四个参数

-->output
1
2


1
2
3
4
```
####返回值
lua 函数可以没有返回值，可以返回一个值，也可以返回多个值。返回多个值时，值之间用“,”隔开。
例：定义一个函数，实现两个变量交换值
```lua
function swap(a,b) --定义函数swap，实现两个变量交换值

   return b,a   --按相反顺序返回变量的值
end

local x = 1
local y = 20
x,y = swap(x,y) --调用swap函数
print(x,y)      -->output   20     1
```

当函数返回值的个数和接收返回值的变量的个数不一致时，lua也会自动调整参数个数。调整规则：若返回值个数大于接收变量的个数，多余的返回值会被忽略掉；
若返回值个数小于参数个数，从左向右，没有被返回值初始化的变量会被初始化为nil。
例：
```lua
function init() --init函数 返回两个值 1和"lua"
  return 1,"lua"
end

x = init()
print(x)

x,y,z = init()
print(x,y,z)

--output
1
1 lua nil
```
当一个函数有一个以上返回值，且函数调用不是一系列表达式的最后一个元素，那么函数调用只会产生一个返回值,也就是第一个返回值。 
例：
```lua
function init() --init函数 返回两个值 1和"lua"
  return 1,"lua"
end

x,y,z = init(),2
print(x,y,z)   -->output  1  2  nil
```