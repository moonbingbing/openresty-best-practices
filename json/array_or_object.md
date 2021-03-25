# 编码为 array 还是 object

首先大家请看这段源码：
```lua
-- http://www.kyne.com.au/~mark/software/lua-cjson.php
-- version: 2.1 devel

local json = require("cjson")
ngx.say("value --> ", json.encode({dogs={}}))
```

输出结果
```
value --> {"dogs":{}}
```
注意看下 encode 后 key 的值类型，"{}" 代表 key 的值是个 object，"[]" 则代表 key 的值是个数组。
对于强类型语言(C/C++, Java 等)，这时候就有点不爽。因为类型不是它期望的，需要做容错。对于 Lua 而言，它是把数组和字典融合到一起了，所以它是无法区分空数组和空字典的。

参考 [openresty/lua-cjson](https://github.com/openresty/lua-cjson) 中额外贴出测试案例，我们就很容易找到思路了。

```lua
-- 内容节选lua-cjson-2.1.0.2/tests/agentzh.t
=== TEST 1: empty tables as objects
--- lua
local cjson = require("cjson")
print(cjson.encode({}))
print(cjson.encode({dogs = {}}))
--- out
{}
{"dogs":{}}


=== TEST 2: empty tables as arrays
--- lua
local cjson = require("cjson")
cjson.encode_empty_table_as_object(false)
print(cjson.encode({}))
print(cjson.encode({dogs = {}}))
--- out
[]
{"dogs":[]}
```

综合本章节提到的各种问题，我们可以封装一个 `json_encode` 的示例函数：

```lua
local json = require("cjson")
-- 稀疏数组会被处理成 object
json.encode_sparse_array(true)

local function _json_encode(data)
    return json.encode(data)
end

function json_encode( data, empty_table_as_object )
    -- Lua 的数据类型里面，array 和 dict 是同一个东西。对应到 json encode 的时候，就会有不同的判断
    -- cjson 对于空的 table，就会处理为 object，也就是 {}
    -- 处理方法：cjson 使用 `encode_empty_table_as_object` 这个方法。
    json.encode_empty_table_as_object(empty_table_as_object or false) -- 空的 table 默认为 array
    local ok, json_value = pcall(_json_encode, data)
    if not ok then
        return nil
    end
    return json_value
end
```

另一种思路是，使用 `setmetatable(data, json.empty_array_mt)`，来标记特定的 table，让 cjson 在编码这个空 table 时把它处理成 array：
```lua
local data = {}
setmetatable(data, json.empty_array_mt)
ngx.say("empty array: ", json.encode(data)) -- empty array: []
```
