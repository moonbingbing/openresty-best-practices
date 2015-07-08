# 下标从1开始

-  在*lua*中，数组下标从1开始计数。

-  在初始化一个数组的时候，若不显式地用键值对方式赋值，则会默认用数字作为下标，从1开始。由于在*lua*内部实际采用哈希表和数组分别保存键值对、普通值，所以不推荐混合使用这两种赋值方式。
```lua
local color={first="red", "blue", third="green", "yellow"} 
print(color["first"])                 --> output: red
print(color[1])                       --> output: blue
print(color["third"])                 --> output: green
print(color[2])                       --> output: yellow
```


####  注意：不推荐数组下标从 0 开始，否则很多标准库不能使用。

