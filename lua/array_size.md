# 判断数组大小

`table.getn(t)` 等价于 `#t` 但计算的是数组元素，不包括 hash 键值。而且数组是以第一个 `nil` 元素作为结束标志的。`#` 只计算 array 的元素个数，它实际上调用了对象的 `metatable` 的 `__len` 函数。对于有 `__len` 方法的函数返回函数返回值，不然就返回数组成员数目。

Lua 中，数组的实现方式类似于 C++ 中的 map，数组中的所有值，都是以 **键值对** 的形式来存储（无论是显式还是隐式）。

Lua 内部实际采用 **哈希表** 和 **数组** 分别保存 **键值对、普通值**，所以不推荐混合使用这两种赋值方式。

尤其需要注意的一点是：**Lua 数组中允许 `nil` 值的存在，但是数组默认结束标志却是 `nil`**。这类比于 C 语言中的字符串，字符串中允许 '\0' 存在，但当读到 '\0' 时，就认为字符串已经结束了。

**初始化是例外**，在 Lua 相关源码中，初始化数组时:

- 首先判断数组的长度，若长度大于 0 ，并且最后一个值不为 `nil`，返回包括 `nil` 的长度；
- 若最后一个值为 `nil`，则返回截至第一个非 `nil` 值的长度。

**注意**：一定不要使用 `#` 操作符或 `table.getn` 来计算包含 `nil` 的数组长度，这是一个未定义的操作，不一定报错，但不能保证结果如你所想。如果你要删除一个数组中的元素，请使用 `remove` 函数，而不是用 `nil` 赋值。

```lua
-- test.lua
local tblTest1 = { 1, a = 2, 3 }
print("Test1 " .. #(tblTest1))

local tblTest2 = { 1, nil }
print("Test2 " .. #(tblTest2))

local tblTest3 = { 1, nil, 2 }
print("Test3 " .. #(tblTest3))

local tblTest4 = { 1, nil, 2, nil }
print("Test4 " .. #(tblTest4))

local tblTest5 = { 1, nil, 2, nil, 3, nil }
print("Test5 " .. #(tblTest5))

local tblTest6 = { 1, nil, 2, nil, 3, nil, 4, nil }
print("Test6 " .. #(tblTest6))
```

我们分别使用 Lua 和 LuaJIT 来执行一下：

```bash
➜ luajit test.lua
Test1 2
Test2 1
Test3 1
Test4 1
Test5 1
Test6 1

➜ lua test.lua
Test1 2
Test2 1
Test3 3
Test4 1
Test5 3
Test6 1
```

这一段的输出结果，就是这么 **匪夷所思**。不要在 Lua 的 table 中使用 `nil` 值，**如果一个元素要删除，直接 remove，不要用 nil 去代替**。
