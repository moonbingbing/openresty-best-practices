# 和MySQL调用方式的区别

> 我们看看ngx\_postgres模块提供的指令怎么组合的：


        location /postgres {
            internal;

            default_type text/html;
            set_by_lua $query_sql '
                if ngx.var.arg_sql then
                    return ngx.unescape_uri(ngx.var.arg_sql)
                end
                
                local ngx_share     = ngx.shared.ngx_cache_sql
                return ngx_share:get(ngx.var.arg_id)
                ';
            postgres_pass   pg_server;
            rds_json          on;
            rds_json_buffer_size 16k;
            postgres_query  $query_sql;
            postgres_connect_timeout 1s;
            postgres_result_timeout 2s;
        }


这里有很多指令要素：

* internal 这个指令指定所在的 location 只允许使用于处理内部请求，否则返回 404 。
* set\_by\_lua 这一段内嵌的 lua 代码用于计算出 $query_sql 变量的值，即要发送给 PostgreSQL 处理的 SQL 语句。
* postgres\_pass 这个指令可以指定一组提供后台服务的 PostgreSQL 数据库的 upstream 块。
* rds\_json 这个指令是 ngx\_rds\_json 提供的，用于指定 ngx\_rds\_json 的 output 过滤器的开关状态，其模块作用就是一个用于把 rds 格式数据转换成 json 格式的 output filter。这个指令在这里出现意思是让 ngx\_rds\_json 模块帮助 ngx\_postgres 模块把模块输出数据转换成 json 格式的数据。
* rds_json_buffer_size 这个指令指定 ngx\_rds\_json 用于每个连接的数据转换的内存大小. 默认是 4/8k,适当加大此参数，有利于减少 CPU 消耗。
* postgres_query 指定 SQL 查询语句，查询语句将会直接发送给 PostgreSQL 数据库。
* postgres_connect_timeout 设置连接超时时间。
* postgres_result_timeout 设置结果返回超时时间。

 