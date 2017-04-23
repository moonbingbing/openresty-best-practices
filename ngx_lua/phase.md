# 执行阶段概念

`Nginx` 处理一个请求，它的处理流程请参考下图：

![nginx_internet_request](../images/step.png)

我们 OpenResty 做个测试，示例代码如下：
```
location /mixed {
    set_by_lua_block $a {
        ngx.log(ngx.ERR, "set_by_lua*")
    }
    rewrite_by_lua_block {
        ngx.log(ngx.ERR, "rewrite_by_lua*")
    }
    access_by_lua_block {
        ngx.log(ngx.ERR, "access_by_lua*")
    }
    content_by_lua_block {
        ngx.log(ngx.ERR, "content_by_lua*")
    }
    header_filter_by_lua_block {
        ngx.log(ngx.ERR, "header_filter_by_lua*")
    }
    body_filter_by_lua_block {
        ngx.log(ngx.ERR, "body_filter_by_lua*")
    }
    log_by_lua_block {
        ngx.log(ngx.ERR, "log_by_lua*")
    }
}
```


执行结果日志(截取了一下)：

```
set_by_lua*
rewrite_by_lua*
access_by_lua*
content_by_lua*
header_filter_by_lua*
body_filter_by_lua*
log_by_lua*
```

这几个阶段的存在，应该是 OpenResty 不同于其他多数 Web server 编程的最明显特征了。由于 Nginx 把一个请求分成了很多阶段，这样第三方模块就可以根据自己行为，挂载到不同阶段进行处理达到目的。

这样我们就可以根据我们的需要，在不同的阶段直接完成大部分典型处理了。

* `set_by_lua*`: 流程分支处理判断变量初始化
* `rewrite_by_lua*`: 转发、重定向、缓存等功能(例如特定请求代理到外网)
* `access_by_lua*`: IP 准入、接口权限等情况集中处理(例如配合 iptable 完成简单防火墙)
* `content_by_lua*`: 内容生成
* `header_filter_by_lua*`: 响应头部过滤处理(例如添加头部信息)
* `body_filter_by_lua*`: 响应体过滤处理(例如完成应答内容统一成大写)
* `log_by_lua*`: 会话完成后本地异步完成日志记录(日志可以记录在本地，还可以同步到其他机器)

实际上我们只使用其中一个阶段 `content_by_lua*`，也可以完成所有的处理。但这样做，会让我们的代码比较臃肿，越到后期越发难以维护。把我们的逻辑放在不同阶段，分工明确，代码独立，后期发力可以有很多有意思的玩法。

举一个例子，如果在最开始的开发中，请求体和响应体都是通过 HTTP 明文传输，后面需要使用 aes 加密，利用不同的执行阶段，我们可以非常简单的实现：

```
# 明文协议版本
location /mixed {
    content_by_lua_file ...;       # 请求处理
}

# 加密协议版本
location /mixed {
    access_by_lua_file ...;        # 请求加密解码
    content_by_lua_file ...;       # 请求处理，不需要关心通信协议
    body_filter_by_lua_file ...;   # 应答加密编码
}
```

内容处理部分都是在 `content_by_lua*` 阶段完成，第一版本 API 接口开发都是基于明文。为了传输体积、安全等要求，我们设计了支持压缩、加密的密文协议(上下行)，痛点就来了，我们要更改所有 API 的入口、出口么？

最后我们是在 `access_by_lua*` 完成密文协议解码，`body_filter_by_lua*` 完成应答加密编码。如此一来世界都宁静了，我们没有更改已实现功能的一行代码，只是利用 OpenResty 的阶段处理特性，非常优雅的解决了这个问题。

前两天看到春哥的微博，里面说到 GitHub 的某个应用里面也使用了 OpenResty 做了一些东西。发现他们也是利用阶段特性 + Lua 脚本处理了很多用户证书方面的东东。最终在性能、稳定性都十分让人满意。使用者选型很准，不愧是 GitHub 的工程师。

不同的阶段，有不同的处理行为，这是 OpenResty 的一大特色。学会他，适应他，会给你打开新的一扇门。这些东西不是 OpenResty 自身所创，而是 Nginx C module 对外开放的处理阶段。理解了他，也能更好的理解 Nginx 的设计思维。
