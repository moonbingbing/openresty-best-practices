# 变量的共享范围

> 本章内容来自openresty讨论组 [这里](https://groups.google.com/forum/#!topic/openresty/3ylMdtvUJqg)

先看两段代码：
```lua
-- index.lua
local uri_args = ngx.req.get_uri_args()
local mo = require('mo') 
mo.args = uri_args
```

```lua
-- mo.lua

local showJs = function(callback, data)
    local cjson = require('cjson')
    ngx.say(callback .. '(' .. cjson.encode(data) .. ')')
end
local self.jsonp = self.args.jsonp
local keyList = string.split(self.args.key_list, ',')
for i=1, #keyList do
    -- do something
    ngx.say(self.args.kind) 
end
showJs(self.jsonp, valList)
```

大概代码逻辑如上，然后出现这种情况：

生产服务器中，如果没有用户访问，自己几个人测试，一切正常。

同样生产服务器，我将大量的用户请求接入后，我不停刷新页面的时候会出现部分情况（概率也不低，几分之一，大于10%），输出的callback（也就是来源于self.jsonp，即URL参数中的jsonp变量）和url地址中不一致（我自己测试的值是?jsonp=jsonp1435220570933，而用户的请求基本上都是?jsonp=jquery....)错误的情况都是会出现用户请求才会有的jquery....这种字符串。另外URL参数中的kind是1，我在循环中输出会有“1”或“nil”的情况。不仅这两种参数，几乎所有url中传递的参数，都有可能变成其他请求链接中的参数。

基于以上情况，个人判断会不会是在生产服务器大量用户请求中，不同请求参数串掉了，但是如果这样，是否应该会出现我本次的获取参数是某个其他用户的值，那么for循环中的值也应该固定的，而不会是一会儿是我自己请求中的参数值，一会儿是其他用户请求中的参数值。

###问题在哪里？
Lua module 是 VM 级别共享的，见[这里](https://github.com/openresty/lua-nginx-module#data-sharing-within-an-nginx-worker)。

self.jsonp变量一不留神全局共享了，而这肯定不是作者期望的。所以导致了高并发应用场景下偶尔出现异常错误的情况。

每请求的数据在传递和存储时须特别小心，只应通过你自己的函数参数来传递，或者通过 ngx.ctx 表。前者是推荐的玩法，因为效率高得多。 

贴一个ngx.ctx的例子：
```lua
    location /test {
        rewrite_by_lua '
            ngx.ctx.foo = 76
        ';
        access_by_lua '
            ngx.ctx.foo = ngx.ctx.foo + 3
        ';
        content_by_lua '
            ngx.say(ngx.ctx.foo)
        ';
    }
```

Then GET /test will yield the output
> 79


