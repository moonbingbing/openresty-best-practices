# 函数返回值

Lua 具有一项与众不同的特性，允许函数返回多个值。Lua 的库函数中，有一些就是返回多个值。

> 示例代码：使用库函数 `string.find`，在源字符串中查找目标字符串，若查找成功，则返回目标字符串在源字符串中的起始位置和结束位置的下标。

```lua
local s, e = string.find("hello world", "llo")
print(s, e)  -->output 3  5
```

返回多个值时，值之间用“,”隔开。

> 示例代码：定义一个函数，实现两个变量交换值

```lua
local function swap(a, b)   -- 定义函数 swap，实现两个变量交换值
   return b, a              -- 按相反顺序返回变量的值
end

local x = 1
local y = 20
x, y = swap(x, y)           -- 调用 swap 函数
print(x, y)                 --> output   20     1
```

当函数返回值的个数和接收返回值的变量的个数不一致时，Lua 也会自动调整参数个数。

调整规则：
- 若返回值个数 **大于** 接收变量的个数，**多余的返回值会被忽略掉**；
- 若返回值个数 **小于** 参数个数，从左向右，没有被返回值初始化的变量会被初始化为 **nil**。

> 示例代码：

```lua
function init()             --init 函数 返回两个值 1 和 "lua"
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

当一个函数有一个以上返回值，且函数调用不是一个列表表达式的最后一个元素，那么函数调用只会产生一个返回值, 也就是第一个返回值。

> 示例代码：

```lua
local function init()       -- init 函数 返回两个值 1 和 "lua"
    return 1, "lua"
end

local x, y, z = init(), 2   -- init 函数的位置不在最后，此时只返回 1
print(x, y, z)              -->output  1  2  nil

local a, b, c = 2, init()   -- init 函数的位置在最后，此时返回 1 和 "lua"
print(a, b, c)              -->output  2  1  lua
```

函数调用的实参列表也是一个列表表达式。考虑下面的例子：

```lua
local function init()
    return 1, "lua"
end

print(init(), 2)   -->output  1  2
print(2, init())   -->output  2  1  lua
```

如果你确保只取函数返回值的第一个值，可以使用括号运算符，例如

```lua
local function init()
    return 1, "lua"
end

print((init()), 2)   -->output  1  2
print(2, (init()))   -->output  2  1
```

**值得一提的是，如果实参列表中某个函数会返回多个值，同时调用者又没有显式地使用括号运算符来筛选和过滤，则这样的表达式是不能被 LuaJIT 2 所 JIT 编译的，而只能被解释执行。**
