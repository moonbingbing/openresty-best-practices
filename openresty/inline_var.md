# 使用 Nginx 内置绑定变量

Nginx 作为一个成熟、久经考验的负载均衡软件，与其提供丰富、完整的内置变量是分不开的，它极大地增加了对 Nginx 网络行为的控制细度。这些变量大部分都是在请求进入时解析的，并把他们缓存到请求 cycle 中，方便下一次获取使用。首先来看看 Nginx 对外都开放了那些 API 。

参看下表：

|名称|说明|
|----|------|
|$arg_name                  |请求中的 name 参数|
|$args                      |请求中的参数|
|$binary_remote_addr        |远程地址的二进制表示|
|$body_bytes_sent           |已发送的消息体字节数|
|$content_length            |HTTP 请求信息里的"Content-Length"|
|$content_type              |请求信息里的"Content-Type"|
|$document_root             |针对当前请求的根路径设置值|
|$document_uri              |与 $uri 相同，比如 /test2/test.php|
|$host                      |请求信息中的"Host"，如果请求中没有 Host 行，则等于设置的服务器名|
|$hostname                  |机器名使用 gethostname 系统调用的值|
|$http_cookie               |cookie 信息|
|$http_referer              |引用地址|
|$http_user_agent           |客户端代理信息|
|$http_via                  |最后一个访问服务器的 IP 地址|
|$http_x_forwarded_for      |相当于网络访问路径|
|$is_args                   |如果请求行带有参数，返回“?”，否则返回空字符串|
|$limit_rate                |对连接速率的限制|
|$nginx_version             |当前运行的 Nginx 版本号|
|$pid                       |worker 进程的 PID|
|$query_string              |与 $args 相同|
|$realpath_root             |按 `root` 指令或 `alias` 指令算出的当前请求的绝对路径。其中的符号链接都会解析成真实文件路径|
|$remote_addr               |客户端 IP 地址|
|$remote_port               |客户端端口号|
|$remote_user               |客户端用户名，认证用|
|$request                   |用户请求|
|$request_body              |这个变量（0.7.58+）包含请求的主要信息。<br>在使用 `proxy_pass` 或 `fastcgi_pass` 指令的 location 中比较有意义|
|$request_body_file         |客户端请求主体信息的临时文件名|
|$request_completion        |如果请求成功，设为"OK"；<br>如果请求未完成或者不是一系列请求中最后一部分，则设为空|
|$request_filename          |当前请求的文件路径名，比如 /opt/nginx/www/test.php|
|$request_method            |请求的方法，比如"GET"、"POST"等|
|$request_uri               |请求的 URI，带参数|
|$scheme                    |所用的协议，比如 http 或者是 https|
|$server_addr               |服务器地址，如果没有用 `listen` 指明服务器地址，使用这个变量将发起一次系统调用以取得地址(造成资源浪费)|
|$server_name                |请求到达的服务器名|
|$server_port                |请求到达的服务器端口号|
|$server_protocol            |请求的协议版本，"HTTP/1.0"或"HTTP/1.1"|
|$uri                        |请求的 URI，可能和最初的值有不同，比如经过重定向之类的|

其实这还不是全部，Nginx 在不停迭代更新是一个原因，还有一个是有些变量太冷门，借助它们，会有很多玩法。

首先，在 OpenResty 中如何引用这些变量呢？参考 [ngx.var.VARIABLE](https://github.com/openresty/lua-nginx-module#ngxvarvariable) 小节。

利用这些内置变量，来做一个简单的数学求和运算例子：

```nginx
server {
    listen    80;
    server_name  localhost;

    location /sum {
        # 处理业务
       content_by_lua_block {
            local a = tonumber(ngx.var.arg_a) or 0
            local b = tonumber(ngx.var.arg_b) or 0
            ngx.say("sum: ", a + b )
        }
    }
}
```

验证一下：

```shell
➜  ~  curl 'http://127.0.0.1/sum?a=11&b=12'
sum: 23
```

也许你笑了，这个 API 太简单没有实际意义。我们做个简易防火墙，看看如何开始玩耍。

参看下面示例代码：

```nginx
server {
    listen    80;
    server_name  localhost;

    location /sum {
        # 使用access阶段完成准入阶段处理
        access_by_lua_block {
            local black_ips = {["127.0.0.1"]=true}

            local ip = ngx.var.remote_addr
            if true == black_ips[ip] then
                ngx.exit(ngx.HTTP_FORBIDDEN)
            end
        };

        #处理业务
       content_by_lua_block {
            local a = tonumber(ngx.var.arg_a) or 0
            local b = tonumber(ngx.var.arg_b) or 0
            ngx.say("sum:", a + b )
        }
    }
}
```

运行测试：

```shell
➜  ~  curl '192.168.1.104/sum?a=11&b=12'
sum:23
➜  ~
➜  ~
➜  ~  curl '127.0.0.1/sum?a=11&b=12'
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>openresty/1.9.3.1</center>
</body>
</html>
```

通过测试结果看到，提取了终端的 IP 地址后进行限制。扩充一下，就可以支持 IP 地址段，如果再与系统 `iptables` 进行配合，那么就足以达到软防火墙的目的。

目前为止，所有的例子都是对 Nginx 内置变量的获取，是否可以对其进行设置呢？其实 **大多数内容都是不允许写入的**，例如刚刚的终端 IP 地址，在请求中是不允许对其进行更新的。

对于可写的变量中的 `limit_rate`，值得一提，它能完成传输速率限制，并且它的影响是 **单个请求** 级别。

参看下面示例：

```nginx
location /download {
    access_by_lua_block {
        ngx.var.limit_rate = 1000
    };
}
```

下载测试：

```shell
➜  ~  wget '127.0.0.1/download/1.cab'
--2015-09-13 13:59:51--  http://127.0.0.1/download/1.cab
Connecting to 127.0.0.1... connected.
HTTP request sent, awaiting response... 200 OK
Length: 135802 (133K) [application/octet-stream]
Saving to: '1.cab'

1.cab                6%[===>             ]   8.00K  1.01KB/s   eta 1m 53s
```
