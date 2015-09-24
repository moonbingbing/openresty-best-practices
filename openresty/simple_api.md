# 简单API Server框架

我们实现一个最最简单的数学计算：加、减、乘、除，给大家演示如何搭建简单的 API Server。

按照我们前面几章的写法，我们先来看看加法、减法示例代码：

```nginx
worker_processes  1;        #nginx worker 数量
error_log logs/error.log;   #指定错误日志文件路径
events {
    worker_connections 1024;
}
http {
    server {
        listen 6699;

        # 加法
        location /addition {
            content_by_lua '
                local args = ngx.req.get_uri_args()
                ngx.say(args.a + args.b)
            ';
        }

        # 减法
        location /subtraction {
            content_by_lua '
                local args = ngx.req.get_uri_args()
                ngx.say(args.a - args.b)
            ';
        }

        # 乘法
        location /multiplication {
            content_by_lua '
                local args = ngx.req.get_uri_args()
                ngx.say(args.a * args.b)
            ';
        }

        # 除法
        location /division {
            content_by_lua '
                local args = ngx.req.get_uri_args()
                ngx.say(args.a / args.b)
            ';
        }
    }
}
```

代码写多了我们一眼就可以看出来，这么简单的加减乘除，居然写了这么长，而且我们还要对每个 API 都写一个 location ，这明显是让人不爽的。如果我们的某个API接口比较冗长，这样写岂不是直接会撑爆 nginx.conf 文件。要知道即使你喜欢这样写，nginx的配置文件对字符串最大长度有限制，不能超过4K。而且代码中如果需要出现单引号等字符，都需要进行转义，这些都是比较痛苦的。

* 首先就是把这些 location 合并为一个；
* 其次是这些接口的实现放到独立文件中，保持 nginx 配置文件的简洁；

基于这两点要求，我们可以改成下面的版本，看上去有那么几分模样：

> nginx.conf 内容：

```nginx
worker_processes  1;        #nginx worker 数量
error_log logs/error.log;   #指定错误日志文件路径
events {
    worker_connections 1024;
}
http {
    server {
        listen 6699;

        # 在代码路径中使用nginx变量
        # 注意： nginx var 的变量一定要谨慎，否则将会带来非常大的风险
        location ~ ^/api/([-_a-zA-Z0-9/]+) {
            content_by_lua_file /path/to/lua/app/root/$1.lua;
        }
    }
}
```
> 其他文件内容：

```lua
--========== /path/to/lua/app/root/addition.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a + args.b)

--========== /path/to/lua/app/root/subtraction.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a - args.b)

--========== /path/to/lua/app/root/multiplication.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a * args.b)

--========== /path/to/lua/app/root/division.lua
local args = ngx.req.get_uri_args()
ngx.say(args.a / args.b)
```

既然我们对外提供的是 API Server，作为一个服务端程序员，怎么可以容忍输入参数不检查呢？万一对方送过来的不是数字或者为空，这些都要过滤掉嘛。参数检查过滤的方法是统一，在这几个 API 中如何共享这个方法呢？这时候就需要 Lua 中的模块来完成了。

* 使用统一的公共模块，完成参数验证；
* 对本示例，参数验证的方式方法是统一的，我们可以把它们集中在一处完成；

> nginx.conf 内容：

```nginx
worker_processes  1;        #nginx worker 数量
error_log logs/error.log;   #指定错误日志文件路径
events {
    worker_connections 1024;
}
http {
    server {
        listen 6699;

        # 在代码路径中使用nginx变量
        # 注意： nginx var 的变量一定要谨慎，否则将会带来非常大的风险
        location ~ ^/api/([-_a-zA-Z0-9/]+) {
            access_by_lua_file  /path/to/lua/app/root/access_check.lua;
            content_by_lua_file /path/to/lua/app/root/$1.lua;
        }
    }
}
```

> 新增文件内容：

```lua
--========== /path/to/lua/app/root/comm/param.lua
local _M = {}

-- 对输入参数逐个进行校验，只要有一个不是数字类型，则返回 false
function _M.is_number(...)
    for _,v in ipairs(arg) do
       if "number" ~= type(v) then
            return false
       end
    end

    return true
end

return _M

--========== /path/to/lua/app/root/access_check.lua
local param= require("comm.param")
local args = ngx.req.get_uri_args()

if not param.is_number(args.a, args.b) then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end
```

怎么样，有点 magic 的味道不？其实你的接口越是规范，有固定规律可寻，那么 OpenResty 就总是很容易能找到适合你的位置。当然这里你也可以把 `access_check.lua` 内容分别复制到加、减、乘、除实现的四个 Lua 文件中，肯定也是能用的。这里只是为了给大家提供更多的玩法，偶尔需要的时候我们可以有更多的选择。
