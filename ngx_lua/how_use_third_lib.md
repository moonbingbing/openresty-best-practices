# 如何引用第三方 resty 库

OpenResty 引用第三方 resty 库非常简单，只需要将相应的文件拷贝到 resty 目录下即可。

我们以 `resty.http` ( [pintsized/lua-resty-http](https://github.com/pintsized/lua-resty-http)) 库为例。

只要将 `lua-resty-http/lib/resty/` 目录下的 http.lua 和 http_headers.lua 两个文件拷贝到 `/usr/local/openresty/lualib/resty` 目录下即可(假设你的 OpenResty 安装目录为 `/usr/local/openresty`)。

验证代码如下：

```nginx

server {

    listen       8080 default_server;
    server_name  _;

    resolver 8.8.8.8;

    location /baidu {
        content_by_lua_block {
            local http = require "resty.http"
            local httpc = http.new()
            local res, err = httpc:request_uri("http://www.baidu.com")
            if res.status == ngx.HTTP_OK then
                ngx.say(res.body)
            else
                ngx.exit(res.status)
            end
        }
    }
}
```

访问 [http://127.0.0.1:8080/baidu](http://127.0.0.1:8080/baidu) , 如果出现的是百度的首页，说明你配置成功了。

当然这里也可以自定义 [`lua_package_path`](https://github.com/iresty/nginx-lua-module-zh-wiki#lua_package_path) 指定 Lua 的查找路径，这样就可以把第三方代码放到相应的位置下，这么做更加方便归类文件，明确什么类型的文件放到什么地方（比如：公共文件、业务文件）。

