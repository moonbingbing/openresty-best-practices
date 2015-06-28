# 执行的几个阶段

首先我们先做个测试：
```
location /mixed {
    set_by_lua $a 'ngx.log(ngx.ERR, "set_by_lua")';
    rewrite_by_lua 'ngx.log(ngx.ERR, "rewrite_by_lua")';
    access_by_lua 'ngx.log(ngx.ERR, "access_by_lua")';
    header_filter_by_lua 'ngx.log(ngx.ERR, "header_filter_by_lua")';
    body_filter_by_lua 'ngx.log(ngx.ERR, "body_filter_by_lua")';
    log_by_lua 'ngx.log(ngx.ERR, "log_by_lua")';
    content_by_lua 'ngx.log(ngx.ERR, "content_by_lua")';
}
```

执行结果日志(截取了一下)：
```
set_by_lua
rewrite_by_lua
access_by_lua
content_by_lua
header_filter_by_lua
body_filter_by_lua
log_by_lua
```

这几个阶段的存在，应该是openresty不同于其他多数web server编程的最明显特征了。由于nginx把一个回话分成了很多阶段，这样第三方模块就可以根据自己行为，挂载到不同阶段进行处理达到目的。

这样我们就可以根据我们的需要，在不同的阶段直接完成大部分典型处理了。
1. set_by_lua: 流程分之处理判断变量初始化
2. rewrite_by_lua: 转发、重定向、缓存等功能(例如特定请求代理到外网)
3. access_by_lua: IP准入、接口权限等情况集中处理(例如配合iptable完成简单防火墙)
4. content_by_lua: 内容生成
5. header_filter_by_lua: 应答HTTP过滤处理(例如添加头部信息)
6. body_filter_by_lua: 应答BODY过滤处理(例如完成应答内容统一成大写)
7. log_by_lua: 回话完成后本地异步完成日志记录(日志可以记录在本地，还可以同步到其他机器)

实际上我们只使用其中一个阶段content_by_lua，可以完成所有的处理。但这样做，会让我们的代码比较臃肿，越到后期越发难以维护。把我们的逻辑放在不同阶段，分工明确，代码独立，并且可以完成很多有意思的东西。

列举360企业版的一个例子：
在天擎6项目中，我们的终端API都是由Openresty框架完成。内容处理部分都是在content_by_lua阶段完成，第一版本API接口开发都是基于明文。为了传输体积、安全等要求，我们设计了支持压缩、加密的密文协议(上下行)，痛点就来了，我们要更改所有API的入口、出口么？

最后我们是在access_by_lua完成密文协议解码，body_filter_by_lua完成应答内容编码。如此一来世界都宁静了，我们没有更改已实现功能的一行代码，只是利用ngx-lua的阶段处理特性，非常优雅的解决了这个问题。

前两天看到春哥的微博，里面说到github的某个应用里面也使用了openresty做了一些东西。发现他们也是利用阶段特性+lua脚本处理了很多用户证书方面的东东。最终在性能、稳定性都十分让人满意。使用者选型很准，不匮是github的工程师。

不同的阶段，有不同的处理行为，这是openresty的一大特色。学会他，适应他，会给你打开新的一扇门。这些东西不是openresty自身所创，而是nginx c module对外开放的处理阶段。理解了他，也能更好的理解nginx的设计思维。
