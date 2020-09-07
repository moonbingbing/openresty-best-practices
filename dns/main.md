# LuaRestyDNSLibrary 简介

这个 Lua 库提供了 `ngx_lua` 模块的 DNS 解析器：[lua-resty-dns](https://github.com/openresty/lua-resty-dns)

该库基于 `ngx_lua` 的 cosocket API 实现，可以确定是 100% 非阻塞的。请注意，该模块至少需要 `ngx_lua` 0.5.12 或 OpenResty 1.2.1.11 版本。

此外，[Lua Bit](http://bitop.luajit.org/) 库也是需要的。 如果你的 `ngx_lua` 绑定的 LuaJIT 的版本是 2.0，就已经默认开启了 Lua Bit 模块。请注意，这个模块在 OpenResty 集成环境中默认是开启的。

重要提示：为了能够生成唯一的 ID，在使用此模块之前，必须使用 `math.randomseed` 正确设定随机生成器。

使用代码示例：

```nginx
lua_package_path "/path/to/lua-resty-dns/lib/?.lua;;";

server {
    location = /dns {
        content_by_lua_block {
            local resolver = require "resty.dns.resolver"
            local r, err = resolver:new{
                nameservers = {"8.8.8.8", {"8.8.4.4", 53} },
                retrans = 5,     -- 5 retransmissions on receive timeout
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
        }
    }
}
```
