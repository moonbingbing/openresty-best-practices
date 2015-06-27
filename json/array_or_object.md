# 编码为array还是object

首先大家请看这段源码：
```lua
-- http://www.kyne.com.au/~mark/software/lua-cjson.php
-- version: 2.1 devel

local json = require("cjson")
ngx.say("value --> ", json.encode({dogs={}}))
```

输出结果
> 
> value --> {"dogs":{}}

注意看下encode后key的值类型，"{}" 代表key的值是个object，"[]" 则代表key的值是个数组。对于强类型语言(c/c++, java等)，这时候就有点不爽。因为类型不是他期望的要做容错。对于lua本身，是把数组和字典融合到一起了，所以他是无法区分空数组和空字典的。

春哥已经碰都了同样的问题，所以在他的测试用例中已经很明确。
```lua
-- 内容节选lua-cjson-2.1.0.2/tests/agentzh.t
=== TEST 1: empty tables as objects
--- lua
local cjson = require "cjson"
print(cjson.encode({}))
print(cjson.encode({dogs = {}}))
--- out
{}
{"dogs":{}}



=== TEST 2: empty tables as arrays
--- lua
local cjson = require "cjson"
cjson.encode_empty_table_as_object(false)
print(cjson.encode({}))
print(cjson.encode({dogs = {}}))
--- out
[]
{"dogs":[]}
```


