# API 的设计

OpenResty，最擅长的应用场景之一就是 API Server。如果我们只有简单的几个 API 出口、入口，那么我们可以相对随意简单一些。

> 举例几个简单API接口输出：

```nginx
server {
    listen       80;
    server_name  localhost;

    location /app/set {
        content_by_lua_block {
             ngx.say('set data')
        }
    }

    location /app/get {
        content_by_lua_block {
            ngx.say('get data')
        }
    }

    location /app/del {
        content_by_lua_block {
            ngx.say('del data')
        }
    }
}
```

当你的 API Server 接口服务比较多，那么上面的方法显然不适合我们（太啰嗦）。这里推荐一下 REST 风格。

### 什么是 REST

从资源的角度来观察整个网络，分布在各处的资源由 URI 确定，而客户端的应用通过 URI 来获取资源的表示方式。获得这些表徵致使这些应用程序转变了其状态。随着不断获取资源的表示方式，客户端应用不断地在转变着其状态，所谓表述性状态转移（Representational State Transfer）。

这一观点不是凭空臆造的，而是通过观察当前 Web 互联网的运作方式而抽象出来的。Roy Fielding 认为，

> 设计良好的网络应用表现为一系列的网页，这些网页可以看作的虚拟的状态机，用户选择这些链接
导致下一网页传输到用户端展现给使用的人，而这正代表了状态的转变。

##### REST 是设计风格而不是标准。

REST 通常基于使用 HTTP，URI，和 XML 以及 HTML 这些现有的广泛流行的协议和标准。

- 资源由 URI 来指定。
- 对资源的操作包括获取、创建、修改和删除，这些操作正好对应 HTTP 协议提供的 GET、POST、PUT 和 DELETE 方法。
- 通过操作资源的表现形式来操作资源。
- 资源的表现形式可以是 XML、HTML、JSON，当然也可以是任何其他的格式。这取决于读者是机器还是人，是消费 Web 服务的客户软件还是 Web 浏览器。

##### REST 的要求：

- 客户端和服务器结构
- 连接协议具有无状态性
- 能够利用 Cache 机制提升性能
- 层次化的系统

### REST 使用举例

按照 REST 的风格引导，我们有关数据的 API Server 就可以变成这样。

```nginx
server {
    listen       80;
    server_name  localhost;

    location /app/task01 {
        content_by_lua_block {
            ngx.say(ngx.req.get_method() .. ' task01')
        }
    }
    location /app/task02 {
        content_by_lua_block {
            ngx.say(ngx.req.get_method() .. ' task02')
        }
    }
    location /app/task03 {
        content_by_lua_block {
            ngx.say(ngx.req.get_method() .. ' task03')
        }
    }
}
```

对于 `/app/task01` 接口，这时候我们可以用下面的方法，完成对应的方法调用。

```shell
# curl -X GET http://127.0.0.1/app/task01
# curl -X PUT http://127.0.0.1/app/task01
# curl -X DELETE http://127.0.0.1/app/task01
```

### 还有办法压缩不？

上一个章节，如果 task 类型非常多，那么后面这个配置依然会随着业务调整而调整。其实每个程序员都有一定的洁癖，是否可以以后直接写业务，而不用每次都修改主配置，万一改错了，服务就起不来了。

引用一下 HttpLuaModule 官方示例代码。

```nginx
# use nginx var in code path
# WARNING: contents in nginx var must be carefully filtered,
# otherwise there'll be great security risk!
location ~ ^/app/([-_a-zA-Z0-9/]+) {
    set $path $1;
    content_by_lua_file /path/to/lua/app/root/$path.lua;
}
```

这下世界宁静了，每天写 Lua 代码的同学，再也不用每次都去修改 Nginx 主配置了。有新业务，直接开工。顺路还强制了入口文件命名规则。对于后期检查维护更容易。

### REST 风格的缺点

需要一定的学习成本，如果你的接口是暴露给运维、售后、测试等不同团队，那么他们经常不去确定当时的 `method`。当他们查看、模拟的时候，具有一定学习难度。

REST 推崇使用 HTTP 返回码来区分返回结果, 但最大的问题在于 HTTP 的错误返回码 (4xx 系列为主) 不够多，而且订得很随意。比如用 API 创建一个用户，那么错误可能有：

- 调用格式错误(一般返回 400, 405)
- 授权错误(一般返回 403)
- "运行期"错误
    - 用户名冲突
    - 用户名不合法
    - email 冲突
    - email 不合法
