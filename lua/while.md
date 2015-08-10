#while 型控制结构
Lua跟其他常见语言一样，提供了while控制结构，语法上也没有什么特别的。但是没有提供do-while型的控制结构,但是提供了功力相当的[repeat](repeat.md)。
while型控制结构语法如下：

```lua
x = 1
sum = 0
--求1到5的各数相加和
while x <=5 do
    sum = sum + x
    x = x + 1
end
print(sum)
```

>运行输出：15