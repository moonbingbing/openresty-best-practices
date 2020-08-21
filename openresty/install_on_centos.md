# CentOS 平台安装

### 从包管理安装

OpenResty 现在提供了 CentOS 上的 [官方包](http://openresty.org/cn/linux-packages.html)。
你只需运行下面的命令：

```shell
# sudo yum-config-manager --add-repo https://openresty.org/yum/cn/centos/OpenResty.repo
# sudo yum install openresty
```

如果一切顺利，OpenResty 应该已经安装好了。接下来，我们就可以进入到后面的章节 [HelloWorld](helloworld.md) 学习。

### 从源码编译安装
如果你想了解更多 OpenResty 上的细节，且不介意弄脏双手；抑或有自定义 OpenResty 安装的需求，可以往下看从源码编译安装的方式。

#### 1、源码包准备

我们首先要在 [官网](http://openresty.org/) 下载 OpenResty 的源码包。官网上会提供很多的版本，各个版本有什么不同也会有说明，我们可以按需选择下载。
笔者选择下载的源码包为 ngx_openresty-1.9.7.1.tar.gz（请大家跟进使用最新版本，这里只是个例子）。
假定将源码包保存在 `/usr/local/src/` 下，输入如下命令：
```shell
# cd /usr/local/src

# wget https://openresty.org/download/ngx_openresty-1.9.7.1.tar.gz
```


#### 2、依赖库安装

需要在系统中安装的依赖库： `perl 5.6.1+`、`libreadline`、 `libpcre`、 `libssl`。
按照以下步骤安装：

- 1、 输入下面的命令，一次性安装需要的库：
    ```shell
    # sudo yum install readline-devel pcre-devel openssl-devel perl
    ```
- 2、 安装成功后会有 “Complete！” 字样。

#### 3、OpenResty 安装

- 1、 在命令行中切换到源码包所在目录；
    ```shell
    # cd /usr/local/src/
    ```
- 2、 解压源码包；（若你下载的源码包版本不一样，将相应的版本号改为你所下载的即可。）
    ```
    # tar xzvf ngx_openresty-1.9.7.1.tar.gz
    ```
- 3、 切换到解压后的源码目录；
    ```shell
    # cd ngx_openresty-1.9.7.1
    ```
- 4、 了解默认激活的组件；
    [OpenResty 官网](http://openresty.org/) 有组件列表，供我们参考，列表中大部分组件默认激活，也有部分默认不激活。
    默认不激活的组件，我们可以在编译的时激活，后面步骤将详细说明。
- 5、 配置安装目录及需要激活的组件；
    - 使用选项 `--prefix=install_path`，指定安装目录（默认为 `/usr/local/openresty`）。
    - 使用选项 `--with-Components` 激活组件，`--without` 则是禁止组件。

    你可以根据自己实际需要选择 `--with` 或 `--without`。 例如，

    ```shell
    # sudo ./configure --prefix=/opt/openresty \
                --with-luajit \
                --with-http_iconv_module
                --without-http_redis2_module \
    ```
    命令解析：
    - 配置 OpenResty 的安装目录为 `/opt/openresty` （注意使用 root 用户）
    - 激活 `luajit`、`http_iconv_module` 组件
    - 禁止 `http_redis2_module` 组件

- 6、 在上一步中，最后没有什么 error 的提示就是最好的；
    - 若有错误，最后会显示具体原因。
    可以到源码包目录下的 `build/nginx-VERSION/objs/autoconf.err` 文件查看。
    - 若没有错误，则会出现如下信息：

    ```shell
     Type the following commands to build and install:
         gmake
         gmake install
    ```

- 7、 根据上一步命令提示，输入以下命令执行编译：
	```
	# sudo gmake
	```
- 8、 输入以下命令执行安装：
	```
	# sudo gmake install
	```
- 9、 上面的步骤顺利完成之后，安装已经完成。可以在你指定的安装目录下看到一些目录及文件。

#### 4、设置环境变量

为了后面启动 OpenResty 的命令简单一些，不用每次都切换到 OpenResty 的安装目录下执行启动，我们设置环境变量来简化操作。
- 将 nginx 的目录添加到 PATH 中。
	打开文件 `/etc/profile`：
	```
	# sudo vim /etc/profile
	```

	在文件末尾添加下面的内容 (若你的安装目录不一样，则需做相应修改)：
	```
	export PATH=$PATH:/opt/openresty/nginx/sbin
	```
- 使环境变量立即生效：
	```
	# sudo source /etc/profile
	```

注意：这一步操作只是在本终端有效，如果新打开一个终端仍然是没有生效的。若要使环境变量永久生效需重启服务器。

接下来，我们就可以进入到后面的章节 [HelloWorld](helloworld.md) 学习。
