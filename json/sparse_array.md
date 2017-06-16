# 稀疏数组

请看示例代码（注意 data 的数组下标）：

```lua
-- http://www.kyne.com.au/~mark/software/lua-cjson.php
-- version: 2.1 devel

local json = require("cjson")

local data = {1, 2}
data[1000] = 99

-- ... do the other things
ngx.say(json.encode(data))
```

运行日志报错结果：

```
2015/06/27 00:23:13 [error] 2714#0: *40 lua entry thread aborted: runtime error: ...ork/git/github.com/lua-resty-memcached-server/t/test.lua:13: Cannot serialise table: excessively sparse array
stack traceback:
coroutine 0:
    [C]: in function 'encode'
    ...ork/git/github.com/lua-resty-memcached-server/t/test.lua:13: in function <...ork/git/github.com/lua-resty-memcached-server/t/test.lua:1>, client: 127.0.0.1, server: localhost, request: "GET /test HTTP/1.1", host: "127.0.0.1:8001"
```

如果把 data 的数组下标修改成 5 ，那么这个 json.encode 就会是成功的。
结果是：[1, 2, null, null, 99]

为什么下标是 1000 就失败呢？实际上这么做是 cjson 想保护你的内存资源。她担心这个下标过大直接撑爆内存（贴心小棉袄啊）。如果我们一定要让这种情况下可以 encode，就要尝试 [encode_sparse_array](https://www.kyne.com.au/~mark/software/lua-cjson-manual.html#encode_sparse_array) API 了。有兴趣的同学可以自己试一试。我相信你看过有关 cjson 的代码后，就知道 cjson 的一个简单危险防范应该是怎样完成的。
