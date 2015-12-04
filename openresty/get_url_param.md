# 获取 uri 参数

上一章节，主要介绍了一下如何使用不同 location 进行协作，这些 location 之间进行柔和，往往都是要需要参数的二次调整。如何正确获取传递参数、设置参数，就是你的必修课了。本章目的是给出在 ngx_lua 的世界中，我们如何正确获取、设置 uri 参数。

### 获取请求 uri 参数
首先看一下官方 API 文档，获取一个 uri 有两个方法：`ngx.req.get_uri_args`、`ngx.req.get_post_args`，二者主要的区别是参数来源有区别。

参考下面例子：

```nginx
server {
   listen       8866;
   server_name  localhost;

   location /test {
       content_by_lua_block {
           local arg = ngx.req.get_uri_args()
           for k,v in pairs(arg) do
               ngx.say("[GET]  key:", k, " v:", v)
           end

           ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
           local arg = ngx.req.get_post_args()
           for k,v in pairs(arg) do
               ngx.say("[POST] key:", k, " v:", v)
           end
       }
   }
}
```

输出结果：

```shell
➜  ~  curl '127.0.0.1:8866/test?a=1&b=2%26' -d 'c=3&d=4%26'
[GET]  key:b v:2&
[GET]  key:a v:1
[POST] key:d v:4&
[POST] key:c v:3
```

从这个例子中，我们可以很明显看到两个函数 `ngx.req.get_uri_args`、`ngx.req.get_post_args` 获取数据来源是有明显区别的，前者来自 uri 请求参数，而后者来自 post 请求内容。

### 传递请求 uri 参数

当我们可以获取到请求参数，自然是需要这些参数来完成的业务控制目的。大家都知道，URI 内容传递过程中是需要调用 ngx.encode_args 进行规则转义。新写一个 location，用它来向上一个例子发起内部子请求。

参看下面例子：

```nignx
server {
   listen       8866;
   server_name  localhost;

   location /test2 {
       content_by_lua_block {
           local res = ngx.location.capture(
                    '/test',
                    { 
                       method = ngx.HTTP_POST, 
                       args = ngx.encode_args{a=1, b='2&'},
                       body = ngx.encode_args{c=3, d='4&'}
                   }
                )
           ngx.say(res.body)
       }
   }
}
```

输出结果：

```shell
➜  ~  curl '127.0.0.1:8866/test2'
[GET]  key:b v:2&
[GET]  key:a v:1
[POST] key:d v:4&
[POST] key:c v:3
```

与我们预期是一样的。

如果这里不调用`ngx.encode_args` ，这里可能就会比较丑了，看下面例子：

```lua
local res = ngx.location.capture('/test',
         { 
            method = ngx.HTTP_POST, 
            args = 'a=1&b=2%26',  -- 注意这里的 %26 ,代表的是 & 字符
            body = 'c=3&d=4%26'
        }
     )
ngx.say(res.body)
```


