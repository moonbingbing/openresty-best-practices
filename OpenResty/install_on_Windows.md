# Windows平台下OpenResty的安装

1、下载Windows版的OpenResty压缩包，这里我下载的是Openresty_For_Windows_1.7.10.2001_64Bit，下载链接： [http://pan.baidu.com/s/1kTxmfmJ](http://pan.baidu.com/s/1kTxmfmJ)，你也可以选择32Bit的版本，下载链接[http://pan.baidu.com/s/1pJ5l1s3](http://pan.baidu.com/s/1pJ5l1s3)。如果你对源码感兴趣，下面是源码链接[https://github.com/LomoX-Offical/nginx-openresty-windows](https://github.com/LomoX-Offical/nginx-openresty-windows)。

2、解压到要安装的目录，这里我选择D盘根目录，你可以根据自己的喜好选择位置。

3、进入到Openresty_For_Windows_1.7.10.2001_64Bit目录，双击执行nginx.exe 或者使用命令start nginx启动nginx，如果没有错误现在nginx已经开始运行了。

4、验证nginx是否成功启动：

   * a、使用tasklist /fi "imagename eq nginx.exe"命令查看nginx进程，下面是在我电脑上的截图，其中一个是master进程，另一个是worker进程。

  ![nginx进程](install_on_Windows01.png)

   * b、在浏览器的地址栏输入localhost，加载nginx的欢迎页面。成功加载说明nginx正在运行。下面是在我电脑上的截图：

  ![nginx的欢迎页面](install_on_Windows02.png)

另外当nginx成功启动后，master进程的pid存放在logs\nginx.pid文件中。

注：OpenResty官方没有提供Windows版本的OpenResty，这里使用的是张家柱、蔡东赟把OpenResty迁移到Windows下的版本。
