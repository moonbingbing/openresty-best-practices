# 函数的返回值

Lua具有一项与众不同的特性，允许函数返回多个值。Lua的库函数中，有一些就是返回多个值。

>示例代码：使用库函数string.find，在源字符串中查找目标字符串，若查找成功，则返回目标字符串在源字符串中的起始位置和结束位置的下标。

```lua
local s, e = string.find("hello world", "llo")
print(s, e)  -->output 3  5
```

返回多个值时，值之间用“,”隔开。

>示例代码：定义一个函数，实现两个变量交换值

```lua
function swap(a, b) --定义函数swap，实现两个变量交换值
   return b, a   --按相反顺序返回变量的值
end

local x = 1
local y = 20
x, y = swap(x, y) --调用swap函数
print(x, y)      -->output   20     1
```

当函数返回值的个数和接收返回值的变量的个数不一致时，Lua也会自动调整参数个数。调整规则：若返回值个数大于接收变量的个数，多余的返回值会被忽略掉；
若返回值个数小于参数个数，从左向右，没有被返回值初始化的变量会被初始化为nil。
>示例代码：

```lua
function init() --init函数 返回两个值 1和"lua"
  return 1, "lua"
end

x = init()
print(x)

x, y, z = init()
print(x, y, z)

--output
1
1 lua nil
```

当一个函数有一个以上返回值，且函数调用不是一系列表达式的最后一个元素，那么函数调用只会产生一个返回值,也就是第一个返回值。
>示例代码：

```lua
function init() --init函数 返回两个值 1和"lua"
  return 1, "lua"
end

local x, y, z = init(), 2  --init函数的位置不在最后，此时只返回 1
print(x, y, z)   -->output  1  2  nil

local a, b, c = 2, init()  --init函数的位置在最后，此时返回 1 和 "lua"
print(a, b, c)   -->output  2  1  lua
```
