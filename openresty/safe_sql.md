# 防止 SQL 注入

所谓 SQL 注入，就是通过把 SQL 命令插入到 Web 表单提交或输入域名或页面请求的查询字符串，最终达到欺骗服务器执行恶意的 SQL 命令。具体来说，它是利用现有应用程序，将（恶意）的 SQL 命令注入到后台数据库引擎执行的能力，它可以通过在 Web 表单中输入（恶意）SQL 语句得到一个存在安全漏洞的网站上的数据库，而不是按照设计者意图去执行 SQL 语句。比如先前的很多影视网站泄露 VIP 会员密码大多就是通过 Web 表单递交查询字符暴出的，这类表单特别容易受到 SQL 注入式攻击。

### SQL 注入例子

下面给了一个完整的可复现的 SQL 注入例子，实际上注入的 SQL 语句写法有很多，下例是比较简单的。

```lua
location /test {
    content_by_lua_block {
        local mysql = require "resty.mysql"
        local db, err = mysql:new()
        if not db then
            ngx.say("failed to instantiate mysql: ", err)
            return
        end

        db:set_timeout(1000) -- 1 sec

        local ok, err, errno, sqlstate = db:connect{
            host = "127.0.0.1",
            port = 3306,
            database = "ngx_test",
            user = "ngx_test",
            password = "ngx_test",
            max_packet_size = 1024 * 1024 }

        if not ok then
            ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
            return
        end

        ngx.say("connected to mysql.")

        local res, err, errno, sqlstate =
            db:query("drop table if exists cats")
        if not res then
            ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
            return
        end

        res, err, errno, sqlstate =
            db:query("create table cats "
                     .. "(id serial primary key, "
                     .. "name varchar(5))")
        if not res then
            ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
            return
        end

        ngx.say("table cats created.")

        res, err, errno, sqlstate =
            db:query("insert into cats (name) "
                     .. "values (\'Bob\'),(\'\'),(null)")
        if not res then
            ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
            return
        end

        ngx.say(res.affected_rows, " rows inserted into table cats ",
                "(last insert id: ", res.insert_id, ")")

        -- 这里有 SQL 注入（后面的 drop 操作）
        local req_id = [[1'; drop table cats;--]]
        res, err, errno, sqlstate =
            db:query(string.format([[select * from cats where id = '%s']], req_id))
        if not res then
            ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
            return
        end

        local cjson = require "cjson"
        ngx.say("result: ", cjson.encode(res))

        -- 再次查询，table 被删
        res, err, errno, sqlstate =
            db:query([[select * from cats where id = 1]])
        if not res then
            ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
            return
        end

        db:set_keepalive(10000, 100)
    }
}
```

其他变种，大家可以自行爬行搜索引擎了解。

### OpenResty 中如何规避

其实大家可以大概网络爬行一下看看如何解决 SQL 注入，可以发现实现放法很多，比如替换各种关键字等。在 OpenResty 中，其实就简单很多了，只需要对输入参数进行一层过滤即可。

对于 MySQL ，可以调用 `ndk.set_var.set_quote_sql_str` ，进行一次过滤即可。

```lua
-- for MySQL
local req_id = [[1'; drop table cats;--]]
res, err, errno, sqlstate =
    db:query(string.format([[select * from cats where id = '%s']],
    ndk.set_var.set_quote_sql_str(req_id)))
if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
end
```

如果恰巧你使用的是 PostgreSQL ，调用 `ndk.set_var.set_quote_pgsql_str` 过滤输入变量。读者这时候可以再次把这段代码放到刚刚的示例代码中，如果您可以得到下面的错误，恭喜您，以正确的姿势防止 SQL 注入。

    bad result: You have an error in your SQL syntax; check the manual that
    corresponds to your MySQL server version for the right syntax to use near
    '1\'; drop table cats;--''' at line 1: 1064: 42000.



