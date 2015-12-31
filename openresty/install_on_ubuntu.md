# Ubuntu 平台下OpenResty的安装

#### 源码包准备

我们首先要在[官网](http://openresty.org/)下载OpenResty的源码包。官网上会提供很多的版本，各个版本有什么不同也会有说明，我们可以按需选择下载。笔者选择下载的源码包为ngx_openresty-1.9.3.1.tar.gz。

#### 相关依赖包的安装

首先你要安装OpenResty需要的多个库
请先配置好你的apt源，配置源的过程在这就不阐述了，然后执行以下命令安装OpenResty编译或运行时所需要的软件包。

```
apt-get install libreadline-dev libncurses5-dev libpcre3-dev \
    libssl-dev perl make build-essential
```
如果你只是想测试一下OpenResty，并不想实际使用，那么你也可以不必去配置源和安装这些依赖库，请直接往下看。

### OpenResty的安装

OpenResty在linux的部署可以通过C程序员非常熟悉的方式进行安装：

```
./configure
make && make install
```

具体的步骤如下：

####（1）将软件包拷贝到Ubuntu系统中

首先通过WinScp或者XFTP等文件传输工具将之前下载的OpenResty包传输到你的Ubuntu系统上，如果你的Ubuntu系统可以直接联网的话，你也可以通过```wget https://openresty.org/download/ngx_openresty-1.9.3.1.tar.gz```命令直接从官网下载OpenResty到当前目录。

####（2）解压openresty软件包

```
tar xzvf ngx_openresty-1.9.3.1.tar.gz
```

一般来说这个命令不会出错，解压之后你会得到一个名为ngx_openresty-1.9.3.1的文件夹，如果解压出错，请尝试重新下载OpenResty。

####（3）配置安装目录及需要激活的组件

现在你可以进入到解压出来的目录下，大致浏览一下目录结构，我们可以看到有一个configure文件，它是一个可执行文件，我们可以通过configure命令来对OpenResty进行一些配置，常见的配置有：   
1）OpenResty安装目录： --prefix，不指定则默认为/usr/local/openresty  
2）激活某些组件： with-xxxx  
3）禁用某些组件： without-xxxx  
OpenResty是在Nginx的基础之上，集成了大量优秀的第三方模块形成的，在OpenResty中，大多数的组件都是默认激活的，只有少数几个组件需要手动指定激活，可以通过下述选项激活这几个组件： 
  
```
--with-lua51 
--with-http_drizzle_module
--with-http_postgres_module
--with-http_iconv_module
```

一个完整的配置命令如下：

```
./configure --prefix=/opt/openresty\ 
	        --without-http_redis2_module \
	        --with-http_postgres_module
```

命令很短，也比较好理解：   
1） --prefix=/opt/openresty：将软件安装在/opt/openresty目录下  
2） --without-http_redis2_module：禁用redis模块  
3） with-http_postgres_module：启用postgres数据库模块  

上述命令如果不出错的话则会在当前目录下生成一个makefile文件，这是为我们后续的```make && make install```做准备的，该文件指定了make命令的执行规则。
如果出现了错误，则在控制台会输出错误信息，即失败的原因，为何出错可以根据失败原因进行具体的分析，我在这里简单总结下可能的情况：  
1）缺少了依赖库：绝大多数情况都是因为这个导致的，可以查看错误提示中具体说明的缺少哪一个库，然后进行安装即可  
2）部分库本身BUG：这种情况是非常少见的，除非你在一些特别的Ubuntu版本上进行安装，笔者使用的是Ubuntu 14.04.3 LTS，没有发现任何问题，如果出现这类问题，可以尝试更新一下编译器版本或者该库文件版本  

前面我们说到，如果只是想测试一下OpenResty的话，我们可以不安装依赖库，当然在这里配置时也需要禁用几个模块，防止configure命令出错

```
./configure --without-http_rewrite_module --without-http_ssl_module  --without-http_gzip_module
```

禁用了这几个模块之后，即可顺利生成makefile文件，但是仅供测试，少了这几个模块，你就少了很多强大的功能。

####（4）执行安装

完成了安装前的配置，生成了对应的makefile之后，我们就可以进行真正的安装了，命令非常的简单。

```
make && make install
```

执行完该命令之后，OpenResty就安装到了你之前指定的安装目录下了。

### 测试安装是否成功

如果你在之前的```make && make install```中没有发现错误的话，一般来说就是安装成功了，但是我们还是进行一个简单的测试以保证我们OpenResty确实成功安装了。

如果你使用的是默认的安装目录，则可以执行以下命令启动OpenResty，如果不是，请改为你指定的路径。

```
/usr/local/openresty/nginx/sbin/nginx
```

正确启动的话则没有任何输出，现在OpenResty已经成功启动并监听了Ubuntu服务器的80端口，你可以打开浏览器，输入你的Ubuntu服务器的IP，则可以看到"Welcome to nginx!"字样，这说明你的OpenResty服务器已经成功运行了。
你也可以通过直接在Ubuntu服务器上输入以下指令来测试OpenResty是否成功启动

```
curl 127.0.0.1
```

你会看到一小段HTML格式的文本输出。

### 设置环境变量方便操作

之前的测试案例中，我们需要切换到软件安装的目录下执行相应的命令，那么有没有办法让我们可以直接在任意目录下都可以使用OpenResty的命令呢，其实也非常的简单，只需要配置一下环境变量PATH即可。
在linux终端输入一个命令之后，它会到PATH环境变量所指定的各个目录下去寻找这个命令，所以我们要做的就是把OpenResty的sbin目录，也就是OpenResty的可执行文件目录设置到PATH环境变量中即可。

在Ubuntu中，有许多方式可以设置环境变量，在多个文件中添加相应的配置行都能达到设置环境变量的目的，我们这里通过设置用户家目录下的.bashrc文件来实现。

```
vi ~/.bashrc

# 添加下面一行代码即可，笔者一般都添加到文件开头，方便查看
# 注意：冒号后面接的是OpenResty安装的位置的可执行文件目录
# 没有特殊指定安装目录的则是： /usr/local/openresty/nginx/sbin

export PATH=$PATH:/usr/local/openresty/nginx/sbin
```

添加配置之后不会立即生效，我们可以通过source命令来重新加载一下我们的配置文件

```
source ~/.bashrc
```

之后我们就可以在任意位置来使用nginx命令了

```
cd ~
nginx -s reload
```

接下来，我们就可以进入到后面的章节[HelloWorld](helloworld.md)学习。

