# 如何引用第三方resty库

openresty 引用第三方 resty 库非常简单，只需要将相应的文件拷贝到 resty 目录下即可

我们以 resty.http ( [https://github.com/pintsized/lua-resty-http](https://github.com/pintsized/lua-resty-http)) 库为例

只要将 lua-resty-http/lib/resty/ 目录下的 http.lua 和 http_headers.lua两个文件拷贝到 /usr/local/openresty/lualib/resty目录下即可(假设你的openresty安装目录为 /usr/local/openresty).

验证代码如下：

```

server {
    
    listen       8080 default_server;
    server_name  _;
    
    resolver 8.8.8.8;
    
    location /baidu {
        content_by_lua_block '

                            local http = require "resty.http"
                            local httpc = http.new()
                            local res, err = httpc:request_uri("http://www.baidu.com")
                            if res.status == ngx.HTTP_OK then
                                ngx.say(res.body)
                            end
                         ';
    }
}
```

访问 http://127.0.0.1:8080/baidu,如果出现的是百度的首页，说明你配置成功了
