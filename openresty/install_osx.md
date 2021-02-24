# Mac OS X 平台安装

OpenResty 官方的安装指引在 https://openresty.org/cn/installation.html 页面。

### 从包管理安装

通过 Homebrew，OpenResty 提供了 OSX 上的 [官方包](https://github.com/Homebrew/homebrew-nginx/blob/master/Formula/openresty.rb)。
你只需运行下面的命令：

```shell
$ brew install openresty/brew/openresty
```
如果你之前是从 homebrew/nginx 安装的 OpenResty，请先执行：
```shell
$ brew untap homebrew/nginx
```
如果一切顺利，OpenResty 应该已经安装好了。 接下来，我们就可以进入到后面的章节 [HelloWorld](helloworld.md) 学习。

### 从源码编译安装

如果你想了解更多 OpenResty 上的细节，且不介意弄脏双手；抑或有自定义 OpenResty 安装的需求，可以往下看从源码安装的方式。

#### 1、源码包准备

我们首先要在 [官网](http://openresty.org/) 下载`OpenResty`的源码包。官网上会提供很多的版本，各个版本有什么不同也会有说明，我们可以按需选择下载。笔者选择下载的源码包 [ngx_openresty-1.9.7.1.tar.gz](https://openresty.org/download/ngx_openresty-1.9.7.1.tar.gz)。

#### 2、相关库的安装

将这些相关库安装到系统中，推荐如 Homebrew 这类包管理方式完成包管理：

```shell
$ brew update
$ brew install pcre openssl
```

在安装 PCRE 和 OpenSSL 之后，你可能需要为 C 编译器和链接器指定它们的头文件和库的路径，例如
```
$ ./configure \
   --with-cc-opt="-I/usr/local/opt/openssl/include/ -I/usr/local/opt/pcre/include/" \
   --with-ld-opt="-L/usr/local/opt/openssl/lib/ -L/usr/local/opt/pcre/lib/" \
   -j8
```
假设您的 PCRE 和 OpenSSL 安装在前缀 `/usr/local/opt/` 下，这是 homebrew 的默认设置。


#### 3、OpenResty 安装

- 1、 在命令行中切换到源码包所在目录；
    ```shell
    # cd /usr/local/src/
    ```
- 2、 解压源码包；（若你下载的源码包版本不一样，将相应的版本号改为你所下载的即可。）
    ```shell
    # tar -xzvf ngx_openresty-1.9.7.1.tar.gz
    ```
- 3、 切换到解压后的源码目录；
    ```shell
    # cd ngx_openresty-1.9.7.1
    ```
- 4、 配置安装目录及需要激活的组件。
    - 使用选项 `--prefix=install_path`，指定安装目录（默认为 `/usr/local/openresty`）。
    - 使用选项 `--with-Components` 激活组件，`--without` 则是禁止组件。

    你可以根据自己实际需要选择 `--with` 或 `--without`。 例如，

    ```shell
    # sudo ./configure --prefix=/opt/openresty \
                --with-cc-opt="-I/usr/local/opt/openssl/include/ -I/usr/local/opt/pcre/include/" \
                --with-ld-opt="-L/usr/local/opt/openssl/lib/ -L/usr/local/opt/pcre/lib/" \
                --with-luajit \
                --with-http_iconv_module \
                --without-http_redis2_module
    ```
    命令解析：
    - 配置 OpenResty 的安装目录为 `/opt/openresty` （注意使用 root 用户）
    - 指定 PCRE 和 OpenSSL 的头文件和库的路径
    - 激活 `luajit`、`http_iconv_module` 组件
    - 禁止 `http_redis2_module` 组件

- 5、 在上一步中，最后没有什么 error 的提示就是最好的。
    - 若有错误，最后会显示 error 字样，具体原因可以看源码包目录下的 `build/nginx-VERSION/objs/autoconf.err` 文件查看。
    - 若没有错误，则会出现如下信息，提示下一步操作：

    ```shell
    Type the following commands to build and install:
        make
        sudo make install
    ```

- 6、 根据上一步命令提示，输入以下命令执行编译：
    ```shell
    # sudo make
    ```
- 7、 输入以下命令执行安装（这里可能需要输入你的管理员密码）：
    ```shell
    # sudo make install
    ```
- 8、 上面的步骤顺利完成之后，安装已经完成。可以在你指定的安装目录下看到一些目录及文件。

#### 4、设置环境变量

为了后面启动 OpenResty 的命令简单一些，不用每次都切换到 OpenResty 的安装目录下执行启动，我们设置环境变量来简化操作。
- 将 nginx 的目录添加到 PATH 中。
    打开文件 `/etc/profile`：
    ```shell
    # sudo vim /etc/profile
    ```

    在文件末尾添加下面的内容 (若你的安装目录不一样，则需做相应修改)：
    ```shell
    export PATH=$PATH:/opt/openresty/nginx/sbin
    ```
- 使环境变量立即生效：
    ```shell
    # sudo source /etc/profile
    ```

注意：这一步操作只是在本终端有效，如果新打开一个终端仍然是没有生效的。若要使环境变量永久生效需重启服务器。


接下来，我们就可以进入到后面的章节 [Hello World](helloworld.md) 学习。
