#如何安装火焰图生成工具

####安装SystemTap
> 环境 CentOS 6.5 2.6.32-504.23.4.el6.x86_64 

SystemTap是一个诊断Linux系统性能或功能问题的开源软件，为了诊断系统问题或性能，开发者或调试人员只需要写一些脚本，然后通过SystemTap提供的命令行接口就可以对正在运行的内核进行诊断调试。

首先需要安装内核开发包和调试包（这一步非常重要并且最为繁琐）：

```
# #Installaion:
# rpm -ivh kernel-debuginfo-($version).rpm
# rpm -ivh kernel-debuginfo-common-($version).rpm
# rpm -ivh kernel-devel-($version).rpm    
```

其中$version使用linux命令 uname -r 查看，需要保证内核版本和上述开发包版本一致才能使用systemtap。([下载](http://debuginfo.centos.org))

安装systemtap：

```
# yum install systemtap
# ...
# 测试systemtap安装成功否：
# stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'

Pass 1: parsed user script and 103 library script(s) using 201628virt/29508res/3144shr/26860data kb, in 10usr/190sys/219real ms.
Pass 2: analyzed script: 1 probe(s), 1 function(s), 3 embed(s), 0 global(s) using 296120virt/124876res/4120shr/121352data kb, in 660usr/1020sys/1889real ms.
Pass 3: translated to C into "/tmp/stapffFP7E/stap_82c0f95e47d351a956e1587c4dd4cee1_1459_src.c" using 296120virt/125204res/4448shr/121352data kb, in 10usr/50sys/56real ms.
Pass 4: compiled C into "stap_82c0f95e47d351a956e1587c4dd4cee1_1459.ko" in 620usr/620sys/1379real ms.
Pass 5: starting run.
read performed
Pass 5: run completed in 20usr/30sys/354real ms.
```
如果出现如上输出表示安装成功。

####火焰图绘制

首先，需要下载ngx工具包：[Github地址](https://github.com/openresty/nginx-systemtap-toolkit)，该工具包即是用perl生成stap探测脚本并运行的脚本，如果是要抓lua级别的情况，请使用工具 ngx-sample-lua-bt

```
# ps -ef | grep nginx  （ps：得到类似这样的输出，其中15010即使worker进程的pid，后面需要用到）
hippo    14857     1  0 Jul01 ?        00:00:00 nginx: master process /opt/openresty/nginx/sbin/nginx -p /home/hippo/skylar_server_code/nginx/main_server/ -c conf/nginx.conf
hippo    15010 14857  0 Jul01 ?        00:00:12 nginx: worker process
# ./ngx-sample-lua-bt -p 15010 --luajit20 -t 5 > tmp.bt （-p 是要抓的进程的pid --luajit20|--luajit51 是luajit的版本 -t是探测的时间，单位是秒， 探测结果输出到tmp.bt）
# ./fix-lua-bt tmp.bt > flame.bt  (处理ngx-sample-lua-bt的输出，使其可读性更佳)
```

其次，下载Flame-Graphic生成包：[Github地址](https://github.com/brendangregg/FlameGraph),该工具包中包含多个火焰图生成工具，其中，stackcollapse-stap.pl才是为SystemTap抓取的栈信息的生成工具

```
# stackcollapse-stap.pl flame.bt > flame.cbt
# flamegraph.pl flame.cbt > flame.svg
```
如果一切正常，那么会生成flame.svg，这便是火焰图，用浏览器打开即可。

####问题回顾

在整个安装部署过程中，遇到的最大问题便是内核开发包和调试信息包的安装，找不到和内核版本对应的，好不容易找到了又不能下载，@！￥#@……%@#，于是升级了内核，在后面的过程便没遇到什么问题。
ps：如果在执行ngx-sample-lua-bt的时间周期内（上面的命令是5秒）,抓取的worker没有任何业务在跑，那么生成的火焰图便没有业务内容，不要惊讶哦~~~~~




