# 自定义函数

调用回调函数，并把一个数组参数作为回调函数的参数

```
local args = {...} or {}
methodName(unpack(args, 1, table.maxn(args)))
```

# 高级使用

```
local function run(x, y)
    ngx.say('run', x, y)
end

local function attack(targetId)
    ngx.say('targetId', targetId)
end

local function doAction(method, ...)
    local args = {...} or {}
    method(unpack(args, 1, table.maxn(args)))
end

doAction(run, 1, 2)
doAction(attack, 1111)
```

我们再新建一个模块  sample

```
local _M = {}

function _M:hello(str)
    ngx.say('hello', str)
end

function _M.world(str)
    ngx.say('world', str)
end

return _M

```

这个时候我们可以这样调用，代码接上文
因为sample模块的方法声明方式的不同
所以在调用时有些区别 主要是.和:的区别

https://github.com/humbut/openresty-best-practices/blob/master/lua/dot_diff.md

```
local sample = require "sample"
doAction(sample.hello, sample, ' 123')  -- 相当于sample:hello('123')
doAction(sample.world, ' 321') -- 相当于sample.world('321')
```