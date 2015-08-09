#HelloWorld

HelloWorld是我们恒古不变的第一个入门程序。但是OpenResty不是一门编程语言，跟编程语言的HelloWorld不一样，来得相对复杂一点。要在OpenResty上实现HelloWorld先要启动它，要启动它则要有个配置文件来指定它的工作参数（比如指定监听端口，日志文件等）。

####设定工作目录

为了工作目录与安装目录互不干扰，我们另外创建一个OpenResty的工作目录来练习。我选择在根目录创建一个openresty-test目录，输入命令为：mkdir /openresty-test。你可以创建你喜欢的目录名字，或者不创建。

上面说了要指定它的工作参数，为此，我们单独创建一个存放配置文件的目录和日志的目录。输入命令cd /openresty-test，进入工作目录。然后输入命令 mkdir logs/ conf/,创建logs和conf子目录存放日志文件和配置文件。

####创建配置文件

在conf目录下创建一个文本文件作为配置文件，命名为nginx.conf。
写入如下内容:

```
worker_processes  1;
 #指定错误日志文件路径
error_log logs/error.log;
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
我们启动nginx即可。输入命令：nginx -p `pwd`/ -c conf/nginx.conf，其中pwd为OpenResty的工作目录，也就是上面设定的，所以我这里就输入nginx -p /openresty-test/ -c conf/nginx.conf。如果没有提示错误，那就证明一切顺利了。如果提示nginx命令不存在，则需要在环境变量中加入安装路径，可以根据你的操作平台，参考前面的安装章节。

在浏览器输入//localhost:6699/或者在命令行输入curl http://localhost:6699/，看看有没有HelloWorld出现。如果显式HelloWorld则说明一切顺利了。
