# NGINX 陷阱和常见错误

翻译自：https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/

>### 警告：
>
>**请阅读下面所有的内容！是所有的！**

不管是新手还是老用户，都可能会掉到一个陷阱中去。下面我们会列出一些我们经常看到，和
经常需要解释如何解决的问题。在 Freenode 的# NGINX IRC频道中，我们频繁的看到这些问题出现。

### 本指南说

最经常看到的是，有人从一些其他的指南中，尝试拷贝、粘贴一个配置片段。并不是说其他所有的指南都是错的，但是里面错误的比例很可怕。
即使是在 Linode 库中也有质量较差的信息，一些 NGINX 社区成员曾经徒劳的试图去纠正。

本指南的文档，是社区成员所创建和审查，他们直接和所有类型的 NGINX 用户在一起工作。
这个特定的文档之所以存在，是因为社区成员看到有大量普遍和重复出现的问题。

### 我的问题没有被列出来

在这里你没有看到和你具体问题相关的东西。也许我们并没有解决你经历的具体问题。
不要只是大概浏览下这个网页，也不要假设你是无意才找到这里的。你找到这里，是因为这里列出了你做错的一些东西。

在许多问题上，当涉及到支持很多用户，社区成员不希望去支持破碎的配置。所以在提问求助前，先修复你的配置。
通读这个文档来修复你的配置，不要只是走马观花。

### chmod 777

**永远不要** 使用777。这可能是一个漂亮的数字，有时候可以懒惰的解决权限问题，
但是它同样也表示你没有线索去解决权限问题，你只是在碰运气。
你应该检查整个路径的权限，并思考发生了什么事情。

要轻松的显示一个路径的所有权限，你可以使用

```
 namei -om /path/to/check
```

### 把root放在location区块内

糟糕的配置：

```lua
server {
    server_name www.example.com;
    location / {
        root /var/www/nginx -default/;
        # [...]
      }
    location /foo {
        root /var/www/nginx -default/;
        # [...]
    }
    location /bar {
        root /var/www/nginx -default/;
        # [...]
    }
}
```

这个是能工作的。把 root 放在 location 区块里面会工作，但并不是完全有效的。
错就错在只要你开始增加其他的 location 区块，就需要给每一个 location 区块增加一个 root 。
如果没有添加，就会没有 root 。让我们看下正确的配置。

推荐的配置：

```lua
server {
    server_name www.example.com;
    root /var/www/nginx -default/;
    location / {
        # [...]
    }
    location /foo {
        # [...]
    }
    location /bar {
        # [...]
    }
}
```

### 重复的index指令

糟糕的配置：

```lua
http {
    index index.php index.htm index.html;
    server {
        server_name www.example.com;
        location / {
            index index.php index.htm index.html;
            # [...]
        }
    }
    server {
        server_name example.com;
        location / {
            index index.php index.htm index.html;
            # [...]
        }
        location /foo {
            index index.php;
            # [...]
        }
    }
}
```

为什么重复了这么多行不需要的配置呢？简单的使用“index”指令一次就够了。只需要把它放到http
 {}区块里面，下面的就会继承这个配置。

推荐的配置：

```lua
http {
    index index.php index.htm index.html;
    server {
        server_name www.example.com;
        location / {
            # [...]
        }
    }
    server {
        server_name example.com;
        location / {
            # [...]
        }
        location /foo {
            # [...]
        }
    }
}
```

### 使用if

这里篇幅有限，只介绍一部分使用 if 指令的陷阱。更多陷阱你应该点击看看邪恶的 if 指令。
我们看下 if 指令的几个邪恶的用法。

> **注意看这里**：

 >[邪恶的 if 指令](../ngx/if_is_evil.md)

#### 用if判断Server Name

糟糕的配置：

```lua
server {
    server_name example.com *.example.com;
        if ($host ~* ^www\.(.+)) {
            set $raw_domain $1;
            rewrite ^/(.*)$ $raw_domain/$1 permanent;
        }
        # [...]
    }
}
```

这个配置有三个问题。首先是if的使用, 为啥它这么糟糕呢? 你有阅读邪恶的if指令吗?
当 NGINX 收到无论来自哪个子域名的何种请求,
不管域名是www.example.com还是example.com，这个if指令**总是**会被执行。
因此 NGINX 会检查**每个请求**的Host header，这是十分低效的。
你应该避免这种情况，而是使用下面配置里面的两个server指令。

推荐的配置：

```lua
 server {
    server_name www.example.com;
    return 301 $scheme://example.com$request_uri;
}
server {
    server_name example.com;
    # [...]
}
```

除了增强了配置的可读性，这种方法还降低了 NGINX 的处理要求；我们摆脱了不必要的if指令；
我们用了 $scheme 来表示 URI 中是 http 还是 https 协议，避免了硬编码。

#### 用if检查文件是否存在

使用if指令来判断文件是否存在是很可怕的，如果你在使用新版本的 NGINX ，
你应该看看try_files，这会让你的生活变得更轻松。

糟糕的配置：

```lua
server {
    root /var/www/example.com;
    location / {
        if (!-f $request_filename) {
            break;
        }
    }
}
```

推荐的配置：

```lua
server {
    root /var/www/example.com;
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

我们不再尝试使用 if 来判断$uri是否存在，用 try_files 意味着你可以测试一个序列。
如果 $uri 不存在，就会尝试 $uri/ ，还不存在的话，在尝试一个回调 location 。

在上面配置的例子里面，如果 $uri 这个文件存在，就正常服务；
如果不存在就检测 $uri/ 这个目录是否存在；如果不存在就按照 index.html 来处理，你需要保证 index.html 是存在的。
try_files的加载是如此简单。这是另外一个你可以完全的消除 if 指令的实例。

### 前端控制器模式的web应用

“前端控制器模式”是流行的设计，被用在很多非常流行的PHP软件包里面。
里面的很多示例配置都过于复杂。想要Drupal, Joomla等运行起来，只用这样做就可以了：

```
try_files $uri $uri/ /index.php?q=$uri&$args;
```

注意：你实际使用的软件包，在参数名字上会有差异。比如：

- "q"参数用在Drupal, Joomla, WordPress
- "page"用在CMS Made Simple

一些软件甚至不需要查询字符串，它们可以从REQUEST_URI中读取。
比如WordPress就支持这样的配置：

```
try_files $uri $uri/ /index.php;
```

当然在你的开发中可能会有变化，你可能需要基于你的需要设置更复杂的配置。
但是对于一个基础的网站来说，这个配置可以工作得很完美。
你应该永远从简单开始来搭建你的系统。

如果你不关心目录是否存在这个检测的话，你也可以决定忽略这个目录的检测，去掉 “$uri/” 这个配置。

### 把不可控制的请求发给PHP

很多网络上面推荐的和PHP相关的 NGINX 配置，都是把每一个.php结尾的 URI 传递给 PHP 解释器。
请注意，大部分这样的PHP设置都有严重的安全问题，因为它可能允许执行任意第三方代码。

有问题的配置通常如下：

```lua
location ~* \.php$ {
    fastcgi_pass backend;
    # [...]
}
```

在这里，每一个.php结尾的请求，都会传递给 FastCGI 的后台处理程序。
这样做的问题是，当完整的路径未能指向文件系统里面一个确切的文件时，
默认的PHP配置试图是猜测你想执行的是哪个文件。

举个例子，如果一个请求中的/forum/avatar/1232.jpg/file.php文件不存在，
但是/forum/avatar/1232.jpg存在，那么PHP解释器就会取而代之，
使用/forum/avatar/1232.jpg来解释。如果这里面嵌入了 PHP 代码，
这段代码就会被执行起来。

有几个避免这种情况的选择：

* 在php.ini中设置cgi.fix_pathinfo=0。
这会让 PHP 解释器只尝试给定的文件路径，如果没有找到这个文件就停止处理。

* 确保 NGINX 只传递指定的PHP文件去执行

```lua
location ~* (file_a|file_b|file_c)\.php$ {
    fastcgi_pass backend;
    # [...]
}
```

* 对于任何用户可以上传的目录，特别的关闭 PHP 文件的执行权限

```lua
location /uploaddir {
    location ~ \.php$ {return 403;}
    # [...]
}
```

* 使用 *try_files* 指令过滤出文件不存在的情况

```lua
location ~* \.php$ {
    try_files $uri =404;
    fastcgi_pass backend;
    # [...]
}
```

* 使用嵌套的 location 过滤出文件不存在的情况

```lua
location ~* \.php$ {
    location ~ \..*/.*\.php$ {return 404;}
    fastcgi_pass backend;
    # [...]
}
```

### 脚本文件名里面的FastCGI路径

很多外部指南喜欢依赖绝对路径来获取你的信息。这在 PHP 的配置块里面很常见。
当你从仓库安装 NGINX ，通常都是以在配置里面折腾好“include fastcgi_params;”来收尾。
这个配置文件位于你的 NGINX 根目录下，通常在/etc/nginx/里面。

推荐的配置：

```
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
```

糟糕的配置：

```
fastcgi_param  SCRIPT_FILENAME    /var/www/yoursite.com/$fastcgi_script_name;
```

$document_root$ 在哪里设置呢？它是 server 块里面的 root 指令来设置的。
你的 root 指令不在 server 块内？请看前面关于 root 指令的陷阱。

### 费力的rewrites

不要知难而退， rewrite 很容易和正则表达式混为一谈。
实际上， rewrite 是很容易的，我们应该努力去保持它们的整洁。
很简单，不添加冗余代码就行了。

糟糕的配置：

```
rewrite ^/(.*)$ http://example.com/$1 permanent;
```

好点儿的配置：

```
rewrite ^ http://example.com$request_uri? permanent;
```

更好的配置：

```
return 301 http://example.com$request_uri;
```

反复对比下这几个配置。
第一个 rewrite 捕获不包含第一个斜杠的完整 URI 。
使用内置的变量 $request_uri ，我们可以有效的完全避免任何捕获和匹配。

### 忽略 http:// 的rewrite

这个非常简单， rewrites 是用相对路径的，除非你告诉 NGINX 不是相对路径。
生成绝对路径的 rewrite 也很简单，加上 scheme 就行了。

糟糕的配置：

```
rewrite ^ example.com permanent;
```

推荐的配置：

```
rewrite ^ http://example.com permanent;
```

你可以看到我们做的只是在 rewrite 里面增加了 *http://*。这个很简单而且有效。

### 代理所有东西

糟糕的配置：

```
server {
    server_name _;
    root /var/www/site;
    location / {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/tmp/phpcgi.socket;
    }
}
```

这个是令人讨厌的配置，你把 **所有东西** 都丢给了 PHP 。
为什么呢？ Apache 可能要这样子做，但在 NGINX 里你不必这样。
换个思路，try_files 有一个神奇之处，它是按照特定顺序去尝试文件的。
这意味着 NGINX 可以先尝试下静态文件，如果没有才继续往后走。
这样PHP就不用参与到这个处理中，会快很多。
特别是如果你提供一个1MB图片数千次请求的服务，通过PHP处理还是直接返回静态文件呢？
让我们看下怎么做到吧。

推荐的配置：

```
server {
    server_name _;
    root /var/www/site;
    location / {
        try_files $uri $uri/ @proxy;
    }
    location @proxy {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/tmp/phpcgi.socket;
    }
}
```

另外一个推荐的配置：

```
server {
    server_name _;
    root /var/www/site;
    location / {
        try_files $uri $uri/ /index.php;
    }
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/tmp/phpcgi.socket;
    }
}
```

这个很容易，不是吗？你看，如果请求的 URI 存在， NGINX 会处理掉；
如果不存在，检查下目录是不是存在，是的话也可以被 NGINX 处理；
只有在 NGINX 不能直接处理请求的URI的时候，才会进入 proxy 这个 location 来处理。

现在，考虑下你的请求中有多少静态内容，比如图片、css、javascript等。这可能会帮你节省很多开销。

### 配置的修改没有起效

浏览器缓存。你的配置可能是对的，但怎么尝试结果总是不对，百思不得其解。
罪魁祸首是你的浏览器缓存。当你下载东西的时候，浏览器做了缓存。

怎么修复：

* 在 Firefox 里面 Ctrl+Shift+Delete ，检查缓存，点击立即清理。可以用你喜欢的搜索引擎找到其他浏览器清理缓存的方法。
每次更改配置后，都需要清理下缓存（除非你知道这个不必要），这会省很多事儿。

* 使用 curl 。

### VirtualBox

如果你在 VirtualBox 的虚拟机中运行 NGINX ，而它不工作，可能是因为 sendfile() 引起的麻烦。
只用简单的注释掉 sendfile 指令，或者设置为 off。 该指令大都会写在  NGINX .conf 文件中：

```
 sendfile off;
```

### 丢失（消失）的 HTTP 头

 
如果你没有明确的设置 underscores_in_headers on; ,
NGINX 将会自动丢弃带有下划线的 HTTP 头(根据 HTTP 标准，这样做是完全正当的).
这样做是为了防止头信息映射到 CGI 变量时产生歧义，因为破折号和下划线都会被映射为下划线。

### 没有使用标准的 Document Root Location

在所有的文件系统中，一些目录永远也不应该被用做数据的托管。这些目录包括 / 和 /root 。
你永远不应该使用这些目录作为你的 document root。

使用这些目录的话，等于打开了潘多拉魔盒，请求会超出你的预期获取到隐私的数据。

**永远也不要这样做！！！** ( 对，我们还是要看下飞蛾扑火的配置长什么样子)

```
server {
    root /;

    location / {
        try_files /web/$uri $uri @php;
    }

    location @php {
        [...]
    }
}
```

当一个对 /foo 的请求，会传递给 PHP 处理，因为文件没有找到。
这可能没有问题，直到遇到 /etc/passwd 这个请求。没错，你刚才给了我们这台服务器的所有用户列表。
在某些情况下， NGINX 的 workers 甚至是 root 用户运行的。那么，我们现在有你的用户列表，
以及密码哈希值，我们也知道哈希的方法。这台服务器已经变成我们的肉鸡了。

Filesystem Hierarchy Standard (FHS) 定义了数据应该如何存在。你一定要去阅读下。
简单点儿说，你应该把 web 的内容**放在 /var/www/ , /srv 或者 /usr/share/www 里面**。

### 使用默认的 Document Root

在 Ubuntu、 Debian 等操作系统中， NGINX 会被封装成一个易于安装的包，
里面通常会提供一个 『默认』的配置文件作为范例，也通常包含一个 document root 来保存基础的 HTML 文件。

大部分这些打包系统，并没有检查默认的 document root 里面的文件是否修改或者存在。
在包升级的时候，可能会导致代码失效。有经验的系统管理员都知道，不要假设默认的 document root
里面的数据在升级的时候会原封不动。

你不应该使用默认的 document root 做网站的任何关键文件的目录。
并没有默认的 document root 目录会保持不变这样的约定，你网站的关键数据，
很可能在更新和升级系统提供的 NGINX 包时丢失。

### 使用主机名来解析地址

糟糕的配置：

```lua
upstream {
    server http://someserver;
}

server {
    listen myhostname:80;
    # [...]
}
```

你不应该在 listen 指令里面使用使用主机名。
虽然这样可能是有效的，但它会带来层出不穷的问题。
其中一个问题是，这个主机名在启动时或者服务重启中不能解析。
这会导致 NGINX 不能绑定所需的 TCP socket 而启动失败。

一个更安全的做法是使用主机名对应 IP 地址，而不是主机名。
这可以防止 NGINX 去查找 IP 地址，也去掉了去内部、外部解析程序的依赖。

例子中的 upstream location 也有同样的问题，虽然有时候在 upstream 里面不可避免要使用到主机名，
但这是一个不好的实践，需要仔细考虑以防出现问题。

推荐的配置：

```lua
upstream {
    server http://10.48.41.12;
}

server {
    listen 127.0.0.16:80;
    # [...]
}
```

### 在 HTTPS 中使用 SSLv3

由于 SSLv3 的 [POODLE 漏洞](https://www.openssl.org/~bodo/ssl-poodle.pdf)，
建议不要在开启 SSL 的网站使用 SSLv3。
你可以简单粗暴的直接禁止 SSLv3， 用 TLS 来替代：

```
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```
