#动态限速

> 内容来源于openresty讨论组，点击[这里](https://groups.google.com/forum/#!forum/openresty)

在我们的应用场景中，有大量的限制并发、下载传输速率这类要求。突发性的网络峰值会对企业用户的网络环境带来难以预计的网络灾难。

nginx示例配置：
```
location /download_internal/ {
    internal;
    send_timeout 10s;
    limit_conn perserver 100;
    limit_rate 0k;

    chunked_transfer_encoding off;
    default_type application/octet-stream;

    alias ../download/;
}
```

我们从一开始，就想把速度值做成变量，但是发现limit_rate不接受变量。我们就临时的修改配置文件限速值，然后给nginx信号做reload。只是没想到这一临时，我们就用了一年多。

直到刚刚，讨论组有人问起网络限速如何实现的问题，春哥给出了大家都喜欢的办法：

> 地址：https://groups.google.com/forum/#!topic/openresty/aespbrRvWOU

```
可以在 Lua 里面（比如 access_by_lua 里面）动态读取当前的 URL 参数，然后设置 nginx 的内建变量$limit_rate（在 Lua 里访问就是 ngx.var.limit_rate）。

http://nginx.org/en/docs/http/ngx_http_core_module.html#var_limit_rate 
```

改良后的限速代码：

```
location /download_internal/ {
    internal;
    send_timeout 10s;
    access_by_lua 'ngx.var.limit_rate = "300K"';

    chunked_transfer_encoding off;
    default_type application/octet-stream;

    alias ../download/;
}
```

经过测试，绝对达到要求。有了这个东东，我们就可以在lua上直接操作限速变量实时生效。再也不用之前笨拙的reload方式了。

