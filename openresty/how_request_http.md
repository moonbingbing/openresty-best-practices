# 如何发起新 HTTP 请求

OpenResty 最主要的应用场景之一是 API Server，有别于传统 Nginx 的代理转发应用场景，API Server 中心内部有各种复杂的交易流程和判断逻辑，学会高效的与其他 HTTP Server 调用是必备基础。本文将介绍 OpenResty 中两个最常见 HTTP 接口调用方法。

我们先来模拟一个接口场景，一个公共服务专门用来对外提供加了“盐” md5 计算，业务系统调用这个公共服务完成业务逻辑，用来判断请求本身是否合法。

### 利用 proxy_pass

参考下面示例，利用 `proxy_pass` 完成 HTTP 接口访问的成熟配置+调用方法。

```nginx
http {
    upstream md5_server{
        server 127.0.0.1:81;        # ①
        keepalive 20;               # ②
    }

    server {
        listen    80;

        location /test {
            content_by_lua_block {
                ngx.req.read_body()
                local args, err = ngx.req.get_uri_args()

                -- ③
                local res = ngx.location.capture('/spe_md5',
                    {
                        method = ngx.HTTP_POST,
                        body = args.data
                    }
                )

                if 200 ~= res.status then
                    ngx.exit(res.status)
                end

                if args.key == res.body then
                    ngx.say("valid request")
                else
                    ngx.say("invalid request")
                end
            }
        }

        location /spe_md5 {
            proxy_pass http://md5_server;   -- ④
            #For HTTP, the proxy_http_version directive should be set to “1.1” and the “Connection”
            #header field should be cleared.（from:http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive)
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }

    server {
        listen    81;           -- ⑤

        location /spe_md5 {
            content_by_lua_block {
                ngx.req.read_body()
                local data = ngx.req.get_body_data()
                ngx.print(ngx.md5(data .. "*&^%$#$^&kjtrKUYG"))
            }
        }
    }
}
```

重点说明：
- ① 上游访问地址清单（可以按需配置不同的权重规则）；
- ② 上游访问长连接，是否开启长连接，对整体性能影响比较大（大家可以实测一下）；
- ③ 接口访问通过 `ngx.location.capture` 的子查询方式发起；
- ④ 由于 `ngx.location.capture` 方式只能是 Nginx 自身的子查询，需要借助 `proxy_pass` 发出 HTTP 连接信号；
- ⑤ 公共 API 输出服务；

这里大家可以看到，借用 Nginx 周边成熟组件力量，为了发起一个 HTTP 请求，我们需要绕好几个弯子，甚至还有可能踩到坑（`upstream` 中长连接的细节处理），显然没有足够优雅，所以我们继续看下一章节。

### 利用 cosocket

立马开始我们的新篇章，给大家展示优雅的解决方式。

```nginx
http {
    server {
        listen    80;

        location /test {
            content_by_lua_block {
                ngx.req.read_body()
                local args, err = ngx.req.get_uri_args()

                local http = require("resty.http")   -- ①
                local httpc = http.new()
                local res, err = httpc:request_uri( -- ②
                    "http://127.0.0.1:81/spe_md5",
                        {
                        method = "POST",
                        body = args.data,
                      }
                )

                if 200 ~= res.status then
                    ngx.exit(res.status)
                end

                if args.key == res.body then
                    ngx.say("valid request")
                else
                    ngx.say("invalid request")
                end
            }
        }
    }

    server {
        listen    81;

        location /spe_md5 {
            content_by_lua_block {
                ngx.req.read_body()
                local data = ngx.req.get_body_data()
                ngx.print(ngx.md5(data .. "*&^%$#$^&kjtrKUYG"))
            }
        }
    }
}
```

重点解释：
- ① 引用 `resty.http` 库资源，它来自 github [https://github.com/pintsized/lua-resty-http](https://github.com/pintsized/lua-resty-http)。
- ② 参考 `resty-http` 官方 wiki 说明，我们可以知道 request_uri 函数完成了连接池、HTTP 请求等一系列动作。

题外话，为什么这么简单的方法我们还要求助外部开源组件呢？其实我也觉得这个功能太基础了，真的应该集成到 OpenResty 官方包里面，只不过目前官方默认包里还没有。

如果你的内部请求比较少，使用 `ngx.location.capture`+`proxy_pass` 的方式还没什么问题。但如果你的请求数量比较多，或者需要频繁的修改上游地址，那么 `resty.http`就更适合你。

另外 `ngx.thread.*` 与 `resty.http` 相互结合也是很不错的玩法，推荐大家有时间研究一下。



