# 函数定义

Lua 使用关键字*function*定义函数，语法如下：

```lua
function function_name (arc)  --arc表示参数列表，函数的参数列表可以为空
   -- body  
end
```

上面的语法定义了一个全局函数，名为 `function_name`. 全局函数本质上就是函数类型的值赋给了一个全局变量，即上面的语法等价于

```
function_name = function (arc)
  -- body
end_
```

由于全局变量一般会污染全局名字空间，同时也有性能损耗（即查询全局环境表的开销），因此我们应当尽量使用“局部函数”，其记法是类似的，
只是开头加上 `local` 修饰符：

```
local function function_name (arc)
  -- body
end_
```

由于函数定义本质上就是变量赋值，而变量的定义总是应放置在变量使用之前，所以函数的定义也需要放置在函数调用之前。

>示例代码：

```lua
local function max(a, b)      --定义函数max，用来求两个数的最大值，并返回
   local temp = nil    --使用局部变量temp，保存最大值
   if(a > b) then
      temp = a
   else
      temp = b
   end
   return temp         --返回最大值
end

local m = max(-12, 20)  --调用函数max，找去-12和20中的最大值
print(m)               -->output 20
```

如果参数列表为空，必须使用 `()` 表明是函数调用。

>示例代码：

```lua
local function func()  --形参为空
    print("no parameter")
end

func()           --函数调用，圆扩号不能省

-->output：
no parameter
```

在定义函数要注意几点：

1. 利用名字来解释函数、变量的目的，使人通过名字就能看出来函数、变量的作用。
2. 要勤于写注释，注释可以帮助读者理解代码。

由于函数定义等价于变量赋值，我们也可以把函数名替换为某个 Lua 表的某个字段，例如

```lua
function Foo.bar(a, b, c)

end
```

此时我们是把一个函数类型的值赋给了 `Foo` 表的 `bar` 字段。换言之，上面的定义等价于

```lua
Foo.bar = function (a, b, c)
    print(a, b, c)
end
```

对于此种形式的函数定义，不能再使用 `local` 修饰符了，因为不存在定义新的局部变量了。