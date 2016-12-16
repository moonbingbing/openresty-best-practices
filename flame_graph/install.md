# 如何安装火焰图生成工具

#### 安装 SystemTap

> 环境 CentOS 6.5 2.6.32-504.23.4.el6.x86_64

SystemTap 是一个诊断 Linux 系统性能或功能问题的开源软件，为了诊断系统问题或性能，开发者或调试人员只需要写一些脚本，然后通过 SystemTap 提供的命令行接口就可以对正在运行的内核进行诊断调试。

首先需要安装内核开发包和调试包（这一步非常重要并且最为繁琐）：

```
# #Installaion:
# rpm -ivh kernel-debuginfo-($version).rpm
# rpm -ivh kernel-debuginfo-common-($version).rpm
# rpm -ivh kernel-devel-($version).rpm
```

其中$version 使用 linux 命令 uname -r 查看，需要保证内核版本和上述开发包版本一致才能使用 systemtap。([下载](http://debuginfo.centos.org))

安装 systemtap：

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

> 在 Ubuntu 14.04 Desktop 上的安装方法

打开 Systemtap Ubuntu 系统安装官方 [wiki](https://sourceware.org/systemtap/wiki/SystemtapOnUbuntu) 地址，获取 systemtap 安装包：

```shell
sudo apt-get install systemtap
```

其次我们还需要内核支持（具有 CONFIG_DEBUG_FS, CONFIG_DEBUG_KERNEL, CONFIG_DEBUG_INFO 和 CONFIG_KPROBES 标识的内核，不需要重新编译内核）。对于 `Ubuntu Gutsy` (或更老的版本)，必须重新编译内核。

生成 ddeb repository 配置：

```
# cat > /etc/apt/sources.list.d/ddebs.list << EOF
deb http://ddebs.ubuntu.com/ precise main restricted universe multiverse
EOF

etc.

# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECDCAD72428D7C01
# apt-get update
```

针对 Ubuntu 14.04 版本（其他版本，只要不太老，相差不大），我们按照下面顺序尝试重新编译内核：

```
# uname -r
3.13.0-34-generic
# dpkg --list | grep linux | grep 3.13.0-34-generic
ii  linux-headers-3.13.0-34-generic                       3.13.0-34.60
amd64        Linux kernel headers for version 3.13.0 on 64 bit x86 SMP
ii  linux-image-3.13.0-34-generic                         3.13.0-34.60
amd64        Linux kernel image for version 3.13.0 on 64 bit x86 SMP
ii  linux-image-extra-3.13.0-34-generic                   3.13.0-34.60
amd64        Linux kernel extra modules for version 3.13.0 on 64 bit x86 SMP
# apt-get install linux-image-3.13.0-34-generic
```

上面的输出比较乱，大家要跟紧一条主线，`3.13.0-34-generic` 也就是 `uname -r` 的输出结果（如果您的系统和这个不一样，请自行更改），结合刚刚给出的 systemtap 官方 wiki 我们可以知道，正确的安装包地址应当是 `linux-image-**` 开头。这样我们，就可以很容易找到 `linux-image-3.13.0-34-generic` 是我们需要的。

#### 火焰图绘制

首先，需要下载 ngx 工具包：[Github地址](https://github.com/openresty/nginx-systemtap-toolkit)，该工具包即是用 perl 生成 stap 探测脚本并运行的脚本，如果是要抓 Lua 级别的情况，请使用工具 ngx-sample-lua-bt

```
# ps -ef | grep nginx  （ps：得到类似这样的输出，其中15010即使worker进程的pid，后面需要用到）
hippo    14857     1  0 Jul01 ?        00:00:00 nginx: master process /opt/openresty/nginx/sbin/nginx -p /home/hippo/skylar_server_code/nginx/main_server/ -c conf/nginx.conf
hippo    15010 14857  0 Jul01 ?        00:00:12 nginx: worker process
# ./ngx-sample-lua-bt -p 15010 --luajit20 -t 5 > tmp.bt （-p 是要抓的进程的pid --luajit20|--luajit51 是LuaJIT的版本 -t是探测的时间，单位是秒， 探测结果输出到tmp.bt）
# ./fix-lua-bt tmp.bt > flame.bt  (处理ngx-sample-lua-bt的输出，使其可读性更佳)
```

其次，下载 Flame-Graphic 生成包：[Github地址](https://github.com/brendangregg/FlameGraph),该工具包中包含多个火焰图生成工具，其中，stackcollapse-stap.pl 才是为 SystemTap 抓取的栈信息的生成工具

```
# stackcollapse-stap.pl flame.bt > flame.cbt
# flamegraph.pl flame.cbt > flame.svg
```
如果一切正常，那么会生成 flame.svg，这便是火焰图，用浏览器打开即可。

#### 问题回顾

在整个安装部署过程中，遇到的最大问题便是内核开发包和调试信息包的安装，找不到和内核版本对应的，好不容易找到了又不能下载，@！￥#@……% @#，于是升级了内核，在后面的过程便没遇到什么问题。
ps：如果在执行 ngx-sample-lua-bt 的时间周期内（上面的命令是 5 秒）, 抓取的 worker 没有任何业务在跑，那么生成的火焰图便没有业务内容，不要惊讶哦 ~~~~~




