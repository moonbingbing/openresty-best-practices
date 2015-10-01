# 下标从1开始

FIXME 这一节的位置很是奇怪。应该分散在 array 类型的 table 一节以及 string 类型的介绍中，或者至少应放置在这两节之前。

-  在*Lua*中，数组下标从1开始计数。

-  官方：Lua lists have a base index of 1 because it was thought to be most friendly for non-programmers, as it makes indices correspond to ordinal element positions.

-  在初始化一个数组的时候，若不显式地用键值对方式赋值，则会默认用数字作为下标，从1开始。由于在*Lua*内部实际采用哈希表和数组分别保存键值对、普通值，所以不推荐混合使用这两种赋值方式。

```lua
local color={first="red", "blue", third="green", "yellow"} 
print(color["first"])                 --> output: red
print(color[1])                       --> output: blue
print(color["third"])                 --> output: green
print(color[2])                       --> output: yellow
print(color[3])                       --> output: nil
```

TODO 应强调，对于 Lua 字符串也是如此。但不适用于 cdata，因为 cdata 使用的是 C 语言的语义。

