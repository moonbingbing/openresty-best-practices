# location 之间的配合

#### rewrite 指令介绍

Nginx 中 location 之间的配合，主要是通过 rewrite 指令来进行的。有这些指令会与 rewrite 指令协同使用：set、if 、return、break。rewrite 的基本规则如下：

> 语法:	rewrite regex replacement [flag];
> 上下文环境:	server, location, if

* rewrite 指令的执行流程

因为 server 区块可以有多条 rewrite 指令。当 rewrite 指令在 server 区块时，会逐代码地检查是否匹配。在检测到匹配之后，rewrite 指令在 server 区块最先执行且仅执行一次，会重定向到指明的 replacement 地址，然后判断是否被某个 location 块捕获。如果被某个 location 块捕获，则继续执行 location 块中的 rewrite 指令，执行完成之后，倘若没有用 break 等语句停止该过程的话，则会不断地重复 rewrite -> locatio ->rewrite -> location 这样的操作。这样的循环会重复 10 次，10 次之后，会返回一个 500 代码。

rewrite 指令的 flag 可以设置为 break、last、redirect、permanent。在 Nginx 的 wiki 官方文档中介绍：
* last 停止当前 rewrite 指令，并且用更改后的 URI 在配置文件中搜寻相应的 location 匹配。
* break 停止当前 rewrite 指令，但是继续执行除了 rewrite 之外的指令。
* redirect 如果 replament 不是以 "http://" 或者 "https://" 开头的话，那么返回一个 302 临时重定向。
* permanent 返回一个 301 永久重定向。


```nginx
location /download/ {
    rewrite  ^(/download/)/text1/(.*)\..*$  $1/txt1/$2.txt  last;
    rewrite  ^(/download/)/text2/(.*)\..*$  $1/txt2/$2.txt  last;
    rewrite  ^(/download/)/text3/(.*)\..*$  $1/txt3/$2.txt  last;
}
```

```nginx
location /download/ {
    rewrite  ^(/download/)/text1/(.*)\..*$  $1/txt1/$2.txt  break;
    rewrite  ^(/download/)/text2/(.*)\..*$  $1/txt2/$2.txt  break;
    rewrite  ^(/download/)/text3/(.*)\..*$  $1/txt3/$2.txt  break;
}
```
txt 文件中的信息都是：“文件名” + “：” + “文件路径”。我们用 `/download/text1/test.txt` 来向服务器发起请求。

当我们使用 last 时: 在第 2 行 rewrite 处终止, 并重试 location /download，程序陷入循环，在循环 10 次之后，返回一个 500 代码。

当我们使用 break 时: 在第 2 行 rewrite 处终止, 其结果为最终的 rewrite 地址，成功取回数据。

last 其实就相当于一个新的 url，对 Nginx 进行了一次请求，需要走一遍大多数的处理过程，最重要的是会做一次 find config，提供了一个可以转到其他 location 的配置中处理的机会，而 break 则是在一个请求处理过程中将原来的 url(包括 uri 和 args)改写之后，在继续进行后面的处理，这个重写之后的请求始终都是在同一个 location 中处理。


rewrite 指令有如下两点值得注意的细节：
1. rewrite 只对相对路径进行匹配, 不包含 hostname。
使用相对路径 rewrite 时, 会根据 HTTP header 中的 HOST 跟 Nginx 的 server_name 匹配后进行 rewrite, 如果 HOST 不匹配或者没有 HOST 信息的话则 rewrite 到 server_name 设置的第一个域名, 如果没有设置 server_name 的话, 会使用本机的 localhost 进行 rewrite。

2. 前面提到过, rewrite 的正则是不匹配 query string 的, 所以默认情况下, query string 是自动追加到 rewrite 后的地址上的, 如果不想自动追加 query string, 则在 rewrite 地址的末尾添加?。

通过 rewrite 指令的巧妙使用，还可以轻松实现“防盗链”、“禁封 IP 地址”等效果，由于不是本文的重点，待读者自己去发掘这些功能吧。

#### 公共设置

有时候，我们会遇到这样的业务需求：我们将 js 、css、图片分别保存在相同的硬盘目录下，但是我们希望对用户提供各自的对外接口。我们真正暴露给用户的，是我们希望用户看到的路径，而不是文件存储于服务器上的真实细节，可以利用 rewrite 指令向用户隐藏实际的路径信息。于此同时，如果我们为每一类文件编写一个 location 配置，增加了编码人员的负担不说，而且日后维护，只要一个地方有改动，就必须修改所有的 location 块，稍微疏忽就可能出错。
在这种情况下，我们可以将这些文件接口通过 rewrite 的方式，导向同一个内部 location。

```nginx
location ~* /conf/(.*?)$ {
    echo "test$1";
    rewrite .* /download_internal/$1 last;
}

location ~*  /list/(.*)$ {
    rewrite .* /download_internal/$1 break;
}

location ~* /download_internal/(.*?)$ {
    allow 127.0.0.1;  #这两行是关键代码，仅允许本机IP访问，禁封其他任何IP，不向外部暴露接口。
    deny all;
    echo "in the download_internal";
    # alias  ../download/;
    # do something here，例如设置一个共有变量
    set $common_path "/your/path/to/download_directory/";
}
```

当我们在服务器主机上，使用 `curl localhost/conf/test` 来测试时，由于是在服务器主机上，显示结果 `in the download_internal`。
当我们在服务器主机上，使用 `curl localhost/download_internal/test` 来测试时，同样由于访问请求来自本机，所以仍然也可以正常显示 `in the download_internal`。
但如果我们在另外一台机器上，使用 `curl localhost/conf/test` 来测试时，显示结果 `in the download_internal`。
如果我们在另外一台机器上，使用 `curl localhost/download_internal/test` 来测试时，由于 IP 地址并不来自于服务器主机，会返回一个 403 禁止访问代码。

（注：上面这个代码并没有走通，我只是先提交让大家看看我的工作进展）
