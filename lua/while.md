#while 型控制结构
Lua跟其他常见语言一样，提供了while控制结构，语法上也没有什么特别的。但是没有提供do-while型的控制结构,但是提供了功力相当的[repeat](repeat.md)。
while型控制结构语法如下：

```lua
x=1
while x<3 do
    print(x)
    x=x+1
end
--[[output:
1
2
]]
```