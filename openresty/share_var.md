# 不同阶段共享变量

在 OpenResty 的体系中，可以通过共享内存的方式完成不同工作进程的数据共享，可以通过 Lua 模块方式完成单个进程内不同请求的数据共享。如何完成单个请求内不同阶段的数据共享呢？最典型的例子，估计就是在 log 阶段记录一些请求的特殊变量。

ngx.ctx 表就是为了解决这类问题而设计的。参考下面例子：

```nginx
location /test {
    rewrite_by_lua_block {
        ngx.ctx.foo = 76
    }
    access_by_lua_block {
        ngx.ctx.foo = ngx.ctx.foo + 3
    }
    content_by_lua_block {
        ngx.say(ngx.ctx.foo)
    }
}
```
#### ngx.ctx 表的性质
- 首先 ngx.ctx 是一个表，所以我们可以对它添加、修改。
- 它用来存储基于请求的 Lua 环境数据，其生存周期与当前请求相同 (类似 Nginx 变量)。
- 它有一个 **最重要的特性**：单个请求内的 rewrite (重写)，access (访问)，和 content (内容) 等各处理阶段是保持一致的。
- 额外注意，每个请求，包括子请求，都有一份自己的 ngx.ctx 表。例如：

```nginx
location /sub {
    content_by_lua_block {
        ngx.say("sub pre: ", ngx.ctx.blah)
        ngx.ctx.blah = 32
        ngx.say("sub post: ", ngx.ctx.blah)
    }
}

location /main {
    content_by_lua_block {
        ngx.ctx.blah = 73
        ngx.say("main pre: ", ngx.ctx.blah)

        local res = ngx.location.capture("/sub")
        ngx.print(res.body)

        ngx.say("main post: ", ngx.ctx.blah)
    }
}
```

访问 GET /main 输出

```shell
main pre: 73
sub pre: nil
sub post: 32
main post: 73
```

任意数据值，包括 Lua 闭包与嵌套表，都可以被插入这个“魔法”表，也允许注册自定义元方法。

也可以将 ngx.ctx 覆盖为一个新 Lua 表，例如，

```lua
ngx.ctx = { foo = 32, bar = 54 }
```

ngx.ctx 表查询需要相对昂贵的元方法调用，这比通过用户自己的函数参数直接传递基于请求的数据要慢得多。所以不要为了节约用户函数参数而滥用此 API，因为它可能对性能有明显影响。

由于 ngx.ctx 保存的是指定请求资源，所以这个变量是不能直接共享给其他请求使用的。
