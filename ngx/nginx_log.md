# 日志

Nginx 日志主要有两种：access_log(访问日志) 和 error_log(错误日志)。

### access_log 访问日志

access_log 主要记录客户端访问 Nginx 的每一个请求，格式可以自定义。通过 access_log 你可以得到用户地域来源、跳转来源、使用终端、某个URL访问量等相关信息。

log_format 指令用于定义日志的格式，语法: `log_format name string;` 其中 name 表示格式名称，string 表示定义的格式字符串。log_format 有一个默认的无需设置的组合日志格式。

>默认的无需设置的组合日志格式

```nginx
log_format combined '$remote_addr - $remote_user  [$time_local]  '
                    ' "$request"  $status  $body_bytes_sent  '
                    ' "$http_referer"  "$http_user_agent" ';
```

access_log 指令用来指定访问日志文件的存放路径（包含日志文件名）、格式和缓存大小，语法：`access_log path [format_name [buffer=size | off]];` 其中 path 表示访问日志存放路径，format_name 表示访问日志格式名称，buffer 表示缓存大小，off 表示关闭访问日志。

>log_format 使用事例：在 access.log 中记录客户端 IP 地址、请求状态和请求时间

```nginx
log_format myformat '$remote_addr  $status  $time_local';
access_log logs/access.log  myformat;
```

需要注意的是：log_format 配置必须放在 http 内，否则会出现警告。Nginx 进程设置的用户和组必须对日志路径有创建文件的权限，否则，会报错。

定义日志使用的字段及其作用：

|字段|作用|
|:----|:----|
|$remote_addr与$http_x_forwarded_for | 记录客户端IP地址 |
|$remote_user| 记录客户端用户名称 |
|$request| 记录请求的URI和HTTP协议 |
|$status | 记录请求状态 |
|$body_bytes_sent | 发送给客户端的字节数，不包括响应头的大小 |
|$bytes_sent| 发送给客户端的总字节数 |
|$connection | 连接的序列号 |
|$connection_requests | 当前通过一个连接获得的请求数量 |
|$msec | 日志写入时间。单位为秒，精度是毫秒 |
|$pipe | 如果请求是通过HTTP流水线(pipelined)发送，pipe值为“p”，否则为“.” |
|$http_referer | 记录从哪个页面链接访问过来的 |
|$http_user_agent | 记录客户端浏览器相关信息 |
|$request_length | 请求的长度（包括请求行，请求头和请求正文）|
|$request_time | 请求处理时间，单位为秒，精度毫秒 |
|$time_iso8601 | ISO8601标准格式下的本地时间 |
|$time_local | 记录访问时间与时区 |


## error_log 错误日志

error_log 主要记录客户端访问 Nginx 出错时的日志，格式不支持自定义。通过查看错误日志，你可以得到系统某个服务或 server 的性能瓶颈等。因此，将日志利用好，你可以得到很多有价值的信息。

error_log 指令用来指定错误日志，语法: `error_log path level`; 其中 path 表示错误日志存放路径，level 表示错误日志等级，日志等级包括 debug、info、notice、warn、error、crit，从左至右，日志详细程度逐级递减，即 debug 最详细，crit 最少，默认为 crit。

注意：`error_log off` 并不能关闭错误日志记录，此时日志信息会被写入到文件名为 off 的文件当中。如果要关闭错误日志记录，可以使用如下配置：

>Linux 系统把存储位置设置为空设备

```nginx

error_log /dev/null;

http {
    # ...
}
```

>Windows 系统把存储位置设置为空设备

```nginx

error_log nul;

http {
    # ...
}
```

另外 Linux 系统可以使用 tail 命令方便的查阅正在改变的文件,`tail -f filename`会把 filename 里最尾部的内容显示在屏幕上,并且不断刷新,使你看到最新的文件内容。Windows 系统没有这个命令，你可以在网上找到动态查看文件的工具。
