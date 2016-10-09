# 简单API Server框架

实现一个最最简单的数学计算：加、减、乘、除，给大家演示如何搭建简单的 API Server。

按照前面几章的写法，先来看看加法、减法示例代码：

```nginx
worker_processes  1;        #nginx worker 数量
error_log logs/error.log;   #指定错误日志文件路径
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;

        # 加法
        location /addition {
           content_by_lua_block {
                local args = ngx.req.get_uri_args()
                ngx.say(args.a + args.b)
            }
        }

        # 减法
        location /subtraction {
            content_by_lua_block {
                local args = ngx.req.get_uri_args()
                ngx.say(args.a - args.b)
            }
        }

        # 乘法
        location /multiplication {
            content_by_lua_block {
                local args = ngx.req.get_uri_args()
                ngx.say(args.a * args.b)
            }
        }

        # 除法
        location /division {
            content_by_lua_block {
                local args = ngx.req.get_uri_args()
                ngx.say(args.a / args.b)
            }
        }
    }
}
```

代码写多了一眼就可以看出来，这么简单的加减乘除，居然写了这么长，而且还要对每个 API 都写一个 location ，作为有追求的人士，怎能容忍这种代码风格？

* 首先是需要把这些 location 合并；
* 其次是这些接口的实现放到独立文件中，保持 nginx 配置文件的简洁；

基于这两点要求，可以改成下面的版本，看上去有那么几分模样的样子：

> nginx.conf 内容：

```nginx
worker_processes  1;        #nginx worker 数量
error_log logs/error.log;   #指定错误日志文件路径
events {
    worker_connections 1024;
}

http {
    # 设置默认 lua 搜索路径，添加 lua 路径
    # 此处写相对路径时，对启动 nginx 的路径有要求，必须在 nginx 目录下启动，require 找不到
    # comm.param 绝对路径当然也没问题，但是不可移植，因此应使用变量 $prefix 或 
    # ${prefix}，OR 会替换为 nginx 的 prefix path。
    
    # lua_package_path 'lua/?.lua;/blah/?.lua;;';
    lua_package_path '$prefix/lua/?.lua;/blah/?.lua;;'

    # 对于开发研究，可以对代码 cache 进行关闭，这样不必每次都重新加载 nginx。
    lua_code_cache off;

    server {
        listen 80;

        # 在代码路径中使用nginx变量
        # 注意： nginx var 的变量一定要谨慎，否则将会带来非常大的风险
        location ~ ^/api/([-_a-zA-Z0-9/]+) {
            # 准入阶段完成参数验证
            access_by_lua_file  lua/access_check.lua;

            #内容生成阶段
            content_by_lua_file lua/$1.lua;
        }
    }
}
```
> 其他文件内容：

```lua
--========== {$prefix}/lua/addition.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a + args.b)

--========== {$prefix}/lua/subtraction.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a - args.b)

--========== {$prefix}/lua/multiplication.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a * args.b)

--========== {$prefix}/lua/division.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a / args.b)
```

既然对外提供的是 API Server，作为一个服务端程序员，怎么可以容忍输入参数不检查呢？万一对方送过来的不是数字或者为空，这些都要过滤掉嘛。参数检查过滤的方法是统一，在这几个 API 中如何共享这个方法呢？这时候就需要 Lua 模块来完成了。

* 使用统一的公共模块，完成参数验证；
* 验证入口最好也统一，不要分散在不同地方；

> nginx.conf 内容：

```nginx
worker_processes  1;        #nginx worker 数量
error_log logs/error.log;   #指定错误日志文件路径
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;

        # 在代码路径中使用nginx变量
        # 注意： nginx var 的变量一定要谨慎，否则将会带来非常大的风险
        location ~ ^/api/([-_a-zA-Z0-9/]+) {
            access_by_lua_file  lua/access_check.lua;
            content_by_lua_file lua/$1.lua;
        }
    }
}
```

> 新增文件内容：

```lua
--========== {$prefix}/lua/comm/param.lua
local _M = {}

-- 对输入参数逐个进行校验，只要有一个不是数字类型，则返回 false
function _M.is_number(...)
    local arg = {...}

    local num
    for _,v in ipairs(arg) do
        num = tonumber(v)
        if nil == num then
            return false
        end
    end

    return true
end

return _M

--========== {$prefix}/lua/access_check.lua
local param= require("comm.param")
local args = ngx.req.get_uri_args()

if not param.is_number(args.a, args.b) then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end
```

看看curl测试结果吧：

```shell
$  nginx  curl '127.0.0.1:80/api/addition?a=1'
<html>
<head><title>400 Bad Request</title></head>
<body bgcolor="white">
<center><h1>400 Bad Request</h1></center>
<hr><center>openresty/1.9.3.1</center>
</body>
</html>
$  nginx  curl '127.0.0.1:80/api/addition?a=1&b=3'
4
```

基本是按照预期执行的。参数不全、错误时，会提示400错误。正常处理，可以返回预期结果。

来整体看一下目前的目录关系：

```
.
├── conf
│   ├── nginx.conf
├── logs
│   ├── error.log
│   └── nginx.pid
├── lua
│   ├── access_check.lua
│   ├── addition.lua
│   ├── subtraction.lua
│   ├── multiplication.lua
│   ├── division.lua
│   └── comm
│       └── param.lua
└── sbin
    └── nginx
```

怎么样，有点 magic 的味道不？其实你的接口越是规范，有固定规律可寻，那么 OpenResty 就总是很容易能找到适合你的位置。当然这里你也可以把 `access_check.lua` 内容分别复制到加、减、乘、除实现的四个 Lua 文件中，肯定也是能用的。这里只是为了给大家提供更多的玩法，需要的时候可以有更多的选择。

本章目的是搭建一个简单API Server，记住这绝对不是终极版本。这里面还有很多需要进一步去考虑的地方，但是作为最基本的框架已经有了。
