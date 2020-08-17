# 虚变量

当一个方法返回多个值时，有些返回值有时候用不到，要是声明很多变量来一一接收，显然不太合适（不是不能）。Lua 提供了一个虚变量 (dummy variable) 的概念，
按照 [惯例](https://www.lua.org/pil/1.3.html) 以一个下划线（`_`）来命名，用它来表示丢弃不需要的数值，仅仅起到占位的作用。

> 看一段示例代码：

```lua
-- string.find (s,p)：
-- 两个 string 类型的变量 s 和 p，从变量 s 的开头向后匹配变量 p，
-- 若匹配不成功，返回 nil，
-- 若匹配成功，返回第一次匹配成功的起止下标。

local start, finish = string.find("hello", "he") --start 值为起始下标，
                                                 --finish 值为结束下标
print(start, finish)                             --输出 1   2

local start = string.find("hello", "he")    -- start值为起始下标
print(start)                                -- 输出 1


local _,finish = string.find("hello", "he") --采用虚变量（即下划线），
                                            --接收起始下标值，然后丢弃，
                                            --finish 接收结束下标值
print(finish)                               --输出 2
print(_)                                    --输出 1, `_` 只是一个普通变量,我们习惯上不会读取它的值
```

代码倒数第二行，定义了一个用 local 修饰的 **虚变量**（即 单个下划线）。使用这个虚变量接收 `string.find()` 第一个返回值，忽略不用，直接使用第二个返回值。

虚变量不仅仅可以被用在返回值，还可以用在迭代等。

> 在for循环中的使用：

```lua
-- test.lua 文件
local t = {1, 3, 5}

print("all  data:")
for i,v in ipairs(t) do
    print(i,v)
end

print("")
print("part data:")
for _,v in ipairs(t) do
    print(v)
end
```

执行结果：

```shell
# luajit test.lua
all  data:
1   1
2   3
3   5

part data:
1
3
5
```

当有多个返回值需要忽略时，可以重复使用同一个虚变量:
> 多个占位:

```lua
-- test.lua 文件
function foo()
    return 1, 2, 3, 4
end

local _, _, bar = foo();    -- 我们只需要第三个
print(bar)
```

执行结果：

```shell
# luajit test.lua
3
```
