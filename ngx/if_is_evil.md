# if 是邪恶的

当在 location 区块中使用 if 指令的时候会有一些问题, 在某些情况下它并不按照你的预期运行而是做一些完全不同的事情。而在另一些情况下他甚至会出现段错误。一般来说避免使用 if 指令是个好主意。

在 location 区块里 if 指令下唯一 100% 安全的指令应该只有:

>return …;
>rewrite … last;

除此以外的指令都可能导致不可预期的行为, 包括诡异的发出段错误信号 (SIGSEGV)。

要着重注意的是 if 的行为不是反复无常的, 给出两个条件完全一致的请求, Nginx 并不会出现一个正常工作而一个请求失败的随机情况, 在明晰的测试和理解下 if 是完全可用的。尽管如此, 在这里还是建议使用其他指令。

总有一些情况你无法避免去使用 if 指令, 比如你需要测试一个变量, 而它没有相应的配置指令。

```nginx
if ($request_method = POST) {
    return 405;
}
if ($args ~ post=140){
    rewrite ^ http://example.com/ permanent;
}
```

#### 如何替换掉 if

使用 try_files 如果他适合你的需求。在其他的情况下使用 `return …` 或者 `rewrite … last`。还有一些情况可能要把 if 移动到 server 区块下(只有当其他的 rewrite 模块指令也允许放在的地方才是安全的)。

如下可以安全地改变用于处理请求的 location。

```nginx
location / {
    error_page 418 = @other;
    recursive_error_pages on;

    if ($something) {
        return 418;
    }

    # some configuration
    # ...
}

location @other {
    # some other configuration
    # ...
}
```

在某些情况下使用嵌入脚本模块(嵌入 perl 或者其他一些第三方模块)处理这些脚本更佳。

以下是一些例子用来解释为什么 if 是邪恶的。非专业人士, 请勿模仿!

```nginx
# 这里收集了一些出人意料的坑爹配置来展示 location 中的 if 指令是万恶的

# 只有第二个 header 才会在响应中展示
# 这不是 Bug, 只是他的处理流程如此

location /only-one-if {
    set $true 1;

    if ($true) {
        add_header X-First 1;
    }

    if ($true) {
        add_header X-Second 2;
    }

    return 204;
}

# 因为 if, 请求会在未改变 uri 的情况下下发送到后台的 '/'

location /proxy-pass-uri {
    proxy_pass http://127.0.0.1:8080/;

    set $true 1;

    if ($true) {
        # nothing
    }
}

# 因为if, try_files 失效

location /if-try-files {
    try_files  /file  @fallback;

    set $true 1;

    if ($true) {
        # nothing
    }
}

# nginx 将会发出段错误信号(SIGSEGV)

location /crash {

    set $true 1;

    if ($true) {
        # fastcgi_pass here
        fastcgi_pass  127.0.0.1:9000;
    }

    if ($true) {
        # no handler here
    }
}

# alias with captures isn't correcly inherited into implicit nested location created by if
# alias with captures 不能正确的继承到由if创建的隐式嵌入的location

location ~* ^/if-and-alias/(?<file>.*) {
    alias /tmp/$file;

    set $true 1;

    if ($true) {
        # nothing
    }
}
```

#### 为什么会这样且到现在都没修复这些问题?

if 指令是 rewrite 模块中的一部分, 是实时生效的指令。另一方面来说, Nginx 配置大体上是陈述式的。在某些时候用户出于特殊是需求的尝试, 会在 if 里写入一些非 rewrite 指令, 这直接导致了我们现处的情况。大多数情况下他可以工作, 但是…看看上面。
看起来唯一正确的修复方式是完全禁用 if 中的非 rewrite 指令。但是这将破坏很多现有可用的配置, 所以还没有修复。

#### 如果你还是想知道该如何使用 if

如果你看完了上面所有内容还是想使用 if ，请确认你确实理解了该怎么用它。一些比较基本的用法可以在[这里](http://agentzh.blogspot.jp/2011/03/how-nginx-location-if-works.html)找到。

##### 做适当的测试

我已经警告过你了!

> 文章选自：http://xwsoul.com/posts/761
> TODO:这个文章后面需要自己翻译，可能有版权问题：https://www.nginx.com/resources/wiki/start/topics/depth/ifisevil/
