# Nginx内置变量

|名称|版本|说明|
|----|------|------|
|$args                      |1.0.8|请求中的参数|
|$binary_remote_addr        |1.0.8|远程地址的二进制表示|
|$body_bytes_sent           |1.0.8|已发送的消息体字节数|
|$content_length            |1.0.8|HTTP请求信息里的"Content-Length"|
|$content_type              |1.0.8|请求信息里的"Content-Type"|
|$document_root             |1.0.8|针对当前请求的根路径设置值|
|$document_uri              |1.0.8|与$uri相同; 比如 /test1/test2/test.php|
|$host                      |1.0.8|请求信息中的"Host"，如果请求中没有Host行，则等于设置的服务器名|
|$hostname                  |1.0.8||
|$http_cookie               |1.0.8|cookie 信息|
|$http_post                 |1.0.8||
|$http_referer              |1.0.8|引用地址|
|$http_user_agent           |1.0.8|客户端代理信息|
|$http_via                  |1.0.8|最后一个访问服务器的Ip地址。|
|$http_x_forwarded_for      |1.0.8|相当于网络访问路径|
|$is_args                   |1.0.8||
|$limit_rate                |1.0.8|对连接速率的限制|
|$nginx_version             |1.0.8||
|$pid                       |1.0.8||
|$query_string              |1.0.8|与$args相同|
|$realpath_root             |1.0.8||
|$remote_addr               |1.0.8|客户端地址|
|$remote_port               |1.0.8|客户端端口号|
|$remote_user               |1.0.8|客户端用户名，认证用|
|$request                   |1.0.8|用户请求|
|$request_body              |1.0.8||
|$request_body_file         |1.0.8|发往后端的本地文件名称|
|$request_completion        |1.0.8||
|$request_filename          |1.0.8|当前请求的文件路径名，比如D:\nginx/html/test1/test2/test.php|
|$request_method            |1.0.8|请求的方法，比如"GET"、"POST"等;|
|$request_uri               |1.0.8|请求的URI，带参数; 比如http://localhost:88/test1/|test2/test.php|
|$scheme                    |1.0.8|所用的协议，比如http或者是https|
|$sent_http_cache_control   |1.0.8||
|$sent_http_connection      |1.0.8||
|$sent_http_content_length  |1.0.8||
|$sent_http_content_type    |1.0.8||
|$sent_http_keep_alive      |1.0.8||
|$sent_http_last_modified   |1.0.8||
|$sent_http_location        |1.0.8||
|$sent_http_transfer_encoding        |1.0.8||       
|$server_addr               |1.0.8|服务器地址，如果没有用listen指明服务器地址，使用这个变量将发起一次系统调用以取得地址(造成资源浪费)|
|$server_name                |1.0.8|请求到达的服务器名|
|$server_port                |1.0.8|请求到达的服务器端口号|
|$server_protocol            |1.0.8|请求的协议版本，"HTTP/1.0"或"HTTP/1.1"|
|$uri                        |1.0.8|请求的URI，可能和最初的值有不同，比如经过重定向之类的|

<!-- waiting todo complete -->

