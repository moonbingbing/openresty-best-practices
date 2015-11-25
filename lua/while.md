#while 型控制结构
Lua跟其他常见语言一样，提供了while控制结构，语法上也没有什么特别的。但是没有提供do-while型的控制结构,但是提供了功能相当的[repeat](repeat.md)。

while型控制结构语法如下，当表达式值为假（即false或nil）时结束循环。也可以使用[break](break.md)语言提前跳出循环。

```lua
while 表达式 do
--body
end
```

>示例代码，求 1 + 2 + 3 + 4 + 5的结果

```lua
x = 1
sum = 0

while x <= 5 do
    sum = sum + x
    x = x + 1
end
print(sum)  -->output 15
```

值得一提的是，Lua 并没有像许多其他语言那样提供类似 `continue` 这样的控制语句用来立即进入下一个循环迭代（如果有的话）。因此，我们
需要仔细地安排循环体里的分支，以避免这样的需求。