# 控制结构：for

Lua提供了一组传统的、小巧的控制结构，包括用于条件判断的if、用于迭代的while、repeat和for。本章节主要介绍for的使用。

#### 数字型for

for语句有两种形式：数字for（numeric for）和范型for（generic for）。

> 数字型for的语法如下：

```lua
for var = begin, finish, step do
--body
end
```

var从begin变化到finish，每次变化都以step作为步长递增var，并执行一次“执行体”。第三个表达式step是可选的，若不指定的话，Lua会将步长默认为1。

> 示例

```lua
for i=1,5 do
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
for i=1,10,2 do
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
for i=10, 1, -1 do
  print(i)
end

-- output:
...
```

如果不想给循环设置上限的话，可以使用常量math.huge：

```lua
for i=1, math.huge do
    if (0.3*i^3 - 20*i^2 - 500 >=0) then
      print(i)
      break
    end
end
```

#### 泛型for

泛型for循环通过一个迭代器（iterator）函数来遍历所有值：

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

Lua的基础库提供了ipairs，这是一个用于遍历数组的迭代器函数。在每次循环中，i会被赋予一个索引值，同时v被赋予一个对应于该索引的数组元素值。

> 下面是另一个类似的示例，演示了如何遍历一个table中所有的key

```lua
-- 打印table t中所有的key
for k in pairs(t) do
  print(k)
end
```

从外观上看泛型for比较简单，但其实它是非常强大的。通过不同的迭代器，几乎可以遍历所有的东西，
而且写出的代码极具可读性。标准库提供了几种迭代器，包括用于迭代文件中每行的（io.lines）、
迭代table元素的（pairs）、迭代数组元素的（ipairs）、迭代字符串中单词的（string.gmatch）等。

泛型for循环与数字型for循环有两个相同点：（1）**循环变量是循环体的局部变量**；（2）**决不应该对
循环变量作任何赋值**。
对于泛型for的使用，再来看一个更具体的示例。假设有这样一个table，它的内容是一周中每天的名称：

```lua
local days = {
  "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
}
```

现在要将一个名称转换成它在一周中的位置。为此，需要根据给定的名称来搜索这个table。然而
在Lua中，通常更有效的方法是创建一个“逆向table”。例如这个逆向table叫revDays，它以
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

接下来，要找出一个名称所对应的需要，只需用名字来索引这个reverse table即可：

```lua
local x = "Tuesday"
print(revDays[x])  -->3
```

当然，不必手动声明这个逆向table，而是通过原来的table自动地构造出这个逆向table：

```lua
local days = {
   "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"
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

这个循环会为每个元素进行赋值，其中变量k为key(1、2、...)，变量v为value("Sunday"、"Monday"、...)。
