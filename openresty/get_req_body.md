# 获取请求 body

在 Nginx 的典型应用场景中，几乎都是只读取 HTTP 头即可，例如负载均衡、正反向代理等场景。但是对于 API Server 或者 Web Application ，对 body 可以说就比较敏感了。由于 OpenResty 基于 Nginx ，所以天然的对请求 body 的读取细节与其他成熟 Web 框架有些不同。

### 最简单的 “Hello \*\*\*\*”

我们先来构造最简单的一个请求，POST 一个名字给服务端，服务端应答一个 “Hello \*\*\*\*”。

```nginx
http {
    server {
        listen    80;

        location /test {
            content_by_lua_block {
                local data = ngx.req.get_body_data()
                ngx.say("hello ", data)
            }
        }
    }
}
```

测试结果：

```shell
➜  ~  curl 127.0.0.1/test -d jack
hello nil
```

大家可以看到 data 部分获取为空，如果你熟悉其他 web 开发框架，估计立刻就觉得 OpenResty 弱爆了。查阅一下官方 wiki 我们很快知道，原来我们还需要添加指令 lua_need_request_body 。究其原因，主要是 Nginx 诞生之初主要是为了解决负载均衡情况，而这种情况，是不需要读取 body 就可以决定负载策略的，所以这个点对于 API Server 和 Web Application 开发的同学有点怪。参看下面的新例子：

```nginx
http {
    server {
        listen    80;

        # 默认读取 body
        lua_need_request_body on;

        location /test {
            content_by_lua_block {
                local data = ngx.req.get_body_data()
                ngx.say("hello ", data)
            }
        }
    }
}
```

再次测试，符合我们预期：

```shell
➜  ~  curl 127.0.0.1/test -d jack
hello jack
```

如果你只是某个接口需要读取 body（并非全局行为），那么这时候也可以显示调用 ngx.req.read_body() 接口，参看下面示例：

```nginx
http {
    server {
        listen    80;

        location /test {
            content_by_lua_block {
                ngx.req.read_body()
                local data = ngx.req.get_body_data()
                ngx.say("hello ", data)
            }
        }
    }
}
```

### body 偶尔读取不到？

ngx.req.get_body_data() 读请求体，会偶尔出现读取不到直接返回 nil 的情况。

如果请求体尚未被读取，请先调用 [ngx.req.read_body](#ngxreqread_body) (或打开 [lua_need_request_body](#lua_need_request_body) 选项强制本模块读取请求体，此方法不推荐）。

如果请求体已经被存入临时文件，请使用 [ngx.req.get_body_file](#ngxreqget_body_file) 函数代替。

如需要强制在内存中保存请求体，请设置 [client_body_buffer_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_buffer_size) 和 [client_max_body_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size) 为同样大小。

参考下面代码：

```nginx
http {
    server {
        listen    80;

        # 强制请求 body 到临时文件中（仅仅为了演示）
        client_body_in_file_only on;

        location /test {
            content_by_lua_block {
                function getFile(file_name)
                    local f = assert(io.open(file_name, 'r'))
                    local string = f:read("*all")
                    f:close()
                    return string
                end

                ngx.req.read_body()
                local data = ngx.req.get_body_data()
                if nil == data then
                    local file_name = ngx.req.get_body_file()
                    ngx.say(">> temp file: ", file_name)
                    if file_name then
                        data = getFile(file_name)
                    end
                end

                ngx.say("hello ", data)
            }
        }
    }
}
```

测试结果：

```nginx
➜  ~  curl 127.0.0.1/test -d jack
>> temp file: /Users/rain/Downloads/nginx/client_body_temp/0000000018
hello jack
```

由于 Nginx 是为了解决负载均衡场景诞生的，所以它默认是不读取 body 的行为，会对 API Server 和 Web Application 场景造成一些影响。根据需要正确读取、丢弃 body 对 OpenResty 开发是至关重要的。








