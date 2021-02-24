# break，return 和 goto

#### break
语句 `break` 用来终止 `while`、`repeat` 和 `for` 三种循环的执行，并跳出当前循环体，
继续执行当前循环之后的语句。下面举一个 `while` 循环中的 `break` 的例子来说明：


```lua
-- 计算最小的 x，使从 1 到 x 的所有数相加和大于 100
sum = 0
i = 1
while true do
    sum = sum + i
    if sum > 100 then
        break
    end
    i = i + 1
end
print("The result is " .. i)  -->output:The result is 14
```

在实际应用中，`break` 经常用于嵌套循环中。

#### return

`return` 主要用于从函数中返回结果，或者用于简单的结束一个函数的执行。
关于函数返回值的细节可以参考 [函数的返回值](lua/function_result.md) 章节。`return` 只能写在语句块的最后，一旦执行了 `return` 语句，该语句之后的所有语句都不会再执行。若要写在函数中间，则只能写在一个显式的语句块内，参见示例代码：


```lua
local function add(x, y)
    return x + y
    --print("add: I will return the result " .. (x + y))
    --因为前面有个return，若不注释该语句，则会报错
end

local function is_positive(x)
    if x > 0 then
        return x .. " is positive"
    else
        return x .. " is non-positive"
    end

    --由于return只出现在前面显式的语句块，所以此语句不注释也不会报错，
    --但是不会被执行，此处不会产生输出
    print("function end!")
end

local sum = add(10, 20)
print("The sum is " .. sum)  -->output:The sum is 30
local answer = is_positive(-10)
print(answer)                -->output:-10 is non-positive
```

有时候，为了调试方便，我们可以在某个函数的中间提前 `return`，以进行控制流的短路。此时我们可以将 `return` 放在一个 `do ... end` 代码块中，例如：

```lua
local function foo()
    print("before")
    do return end
    print("after")  -- 这一行语句永远不会执行到
end
```

#### goto

LuaJIT 一开始对标的是 Lua 5.1，但渐渐地也开始加入部分 Lua 5.2 甚至 Lua 5.3 的有用特性。
`goto` 就是其中一个不得不提的例子。

有了 `goto`，我们可以实现 `continue` 的功能：
```lua
for i=1, 3 do
    if i <= 2 then
        print(i, "yes continue")
        goto continue
    end

    print(i, " no continue")

    ::continue::
    print([[i'm end]])
end
```

输出结果：

```shell
$ luajit test.lua
1   yes continue
i'm end
2   yes continue
i'm end
3    no continue
i'm end
```

在 [GotoStatement](http://lua-users.org/wiki/GotoStatement) 这个页面上，你能看到更多用 `goto` 玩转控制流的脑洞。

`goto` 的另外一项用途，就是简化错误处理的流程。有些时候你会发现，直接 goto 到函数末尾统一的错误处理过程，是更为清晰的写法。
```lua
local function process(input)
    print("the input is", input)
    if input < 2 then
        goto failed
    end
    -- 更多处理流程和 goto err

    print("processing...")
    do return end
    ::failed::
    print("handle error with input", input)
end

process(1)
process(3)
```

*PS* ：推荐大家多关注：[http://luajit.org/extensions.html#lua52](http://luajit.org/extensions.html#lua52) ，
说不定你就发现了新大陆。
