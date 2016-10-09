# for 控制结构

Lua 提供了一组传统的、小巧的控制结构，包括用于条件判断的 if 用于迭代的 while、repeat 和 for，本章节主要介绍 for 的使用。

#### for 数字型

for 语句有两种形式：数字 for（numeric for）和范型 for（generic for）。

> 数字型 for 的语法如下：

```lua
for var = begin, finish, step do
    --body
end
```

关于数字 for 需要关注以下几点：
1.var 从 begin 变化到 finish，每次变化都以 step 作为步长递增 var
2.begin、 finish、 step 三个表达式只会在循环开始时执行一次
3.第三个表达式 step 是可选的， 默认为 1
4.控制变量 var 的作用域仅在 for 循环内，需要在外面控制，则需将值赋给一个新的变量
5.循环过程中不要改变控制变量的值，那样会带来不可预知的影响

> 示例

```lua
for i = 1, 5 do
  print(i)
end

-- output:
1
2
3
4
5
```

...

```lua
for i = 1, 10, 2 do
  print(i)
end

-- output:
1
3
5
7
9
```

> 以下是这种循环的一个典型示例：

```lua
for i = 10, 1, -1 do
  print(i)
end

-- output:
...
```

如果不想给循环设置上限的话，可以使用常量 math.huge：

```lua
for i = 1, math.huge do
    if (0.3*i^3 - 20*i^2 - 500 >=0) then
      print(i)
      break
    end
end
```

#### for 泛型

泛型 for 循环通过一个迭代器（iterator）函数来遍历所有值：

```lua
-- 打印数组a的所有值
local a = {"a", "b", "c", "d"}
for i, v in ipairs(a) do
  print("index:", i, " value:", v)
end

-- output:
index:  1  value: a
index:  2  value: b
index:  3  value: c
index:  4  value: d
```

Lua 的基础库提供了 ipairs，这是一个用于遍历数组的迭代器函数。在每次循环中，i 会被赋予一个索引值，同时 v 被赋予一个对应于该索引的数组元素值。

> 下面是另一个类似的示例，演示了如何遍历一个 table 中所有的 key

```lua
-- 打印table t中所有的key
for k in pairs(t) do
    print(k)
end
```

从外观上看泛型 for 比较简单，但其实它是非常强大的。通过不同的迭代器，几乎可以遍历所有的东西，
而且写出的代码极具可读性。标准库提供了几种迭代器，包括用于迭代文件中每行的（io.lines）、
迭代 table 元素的（pairs）、迭代数组元素的（ipairs）、迭代字符串中单词的（string.gmatch）等。

泛型 for 循环与数字型 for 循环有两个相同点：
（1）循环变量是循环体的局部变量；
（2）决不应该对循环变量作任何赋值。

对于泛型 for 的使用，再来看一个更具体的示例。假设有这样一个 table，它的内容是一周中每天的名称：

```lua
local days = {
  "Sunday", "Monday", "Tuesday", "Wednesday",
  "Thursday", "Friday", "Saturday"
}
```

现在要将一个名称转换成它在一周中的位置。为此，需要根据给定的名称来搜索这个 table。然而
在 Lua 中，通常更有效的方法是创建一个“逆向 table”。例如这个逆向 table 叫 revDays，它以
一周中每天的名称作为索引，位置数字作为值：

```lua
  local revDays = {
    ["Sunday"] = 1,
    ["Monday"] = 2,
    ["Tuesday"] = 3,
    ["Wednesday"] = 4,
    ["Thursday"] = 5,
    ["Friday"] = 6,
    ["Saturday"] = 7
  }
```

接下来，要找出一个名称所对应的需要，只需用名字来索引这个 reverse table 即可：

```lua
local x = "Tuesday"
print(revDays[x])  -->3
```

当然，不必手动声明这个逆向 table，而是通过原来的 table 自动地构造出这个逆向table：

```lua
local days = {
   "Monday", "Tuesday", "Wednesday", "Thursday",
   "Friday", "Saturday","Sunday"
}

local revDays = {}
for k, v in pairs(days) do
  revDays[v] = k
end

-- print value
for k,v in pairs(revDays) do
  print("k:", k, " v:", v)
end

-- output:
k:  Tuesday   v: 2
k:  Monday    v: 1
k:  Sunday    v: 7
k:  Thursday  v: 4
k:  Friday    v: 5
k:  Wednesday v: 3
k:  Saturday  v: 6
```

这个循环会为每个元素进行赋值，其中变量 k 为 key(1、2、...)，变量 v 为 value("Sunday"、"Monday"、...)。

值得一提的是，在 LuaJIT 2.1 中，`ipairs()` 内建函数是可以被 JIT 编译的，而 `pairs()` 则只能被解释执行。因此在性能敏感的场景，应当合理安排数据结构，避免对哈希表进行遍历。事实上，即使未来 `pairs` 可以被 JIT 编译，哈希表的遍历本身也不会有数组遍历那么高效，毕竟哈希表就不是为遍历而设计的数据结构。

