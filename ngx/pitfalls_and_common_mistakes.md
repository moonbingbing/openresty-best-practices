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

要轻松的现实一个路径的所有权限，你可以使用
```
 namei -om /path/to/check
```

### 把root放在location区块内
错误：
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

正确：

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
错误：
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

正确：
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
