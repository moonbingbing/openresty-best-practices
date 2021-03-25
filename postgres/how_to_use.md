# PostgresNginxModule 模块的调用方式

### ngx_postgres 模块使用方法

```nginx
location /postgres {
    internal;

    default_type text/html;
    set_by_lua_block $query_sql {return ngx.unescape_uri(ngx.var.arg_sql)}

    postgres_pass            pg_server;
    rds_json                 on;
    rds_json_buffer_size     16k;
    postgres_query           $query_sql;
    postgres_connect_timeout 1s;
    postgres_result_timeout  2s;
}
```


这里有很多指令要素：

* `internal` 这个指令指定所在的 location 只允许用于处理内部请求，否则返回 404。
* `set_by_lua` 这一段内嵌的 Lua 代码用于计算出 `$query_sql` 变量的值，即后续通过指令 `postgres_query` 发送给 PostgreSQL 处理的 SQL 语句。这里使用了 GET 请求的 `query` 参数作为 SQL 语句输入。
* `postgres_pass` 这个指令可以指定一组提供后台服务的 PostgreSQL 数据库的 `upstream` 块。
* `rds_json` 这个指令是 `ngx_rds_json` 提供的，用于指定 `ngx_rds_json` 的 output 过滤器的开关状态，其模块作用就是一个用于把 `rds` 格式数据转换成 `json` 格式的 output filter。
    这个指令在这里出现意思是让 `ngx_rds_json` 模块帮助 `ngx_postgres` 模块把模块输出数据转换成 `json` 格式的数据。
* `rds_json_buffer_size` 这个指令指定 `ngx_rds_json` 用于每个连接的数据转换的内存大小。 默认是 4/8k，适当加大此参数，有利于减少 CPU 消耗。
* `postgres_query` 指定 SQL 查询语句，查询语句将会直接发送给 PostgreSQL 数据库。
* `postgres_connect_timeout` 设置连接超时时间。
* `postgres_result_timeout` 设置结果返回超时时间。

这样的配置就完成了初步的可以提供其他 location 调用的 location 了。但这里还差一个配置没说明白，就是这一行：

```
postgres_pass   pg_server;
```

其实这一行引入了 名叫 `pg_server` 的 `upstream` 块，其定义应该像如下：

```nginx
upstream pg_server {
    postgres_server  192.168.1.2:5432 dbname=pg_database
            user=postgres password=postgres;
    postgres_keepalive max=800 mode=single overflow=reject;
}
```

这里有一些指令要素：

* `postgres_server` 这个指令是必须带的，但可以配置多个，用于配置服务器连接参数，可以分解成若干参数：
    - 直接跟在后面的应该是服务器的 IP:Port
    - `dbname` 是服务器要连接的 PostgreSQL 的数据库名称。
    - `user` 是用于连接 PostgreSQL 服务器的账号名称。
    - `password` 是账号名称对应的密码。

* `postgres_keepalive` 这个指令用于配置长连接连接池参数，长连接连接池有利于提高通讯效率，可以分解为若干参数：
    - `max` 是工作进程可以维护的连接池最大长连接数量。
    - `mode` 是后端匹配模式，在 `postgres_server` 配置了多个的时候发挥作用，有 `single` 和 `multi` 两种值，一般使用 `single` 即可。
    - `overflow` 是当长连接数量到达 `max` 之后的处理方案，有 `ignore` 和 `reject` 两种值。
        + `ignore` 允许创建新的连接与数据库通信，但完成通信后马上关闭此连接。
        + `reject` 拒绝访问并返回 503 Service Unavailable

这样就构成了我们 PostgreSQL 后端通讯的通用 location，在使用 Lua 业务编码的过程中可以直接使用如下代码连接数据库（折腾了这么老半天）：

```lua
local json = require("cjson")

function test()
    local res = ngx.location.capture('/postgres',
        { args = {sql = "SELECT * FROM test" } }
    )

    local status = res.status
    local body = json.decode(res.body)

    if status == 200 then
        status = true
    else
        status = false
    end
    return status, body
end
```

### 与 resty-mysql 调用方式的不同

先来看一下 `lua-resty-mysql` 模块的调用示例代码。

```nginx
# you do not need the following line if you are using
# the ngx_openresty bundle:
lua_package_path "/path/to/lua-resty-mysql/lib/?.lua;;";

server {
    location /test {
        content_by_lua_block {
            local mysql   = require("resty.mysql")
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
                max_packet_size = 1024 * 1024
            }

            if not ok then
                ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
                return
            end

            ngx.say("connected to mysql.")

            -- run a select query, expected about 10 rows in
            -- the result set:
            res, err, errno, sqlstate =
                db:query("select * from cats order by id asc", 10)
            if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
            end

            local cjson = require("cjson")
            ngx.say("result: ", cjson.encode(res))

            -- put it into the connection pool of size 100,
            -- with 10 seconds max idle timeout
            local ok, err = db:set_keepalive(10000, 100)
            if not ok then
                ngx.say("failed to set keepalive: ", err)
                return
            end
        }
    }
}
```

看过这段代码，大家肯定会说：这才是我熟悉的，我想要的。为什么刚刚 `ngx_postgres` 模块的调用这么诡异，配置那么复杂，其实这是发展历史造成的。`ngx_postgres` 起步比较早，当时 OpenResty 也还没开始流行，所以更多的 Nginx 数据库都是以 `ngx_c_module` 方式存在。有了 OpenResty，才让我们具有了使用完整的语言来描述我们业务的能力。

后面我们会单独说一说使用 `ngx_c_module` 的各种不方便，也就是我们所踩过的坑。希望能给大家一个警示，能转到 `lua-resty-***` 这个方向的，就千万不要和 `ngx_c_module` 玩，`ngx_c_module` 的扩展性、可维护性、升级等各方面都没有 `lua-resty-***` 好。

这绝对是经验的总结。不服来辩！
