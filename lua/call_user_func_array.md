# 全动态函数调用

调用回调函数，并把一个数组参数作为回调函数的参数。

```lua
local args = {...} or {}
method_name(unpack(args, 1, table.maxn(args)))
```

### 使用场景

如果你的实参 table 中确定没有 nil 空洞，则可以简化为

```lua
method_name(unpack(args))
```

1. 你要调用的函数参数是未知的；
2. 函数的实际参数的类型和数目也都是未知的。

> 伪代码

```lua
add_task(end_time, callback, params)

if os.time() >= endTime then
	callback(unpack(params, 1, table.maxn(params)))
end
```

值得一提的是，`unpack` 内建函数还不能为 LuaJIT 所 JIT 编译，因此这种用法总是会被解释执行。对性能敏感的代码路径应避免这种用法。

### 小试牛刀

```lua
local function run(x, y)
    print('run', x, y)
end

local function attack(targetId)
    print('targetId', targetId)
end

local function do_action(method, ...)
    local args = {...} or {}
    method(unpack(args, 1, table.maxn(args)))
end

do_action(run, 1, 2)         -- output: run 1 2
do_action(attack, 1111)      -- output: targetId    1111
```
