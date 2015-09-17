# Nginx新手起步

#### Nginx是什么

Nginx (“engine x”) 是一个高性能的HTTP和反向代理服务器，也是一个IMAP/POP3/SMTP代理服务器。Nginx是由Igor Sysoev为俄罗斯著名的Rambler.ru站点开发的，第一个公开版本0.1.0发布于2004年10月4日。其将源代码以类BSD许可证的形式发布，因它的稳定性、丰富的功能集、示例配置文件和低系统资源的消耗而闻名。

由于Nginx使用基于事件驱动的架构，能够并发处理百万级别的TCP连接，高度模块化的设计和自由的许可证使得扩展Nginx功能的第三方模块层出不穷。因此其作为web服务器被广泛应用到大流量的网站上，包括淘宝、腾讯、新浪、京东等访问量巨大的网站。

2015年6月，Netcraft 收到的调查网站有8亿多家，主流Web服务器市场份额（前四名）如下表：

|Web服务器|市场占有率|
|:--------|:---------:|
|Apache|49.53%|
|Nginx|13.52%|
|Microsoft IIS|12.32%|
|Google Web Server|7.72%|

其中在访问量最多的一万个网站中，Nginx的占有率已超过Apache。

#### 为什选择Nginx

为什么选择Nginx？因为它具有以下特点：

1、处理响应请求很快

在正常的情况下，单次请求会得到更快的响应。在高峰期，Nginx可以比其它的Web服务器更快的响应请求。

2、高并发连接

在互联网快速发展，互联网用户数量不断增加的今天，一些大公司、网站都需要面对高并发请求，如果有一个能够在峰值顶住10万以上并发请求的Server，肯定会得到大家的青睐。理论上，Nginx支持的并发连接上限取决于你的内存，10万远未封顶。

3、低的内存消耗

在一般的情况下，10000个非活跃的HTTP Keep-Alive 连接在Nginx中仅消耗2.5MB的内存，这也是Nginx支持高并发连接的基础。

4、具有很高的可靠性：

Nginx是一个高可靠性的Web服务器，这也是我们为什么选择Nginx的基本条件，现在很多的网站都在使用Nginx，足以说明Nginx的可靠性。高可靠性来自其核心框架代码的优秀设计、模块设计的简单性；并且这些模块都非常的稳定。

5、高扩展性

Nginx的设计极具扩展性，它完全是由多个不同功能、不同层次、不同类型且耦合度极低的模块组成。这种设计造就了Nginx庞大的第三方模块。

6、热部署

master管理进程与worker工作进程的分离设计，使得Nginx具有热部署的功能，可以在7×24小时不间断服务的前提下，升级Nginx的可执行文件。也可以在不停止服务的情况下修改配置文件，更换日志文件等功能。

7、自由的BSD许可协议

BSD许可协议不只是允许用户免费使用Nginx，也允许用户修改Nginx源码，还允许用户用于商业用途。

#### 如何使用 Nginx

Nginx 安装：

不同系统依赖包可能不同，例如pcre，zlib，openssl等。

1. 获取 Nginx，在http://nginx.org/en/download.html上可以获取当前最新的版本。
2. 解压缩nginx-xx.tar.gz包。
3. 进入解压缩目录，执行./configure
4. make & make install

若安装时找不到上述依赖模块，使用--with-openssl=`<openssl_dir>`、--with-pcre=`<pcre_dir>`、--with-zlib=`<zlib_dir>`指定依赖的模块目录。如已安装过，此处的路径为安装目录；若未安装，则此路径为编译安装包路径，nginx将执行模块的默认编译安装。

启动nginx之后，浏览器中输入 http://localhost 可以验证是否安装启动成功。

![](nginx_hello.jpg)

Nginx 配置示例:

安装完成之后，配置目录conf下有以下配置文件，过滤掉了xx.default配置：

```shell
ubuntu: /opt/nginx-1.7.7/conf$ tree |grep -v default
.
├── fastcgi.conf
├── fastcgi_params
├── koi-utf
├── koi-win
├── mime.types
├── nginx.conf
├── scgi_params
├── uwsgi_params
└── win-utf
```

*除了nginx.conf，其余配置文件，一般只需要使用默认提供即可。*

2.1.nginx.conf
nginx.conf是主配置文件，默认配置去掉注释之后的内容如下图所示：

```
worker_process      # 表示工作进程的数量，一般设置为cpu的核数

worker_connections  # 表示每个工作进程的最大连接数

server{}            # 块定义了虚拟主机

    listener        # 监听端口
    
    server_name     # 监听域名
    
    location {}     # 是用来为匹配的 URI 进行配置，URI 即语法中的“/uri/”

    location /{}    # 匹配任何查询，因为所有请求都以 / 开头

        root        # 指定对应uri的资源查找路径，这里html为相对路径，完整路径为
                    # /opt/nginx-1.7.7/html/

        index       # 指定首页index文件的名称，可以配置多个，以空格分开。如有多
                    # 个，按配置顺序查找。
```

![](nginx_conf.jpg)

从配置可以看出，nginx监听了80端口、域名为localhost、跟路径为html文件夹（我的安装路径为/opt/nginx-1.7.7，所以/opt/nginx-1.7.7/html）、默认index文件为index.html， index.htm、服务器错误重定向到50x.html页面。

可以看到/opt/nginx-1.7.7/html/有以下文件：

```shell
ubuntu:/opt/nginx-1.7.7/html$ ls
50x.html  index.html
```

这也是上面在浏览器中输入http://localhost，能够显示欢迎页面的原因。实际上访问的是/opt/nginx-1.7.7/html/index.html文件。
