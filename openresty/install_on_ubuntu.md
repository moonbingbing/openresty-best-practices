# Ubuntu 平台安装

OpenResty 官方的 Linux 各发行版安装指引在 https://openresty.org/cn/linux-packages.html  页面。

### 从包管理安装
> 注：从 OpenResty 1.13.6.1 开始支持，旧版的只能编译安装。

你可以在你的 Ubuntu 系统中添加 OpenResty 的 APT 仓库，这样便于未来安装或更新软件包（通过 apt-get update 命令）。 运行下面的命令就可以添加仓库（每个系统只需要运行一次）：
```shell
# 安装导入 GPG 公钥时所需的几个依赖包（整个安装过程完成后可以随时删除它们）：
sudo apt-get -y install --no-install-recommends wget gnupg ca-certificates

# 导入 GPG 密钥：
wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -

# 添加官方 APT 仓库：
echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
    | sudo tee /etc/apt/sources.list.d/openresty.list

# 更新 APT 索引：
sudo apt-get update
```

然后就可以像下面这样安装软件包，比如 openresty：
```shell
# sudo apt-get -y install openresty
```
这个包同时也推荐安装 `openresty-opm` 和 `openresty-restydoc` 包，所以后面两个包会缺省安装上。 如果你不想自动关联安装，可以用下面方法关闭自动关联安装：
```shell
# sudo apt-get -y install --no-install-recommends openresty
```
参阅 [OpenResty Deb 包](https://openresty.org/cn/deb-packages.html) 页面获取这个仓库里头更多可用包的信息。

### 从源码编译安装

OpenResty 官方的源码安装指引在 https://openresty.org/cn/installation.html  页面。

#### 1、源码包准备

我们首先要在 [官网](http://openresty.org/) 下载 OpenResty 的源码包。官网上会提供很多的版本，各个版本有什么不同也会有说明，我们可以按需选择下载。笔者选择下载的源码包为 ngx_openresty-1.9.7.1.tar.gz。
假定将源码包保存在 `/usr/local/src/` 下，输入如下命令：

```shell
# cd /usr/local/src

# wget https://openresty.org/download/ngx_openresty-1.9.7.1.tar.gz
```

#### 2、相关依赖包的安装

首先你要安装 OpenResty 需要的多个库。
请先配置好你的 apt 源，配置源的过程在这就不阐述了，然后执行以下命令安装 OpenResty 编译或运行时所需要的软件包。

```shell
# sudo apt-get install libreadline-dev libncurses5-dev libpcre3-dev \
    libssl-dev perl make build-essential curl
```

如果你只是想测试一下OpenResty，并不想实际使用，那么你也可以不必去配置源和安装这些依赖库，请直接往下看。

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
                --with-http_iconv_module \
                --without-http_redis2_module
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
        make
        make install
    ```

- 7、 根据上一步命令提示，输入以下命令执行编译：
    ```shell
    # sudo gmake
    ```
- 8、 输入以下命令执行安装：
    ```shell
    # sudo gmake install
    ```
- 9、 上面的步骤顺利完成之后，安装已经完成。可以在你指定的安装目录下看到一些目录及文件。

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

接下来，我们就可以进入到后面的章节 [HelloWorld](helloworld.md) 学习。

