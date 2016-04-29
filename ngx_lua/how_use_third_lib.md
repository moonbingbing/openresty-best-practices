# 如何引用第三方resty库

openresty引用第三方resty库非常简单，只需要将相应的文件copy到resty目录下即可

我们以resty.http(https://github.com/pintsized/lua-resty-http)库为例

只要将lua-resty-http/lib/resty/目录下的http.lua和http_headers.lua两个文件copy到/usr/local/openresty/lualib/resty目录下即可(假设你的openresty安装目录为/usr/local/openresty).

验证代码如下：

```

server {
    location /baidu {
        content_by_lua '

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
访问/baidu,如果出现的是百度的首页，说明你配置成功了
