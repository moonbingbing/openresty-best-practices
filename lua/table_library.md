# table library

table库是由一些辅助函数构成的，这些函数将table作为数组来操作。

TODO 介绍 table 的 nil 空洞问题，以及 table 长度的不确定性。

#### table.getn 获取长度

取长度操作符写作一元操作 #。 字符串的长度是它的字节数（就是以一个字符一个字节计算的字符串长度）。

对于常规的数组，里面从 1 到 n 放着一些非空的值的时候， 它的长度就精确的为 n，即最后一个值的下标。 如果数组有一个“空洞” （就是说，nil 值被夹在非空值之间）， 那么 #t 可能是指向任何一个是 nil 值的前一个位置的下标 （就是说，任何一个nil 值都有可能被当成数组的结束）。这也就说明对于有“空洞”的情况，table 的长度存在一定的不可确定性。

```lua
local tblTest1 = { 1, a = 2, 3 }
print("Test1 " .. table.getn(tblTest1))   

local tblTest2 = { 1, nil }
print("Test2 " .. table.getn(tblTest2))  

local tblTest3 = { 1, nil, 2 }
print("Test3 " .. table.getn(tblTest3))  

local tblTest4 = { 1, nil, 2, nil }
print("Test4 " .. table.getn(tblTest4))   

local tblTest5 = { 1, nil, 2, nil, 3, nil }
print("Test5 " .. table.getn(tblTest5))   

local tblTest6 = { 1, nil, 2, nil, 3, nil, 4, nil }
print("Test6 " .. table.getn(tblTest6))  
```

我们使用 Lua 5.1 和 LuaJIT 2.1 分别执行这个用例，结果如下：

```shell
# lua test.lua
Test1 2
Test2 1
Test3 3
Test4 1
Test5 3
Test6 1
# luajit test.lua
Test1 2
Test2 1
Test3 1
Test4 1
Test5 1
Test6 1
```

看看吧，这一段的输出结果。请问，你以后还敢在 lua 的 table 中用 nil 值吗？？？如果你继续往后面加 nil，你可能会发现点什么。你可能认为你发现的是个规律。但是，你千万不要认为这是个规律，因为这是错误的。 

不要在 lua 的 table 中使用 nil 值，**如果一个元素要删除，直接 remove，不要用 nil 去代替**。

#### table.concat (table [, sep [, i [, j ] ] ])

对于元素是 string 或者 number 类型的表 table，返回 `table[i]..sep..table[i+1] ··· sep..table[j]` 连接成的字符串。填充字符串 sep 默认为空白字符串。起始索引位置 i 默认为 1，结束索引位置 j 默认是 table 的长度。如果 i 大于 j，返回一个空字符串。

>示例代码

```lua
local a = {1, 3, 5, "hello" }
print(table.concat(a))
print(table.concat(a, "|"))
print(table.concat(a, " ", 4, 2))
print(table.concat(a, " ", 2, 4))

-->output
135hello
1|3|5|hello

3 5 hello
```

#### table.insert (table, [pos ,] value)

在（数组型）表 table 的 pos 索引位置插入 value，其它元素向后移动到空的地方。pos的默认值是表的长度加一，即默认是插在表的最后。

>示例代码

```
local a = {1, 8}             --a[1] = 1,a[2] = 8
table.insert(a, 1, 3)   --在表索引为1处插入3
print(a[1], a[2], a[3])
table.insert(a, 10)    --在表的最后插入10
print(a[1], a[2], a[3], a[4])

-->output
3	1	8
3	1	8	10
```

 
#### table.maxn (table)

返回（数组型）表 table 的最大索引编号；如果此表没有正的索引编号，返回 0。

当长度省略时，此函数需要通常需要 `O(n)` 的时间复杂度来计算 table 的末尾。因此用这个函数省略索引位置的调用形式来作 table 元素的末尾追加，是高代价操作。

>示例代码

```lua
local a = {}
a[-1] = 10
print(table.maxn(a))
a[5] = 10  
print(table.maxn(a))

-->output
0
5
```

此函数的行为不同于 `#` 运算符，因为 `#` 可以返回数组中任意一个 nil 空洞或最后一个 nil 之前的元素索引。当然，该函数的开销相比 `#` 运算符也会更大一些。

#### table.remove (table [, pos])

在表table中删除索引为pos（pos只能是number型）的元素，并返回这个被删除的元素，它后面所有元素的索引值都会减一。pos的默认值是表的长度，即默认是删除表的最后一个元素。

>示例代码

```lua
local a = { 1, 2, 3, 4}
print(table.remove(a, 1)) --删除速索引为1的元素
print(a[1], a[2], a[3], a[4])

print(table.remove(a))   --删除最后一个元素
print(a[1], a[2], a[3], a[4])

-->output
1
2	3	4	nil
4
2	3	nil	nil
```


#### table.sort (table [, comp])

按照给定的比较函数 comp 给表 table 排序，也就是从 table[1] 到 table[n] ，这里 n 表示 table 的长度。
比较函数有两个参数，如果希望第一个参数排在第二个的前面，就应该返回 true，否则返回 false。
如果比较函数 comp 没有给出，默认从小到大排序。

>示例代码

```lua
local function compare(x, y) --从大到小排序
   return x > y    --如果第一个参数大于第二个就返回true，否则返回false
end

local a = { 1, 7, 3, 4, 25}
table.sort(a)         --默认从小到大排序
print(a[1], a[2], a[3], a[4], a[5])
table.sort(a, compare) --使用比较函数进行排序
print(a[1], a[2], a[3], a[4], a[5])

-->output
1	3	4	7	25
25	7	4	3	1
```


#### table 一些有用的函数

LuaJIT 2.1 新增加的 `table.new` 和 `table.clear` 函数是非常有用的。前者主要用来预分配 lua table 空间，后者主要用来高效的释放 table 空间，并且它们都是可以被 JIT 编译的。

```lua
-- table 是否为空
local function table_is_empty(t)
    return next(t) == nil
end

-- table 是否是数组
local function table_is_array(t)
  if type(t) ~= "table" then return false end
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

-- table 是否是 hash
local function table_is_map(t)
  if type(t) ~= "table" then return false end
  for k,_ in pairs(t) do
    if type(k) == "number" then return false end
  end
  return true
end
```

注：这些函数都无法被 LuaJIT 所 JIT 编译，因为使用了 `next` 和 `pairs` 这些 NYI 原语。
