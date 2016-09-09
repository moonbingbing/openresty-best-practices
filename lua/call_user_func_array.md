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

<<<<<<< HEAD
我们再新建一个模块  sample

```lua
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

https://github.com/moonbingbing/openresty-best-practices/blob/master/lua/dot_diff.md

```lua
local sample = require "sample"
doAction(sample.hello, sample, ' 123')  -- 相当于sample:hello('123')
doAction(sample.world, ' 321') -- 相当于sample.world('321')
```

# 实战演练
以下代码为360公司公共组件之缓存模块，正是利用了部分特性

```lua
-- {
--   key="...",           cache key
--   exp_time=0,          default expire time
--   exp_time_fail=3,     success expire time
--   exp_time_succ=60*30, failed  expire time
--   lock={...}           lock opsts(resty.lock)
-- }
function get_data_with_cache( opts, fun, ... )
  local ngx_dict_name = "cache_ngx"

  -- get from cache
  local cache_ngx = ngx.shared[ngx_dict_name]
  local values = cache_ngx:get(opts.key)
  if values then
    values = json_decode(values)
    return values.res, values.err
  end

  -- cache miss!
  local lock = lock:new(ngx_dict_name, opts.lock)
  local elapsed, err = lock:lock("lock_" .. opts.key)
  if not elapsed then
    return nil, string.format("get data with cache not found and sleep(%ss) not found again", opts.lock_wait_time)
  end

  -- someone might have already put the value into the cache
  -- so we check it here again:
  values = cache_ngx:get(opts.key)
  if values then
    lock:unlock()

    values = json_decode(values)
    return values.res, values.err
  end

  -- get data
  local exp_time = opts.exp_time or 0 -- default 0s mean forever
  local res, err = fun(...)
  if err then
    exp_time = opts.exp_time_fail or exp_time
  else
    exp_time = opts.exp_time_succ or exp_time
  end
  
  --  update the shm cache with the newly fetched value
  cache_ngx:set(opts.key, json_encode({res=res, err=err}), exp_time)
  lock:unlock()
  return res, err
end
=======
>>>>>>> release/master

