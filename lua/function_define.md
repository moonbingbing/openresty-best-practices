##函数定义
Lua 使用关键字*function*定义函数，语法如下：

```lua
function function_name (arc)  --arc表示参数列表，函数的参数列表可以为空
   --body  
end
```

函数的定义一定要放在函数调用前。

>示例代码：

```lua
function max(a, b)      --定义函数max，用来求两个数的最大值，并返回
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

如果参数列表为空，必须使用()表明是函数调用。

>示例代码：

```lua
function func()  --形参为空
    print("no parameter")
end

func()           --函数调用，圆扩号不能省

-->output：
no parameter
```

在定义函数要注意几点：

1、利用名字来解释函数、变量的目的，使人通过名字就能看出来函数、变量的作用。
 
2、要勤于写注释，注释可以帮助读者理解代码。
