# 日志输出

你如何测试和调试你的代码呢？Lua 的两个主力作者是这样回复的：

Luiz Henrique de Figueiredo：我主要是一块一块的构建，分块测试。我很少使用调试器。即使用调试器，也只是调试 C 代码。我从不用调试器调试 Lua 代码。对于 Lua 来说，在适当的位置放几条打印语句通常就可以胜任了。

Roberto Ierusalimschy：我差不多也是这样。当我使用调试器时，通常只是用来查找代码在哪里崩溃了。对于 C 代码，有个像 Valgrind 或者 Purify 这样的工具是必要的。

摘自《编程之魂 -- 采访 Lua 发明人的一篇文章》。

由此可见掌握日志输出是多么重要，下至入门同学，上至 Lua 作者，使用日志输出来确定问题，是很必要的基本手段。

### 标准日志输出

OpenResty 的标准日志输出原句为 `ngx.log(log_level, ...)` ，我们几乎可以在任何 ngx_lua 阶段进行日志的输出。

下面看几个例子：

```nginx
#user  nobody;
worker_processes  1;

error_log  logs/error.log error;    # 日志级别
#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    server {
        listen 8866;
        location / {
            content_by_lua_block {
                local num = 55
                local str = "string"
                local obj
                ngx.log(ngx.ERR, "num:", num)
                ngx.log(ngx.INFO, " string:", str)
                print([[i am print]])
                ngx.log(ngx.ERR, " object:", obj)
            }
        }
    }
}
```

访问网页，生成日志结果如下：

```shell
2016/01/22 16:43:34 [error] 61610#0: *10 [lua] content_by_lua(nginx.conf:26):5:
 num:55, client: 127.0.0.1, server: , request: "GET /hello HTTP/1.1",
 host: "127.0.0.1"
2016/01/22 16:43:34 [error] 61610#0: *10 [lua] content_by_lua(nginx.conf:26):7:
 object:nil, client: 127.0.0.1, server: , request: "GET /hello HTTP/1.1",
 host: "127.0.0.1"
```

大家可以在单行日志中获取很多有用的信息，例如：时间、日志级别、请求ID、错误代码位置、内容、客户端 IP 、请求参数等等，这些信息都是环境信息，我们可以用来辅助完成更多其他操作。这样的话，我们就可以根据需要，任意添加日志内容输出了。

细心的读者发现了，中间的两行日志哪里去了？这里不卖关子，其实是日志输出级别的原因。我们上面的例子，日志输出级别使用的 error，只有等于或大于这个级别的日志才会输出。这里还有一个知识点就是 OpenResty 里面的 print 语句是 INFO 级别。

有关 Nginx 的日志级别，请看下表：

```lua
ngx.STDERR     -- 标准输出
ngx.EMERG      -- 紧急报错
ngx.ALERT      -- 报警
ngx.CRIT       -- 严重，系统故障，触发运维告警系统
ngx.ERR        -- 错误，业务不可恢复性错误
ngx.WARN       -- 告警，业务中可忽略错误
ngx.NOTICE     -- 提醒，业务比较重要信息
ngx.INFO       -- 信息，业务琐碎日志信息，包含不同情况判断等
ngx.DEBUG      -- 调试
```

他们是一些常量，越往上等级越高。读者朋友可以尝试把 error log 日志级别修改为 info，然后重新执行一下测试用例，就可以看到全部日志输出结果了。

对于应用开发，一般使用 ngx.INFO 到 ngx.CRIT 就够了。生产中错误日志开启到 error 级别就够了。如何正确使用这些级别呢？可能不同的人、不同的公司可能有不同见解。

### 网络日志输出

如果你的日志需要归集，并且对时效性要求比较高那么这里要推荐的库可能就让你很喜欢了。 [lua-resty-logger-socket](https://github.com/cloudflare/lua-resty-logger-socket) ，可以说很好的解决了上面提及的几个特性。

[lua-resty-logger-socket](https://github.com/cloudflare/lua-resty-logger-socket) 的目标是替代 Nginx 标准的 [ngx_http_log_module](http://nginx.org/en/docs/http/ngx_http_log_module.html) 以非阻塞 IO 方式推送 access log 到远程服务器上。对远程服务器的要求是支持 [syslog-ng](http://www.balabit.com/network-security/syslog-ng) 的日志服务。

我们来看一下官方示例：

```nginx
lua_package_path "/path/to/lua-resty-logger-socket/lib/?.lua;;";

    server {
        location / {
            log_by_lua '
                local logger = require "resty.logger.socket"
                if not logger.initted() then
                    local ok, err = logger.init{
                        host = 'xxx',
                        port = 1234,
                        flush_limit = 1234,
                        drop_limit = 5678,
                    }
                    if not ok then
                        ngx.log(ngx.ERR, "failed to initialize the logger: ",
                                err)
                        return
                    end
                end

                -- construct the custom access log message in
                -- the Lua variable "msg"

                local bytes, err = logger.log(msg)
                if err then
                    ngx.log(ngx.ERR, "failed to log message: ", err)
                    return
                end
            ';
        }
    }
```

例举几个好处：

* 基于 cosocket 非阻塞 IO 实现
* 日志累计到一定量，集体提交，增加网络传输利用率
* 短时间的网络抖动，自动容错
* 日志累计到一定量，如果没有传输完毕，直接丢弃
* 日志传输过程完全不落地，没有任何磁盘 IO 消耗

