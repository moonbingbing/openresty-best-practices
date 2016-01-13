# CentOS 平台下OpenResty的安装

#### 源码包准备

我们首先要在[官网](http://openresty.org/)下载OpenResty的源码包。官网上会提供很多的版本，各个版本有什么不同也会有说明，我们可以按需选择下载。
笔者选择下载的源码包为ngx_openresty-1.9.7.1.tar.gz.

#### 相关库的安装

将这些相关的库perl 5.6.1+,libreadline, libpcre, libssl安装在系统中。
按照以下步骤：<p>

1. 用你喜欢的方式打开命令终端。
2. 为了保险起见，切换到root用户（后面的步骤也一样）。在终端输入su,再输入密码，root成功。
3. 输入以下命令```yum install readline-devel pcre-devel openssl-devel perl```，一次性安装需要的库。
4. 相关库安装成功。安装成功后会有“Complete！”字样。

#### OpenResty的安装

1. 在命令行中切换到源码包所在目录。
2. 输入命令```tar xzvf ngx_openresty-1.9.7.1.tar.gz```，按回车键解压源码包。若你下载的源码包版本不一样，将相应的版本号改为你所下载的即可，
或者直接拷贝源码包的名字到命令中。此时当前目录下会出现一个ngx _ openresty-1.9.7.1文件夹。
3. 在命令行中切换工作目录到ngx _ openresty-1.9.7.1。输入命令```cd ngx_openresty-1.9.7.1```。
4. 了解组件是否默认激活。[官网](http://openresty.org/)上有个组件列表,我们可以参考，列表中大部分组件默认激活，也有部分默认不激活。
默认不激活的组件，我们可以在编译的时候将他们激活，下面步骤详说如何激活。
5. 配置安装目录及需要激活的组件。使用选项--prefix=install_path，指定其安装目录（默认为/usr/local/openresty）；
使用选项--with-Components激活组件，--without则是禁止组件，你可以根据自己实际需要选择with及without。
输入如下命令，OpenResty将配置安装在/opt/openresty目录下（注意使用root用户）,并激活luajit、http _ iconv _ module并禁止http _ redis2 _ module组件。

	```
	./configure --prefix=/opt/openresty\
				--with-luajit\
	            --without-http_redis2_module \
	            --with-http_iconv_module
	```
6. 在上一步中，最后没有什么error的提示就是最好的。若有错误，最后会显示error字样，
具体原因可以看源码包目录下的build/nginx-VERSION/objs/autoconf.err文件查看。若没有错误，则会出现如下信息，提示下一步操作：

	```
	 Type the following commands to build and install:
     gmake
     gmake install
	```

7. 编译。根据上一步命令提示，输入```gmake```。
8. 安装。输入```gmake install```.
9. 上面的步骤顺利完成之后，安装已经完成。可以在你指定的安装目录下看到一些相关目录及文件。

#### 设置环境变量

为了后面启动OpenResty的命令简单一些，不用在OpenResty的安装目录下进行启动，我们通过设置环境变量来简化操作。
将OpenResty目录下的nginx/sbin目录添加到PATH中。就是打开文件 /etc/profile，
在文件末尾加入```export PATH=$PATH:/opt/openresty/nginx/sbin```，若你的安装目录不一样，则做相应修改。
注意：这一步操作需要重新加载环境变量才会生效，可通过命令```source /etc/profile```或者重启服务器等方式实现。

接下来，我们就可以进入到后面的章节[HelloWorld](helloworld.md)学习。
