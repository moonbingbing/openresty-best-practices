# NGINX陷阱和常见错误
翻译自：https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/

>### 警告：
>
>**请阅读下面所有的内容！是所有的！**

不管是新手还是老用户，都可能会掉到一个陷阱中去。下面我们会列出一些我们经常看到，和
经常需要解释如何解决的问题。在Freenode的#nginx IRC频道中，我们频繁的看到这些问题出现。

### 本指南说
最经常看到的是，有人从一些其他的指南中，尝试拷贝、粘贴一个配置片段。并不是说其他所有的指南都是错的，但是里面错误的比例很可怕。
即使是在Linode库中也有质量较差的信息，一些NGINX社区成员曾经徒劳的试图去纠正。

本指南的文档，是社区成员所创建和审查，他们直接和所有类型的NGINX用户在一起工作。
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
        root /var/www/nginx-default/;
        # [...]
      }
    location /foo {
        root /var/www/nginx-default/;
        # [...]
    }
    location /bar {
        root /var/www/nginx-default/;
        # [...]
    }
}
```
这个是能工作的。把root放在location区块里面会工作，但并不是完全有效的。
错就错在只要你开始增加其他的location区块，就需要给每一个location区块增加一个root。
如果没有添加，就会没有root。让我们看下正确的配置。

推荐的配置：

```lua
server {
    server_name www.example.com;
    root /var/www/nginx-default/;
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
这里篇幅有限，只介绍一部分使用if指令的陷阱。更多陷阱你应该点击看看邪恶的if指令。
我们看下if指令的几个邪恶的用法。

> **注意看这里**：

 >[邪恶的if指令](ngx/if_is_evil.md)

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
当NGINX收到无论来自哪个子域名的何种请求,
不管域名是www.example.com还是example.com，这个fi指令**总是**会被执行。
 因此NGINX
 会检查**每个请求**的Host header，这是十分低效的。
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
除了增强了配置的可读性，这种方法还降低了NGINX的处理要求；我们摆脱了不必要的if指令；
我们用了$scheme来表示URI中是http还是https协议，避免了硬编码。

#### 用if检查文件是否存在
使用if指令来判断文件是否存在是很可怕的，如果你在使用新版本的NGINX，
你应该看看rty_files，这会让你的生活变得更轻松。

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
我们不再尝试使用if来判断$uri是否存在，用try_files意味着你可以测试一个序列。
如果$uri不存在，就会尝试$uri/，还不存在的话，在尝试一个回调location。

在上面配置的例子里面，如果$uri这个文件存在，就正常服务；如果不存在就检测$uri/这个目录是否存在；如果不存在就按照index.html来处理，你需要保证index.html是存在的。
try_files的加载是如此简单。这是另外一个你可以完全的消除if指令的实例。

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
但是对于一个基础的网站来说，这个配置可以工作的很完美。
你应该永远从简单开始来搭建你的系统。

如果你不关心目录是否存在这个检测的话，你也可以决定忽略这个目录的检测，去掉“$uri/”这个配置。
