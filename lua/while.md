# while 型控制结构

Lua 跟其他常见语言一样，提供了 while 控制结构，语法上也没有什么特别的。但是没有提供 do-while 型的控制结构，但是提供了功能相当的 [repeat](repeat.md)。

while 型控制结构语法如下，当表达式值为假（即 false 或 nil）时结束循环。也可以使用 [break](break.md) 语言提前跳出循环。

```lua
while 表达式 do
--body
end
```

> 示例代码，求 1 + 2 + 3 + 4 + 5 的结果

```lua
x = 1
sum = 0

while x <= 5 do
    sum = sum + x
    x = x + 1
end
print(sum)  -->output 15
```

值得一提的是，Lua 并没有像许多其他语言那样提供类似 `continue` 这样的控制语句用来立即进入下一个循环迭代（如果有的话）。因此，我们需要仔细地安排循环体里的分支，以避免这样的需求。

没有提供 `continue`，却也提供了另外一个标准控制语句 `break`，可以跳出当前循环。例如我们遍历 table，查找值为 11 的数组下标索引：

```lua
local t = {1, 3, 5, 8, 11, 18, 21}

local i
for i, v in ipairs(t) do
    if 11 == v then
        print("index[" .. i .. "] have right value[11]")
        break
    end
end
```
