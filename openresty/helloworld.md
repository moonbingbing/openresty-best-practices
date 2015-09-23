#HelloWorld

`HelloWorld` 是我们恒古不变的第一个入门程序。但是 `OpenResty` 不是一门编程语言，跟其他编程语言的 `HelloWorld` 不一样，让我们来看看都有哪些不一样吧。

####创建工作目录

OpenResty安装之后就有配置文件及相关的目录的，为了工作目录与安装目录互不干扰，并顺便学下简单的配置文件编写，我们另外创建一个OpenResty的工作目录来练习，并且另写一个配置文件。我选择在根目录创建一个openresty-test目录，输入命令为：```mkdir /openresty-test```。你可以创建你喜欢的目录名字。

上面说了要指定它的工作相关参数，为此，我们单独创建一个存放配置文件的目录和日志的目录。输入命令```cd /openresty-test```，进入工作目录。然后输入命令 ```mkdir logs/ conf/```,创建logs和conf子目录存放日志文件和配置文件。

####创建配置文件

在conf目录下创建一个文本文件作为配置文件，命名为nginx.conf。
写入如下内容:

```nginx
worker_processes  1;        #nginx worker 数量
error_log logs/error.log;   #指定错误日志文件路径
events {
    worker_connections 1024;
}
http {
    server {
		#监听端口，若你的6699端口已经被占用，则需要修改
        listen 6699;
        location / {
            default_type text/html;
            content_by_lua '
                ngx.say("HelloWorld")
            ';
        }
    }
}
```


####万事具备只欠东风

我们启动nginx即可，输入命令形式为：```nginx -p work_path/ -c conf/nginx.conf```，其中work_path为OpenResty的工作目录，也就是上面设定的，所以我这里就输入```nginx -p /openresty-test/ -c conf/nginx.conf```。如果没有提示错误，那就证明一切顺利了。如果提示nginx不存在，则需要在环境变量中加入安装路径，可以根据你的操作平台，参考前面的安装章节（一般需要重启生效）。

在浏览器地址栏中输入localhost:6699/或者在命令行输入```curl http://localhost:6699/```，其中6699要改为上面配置文件指定的相关端口，按下回车键，如果出现 `HelloWorld` 则说明一切顺利了。
