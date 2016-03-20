# Mac OS X 平台下 OpenResty 安装

#### 源码包准备

我们首先要在[官网](http://openresty.org/)下载`OpenResty`的源码包。官网上会提供很多的版本，各个版本有什么不同也会有说明，我们可以按需选择下载。笔者选择下载的源码包 [ngx_openresty-1.9.7.1.tar.gz](https://openresty.org/download/ngx_openresty-1.9.7.1.tar.gz)。

#### 相关库的安装

将这些相关库安装到系统中，推荐如 Homebrew 这类包管理方式完成包管理：

```shell
$ brew update
$ brew install pcre openssl
```

#### OpenResty 安装

1. 在命令行中切换到源码包所在目录。
1. 输入命令```tar xzvf ngx_openresty-1.9.7.1.tar.gz```，按回车键解压源码包。若你下载的源码包版本不一样，
将相应的版本号改为你所下载的即可，或者直接拷贝源码包的名字到命令中。
此时当前目录下会出现一个`ngx_openresty-1.9.7.1`文件夹。
1. 在命令行中切换工作目录到`ngx_openresty-1.9.7.1`。输入命令```cd ngx_openresty-1.9.7.1```。
1. 配置安装目录及需要激活的组件。使用选项 --prefix=install_path ，指定其安装目录（默认为/usr/local/openresty）。
使用选项 --with-Components 激活组件， --without 则是禁止组件，你可以根据自己实际需要选择 with 及 without 。
输入如下命令，OpenResty 将配置安装在 /opt/openresty 目录下（注意使用root用户），激活 LuaJIT、HTTP\_iconv\_module 并禁止 http\_redis2\_module 组件。

    ```
    ./configure --prefix=/opt/openresty\
                --with-cc-opt="-I/usr/local/include"\
                --with-luajit\
                --without-http_redis2_module \
                --with-ld-opt="-L/usr/local/lib"
    ```

1. 在上一步中，最后没有什么error的提示就是最好的。若有错误，最后会显示error字样，
具体原因可以看源码包目录下的build/nginx-VERSION/objs/autoconf.err文件查看。
若没有错误，则会出现如下信息，提示下一步操作：

    ```
     Type the following commands to build and install:
     gmake
     gmake install
    ```

7. 编译。根据上一步命令提示，输入```gmake```。
8. 安装。输入```gmake install```，这里可能需要输入你的管理员密码。
9. 上面的步骤顺利完成之后，安装已经完成。可以在你指定的安装目录下看到一些相关目录及文件。

#### 设置环境变量

为了后面启动`OpenResty`的命令简单一些，不用在`OpenResty`的安装目录下进行启动，我们通过设置环境变量来简化操作。
将`OpenResty`目录下的 nginx/sbin 目录添加到 PATH 中。

接下来，我们就可以进入到后面的章节 [Hello World](helloworld.md) 学习。
