# LuaRestyDNSLibrary 简介

这个 Lua 库提供了 ngx_lua 模块的 DNS 解析器：

http://wiki.nginx.org/HttpLuaModule

这个 Lua 库基于 ngx_lua 的 cosocket API 实现，可以确定是100%非阻塞的。注意，该模块需要至少需要 ngx_lua 0.5.12 或 ngx_openresty 1.2.1.11 版本。Lua bit 模块也是需要的。如果你的 ngx_lua 中的 LuaJIT 2.0，Lua bit 模块已经被默认开启。注意，这个模块在 ngx_openresty 集成环境中是被默认绑定并开启的。

使用代码示例：

```nginx
lua_package_path "/path/to/lua-resty-dns/lib/?.lua;;";

 server {
     location = /dns {
         content_by_lua '
             local resolver = require "resty.dns.resolver"
             local r, err = resolver:new{
                 nameservers = {"8.8.8.8", {"8.8.4.4", 53} },
                 retrans = 5,  -- 5 retransmissions on receive timeout
                 timeout = 2000,  -- 2 sec
             }

             if not r then
                 ngx.say("failed to instantiate the resolver: ", err)
                 return
             end

             local answers, err = r:query("www.google.com")
             if not answers then
                 ngx.say("failed to query the DNS server: ", err)
                 return
             end

             if answers.errcode then
                 ngx.say("server returned error code: ", answers.errcode,
                         ": ", answers.errstr)
             end

             for i, ans in ipairs(answers) do
                 ngx.say(ans.name, " ", ans.address or ans.cname,
                         " type:", ans.type, " class:", ans.class,
                         " ttl:", ans.ttl)
             end
         ';
     }
 }
```
