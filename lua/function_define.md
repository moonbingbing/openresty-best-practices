##函数定义
lua 使用关键字*function*定义函数，语法如下：  
```lua
function 函数名 ([参数列表])
   代码块  
end

[ ] 里面的内容是可选的。
```
函数的定义一定要放在函数调用前。
例：
```lua
function max(a,b) --定义函数max，用来求两个数的最大值，并返回
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
如果参数列表为空，必须使用()表明是函数调用。
例：
```lua
function func()  --形参为空
    print("no parameter")
end

func()           --函数调用，圆扩号不能省

-->output  no parameter
```
