# 获取Nginx内置绑定变量

|名称|说明|
|----|------|
|$arg_name                  |请求中的name参数|
|$args                      |请求中的参数|
|$binary_remote_addr        |远程地址的二进制表示|
|$body_bytes_sent           |已发送的消息体字节数|
|$content_length            |HTTP请求信息里的"Content-Length"|
|$content_type              |请求信息里的"Content-Type"|
|$document_root             |针对当前请求的根路径设置值|
|$document_uri              |与$uri相同; 比如 /test1/test2/test.php|
|$host                      |请求信息中的"Host"，如果请求中没有Host行，则等于设置的服务器名|
|$hostname                  |机器名使用 gethostname系统调用的值|
|$http_cookie               |cookie 信息|
|$http_referer              |引用地址|
|$http_user_agent           |客户端代理信息|
|$http_via                  |最后一个访问服务器的Ip地址。|
|$http_x_forwarded_for      |相当于网络访问路径|
|$is_args                   |如果请求行带有参数，返回“?”，否则返回空字符串|
|$limit_rate                |对连接速率的限制|
|$nginx_version             |当前运行的nginx版本号|
|$pid                       |worker进程的PID|
|$query_string              |与$args相同|
|$realpath_root             |按root指令或alias指令算出的当前请求的绝对路径。其中的符号链接都会解析成真是文件路径|
|$remote_addr               |客户端IP地址|
|$remote_port               |客户端端口号|
|$remote_user               |客户端用户名，认证用|
|$request                   |用户请求|
|$request_body              |这个变量（0.7.58+）包含请求的主要信息。在使用proxy_pass或fastcgi_pass指令的location中比较有意义|
|$request_body_file         |客户端请求主体信息的临时文件名|
|$request_completion        |如果请求成功，设为"OK"；如果请求未完成或者不是一系列请求中最后一部分则设为空|
|$request_filename          |当前请求的文件路径名，比如D:\nginx/html/test1/test2/test.php|
|$request_method            |请求的方法，比如"GET"、"POST"等|
|$request_uri               |请求的URI，带参数; 比如http://localhost:88/test1/|test2/test.php|
|$scheme                    |所用的协议，比如http或者是https|
|$sent_http_transfer_encoding        ||       
|$server_addr               |服务器地址，如果没有用listen指明服务器地址，使用这个变量将发起一次系统调用以取得地址(造成资源浪费)|
|$server_name                |请求到达的服务器名|
|$server_port                |请求到达的服务器端口号|
|$server_protocol            |请求的协议版本，"HTTP/1.0"或"HTTP/1.1"|
|$uri                        |请求的URI，可能和最初的值有不同，比如经过重定向之类的|

```
```


<!-- waiting todo complete -->

