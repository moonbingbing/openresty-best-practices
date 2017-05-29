# 如何安装火焰图生成工具

#### 安装 SystemTap

SystemTap 是一个诊断 Linux 系统性能或功能问题的开源软件，为了诊断系统问题或性能，开发者或调试人员只需要写一些脚本，然后通过 SystemTap 提供的命令行接口就可以对正在运行的内核进行诊断调试。

> 在 CentOS 上的安装方法

首先需要安装当前内核版本对应的开发包和调试包（这一步非常重要并且最为繁琐）：

```
# #Installaion:
# rpm -ivh kernel-debuginfo-$(uname -r).rpm
# rpm -ivh kernel-debuginfo-common-$(uname -r).rpm
# rpm -ivh kernel-devel-$(uname -r).rpm
```

这些 rpm 包可以在该网址中下载：
http://debuginfo.centos.org

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

> 在 Ubuntu 上的安装方法

对于 Ubuntu 上的安装，参考 Ubuntu 官方维护的一个 wiki：
https://wiki.ubuntu.com/Kernel/Systemtap

一般来说，仅需引入 ddeb 源，然后 `apt-get` 就能解决了。

由于 systemtap 需要依赖某些内核特性，对于 `Ubuntu Gutsy` (或更老的版本)，必须重新编译内核。
编译的步骤参见 systemtap 的这篇 wiki：
https://sourceware.org/systemtap/wiki/SystemtapOnUbuntu

另外，由于 Ubuntu 16.04 官方库里的 systemtap 版本过旧（version 2.9），从 `apt-get` 安装的 systemtap 有些情况下并不能正确地运行。
这时候需要从 systemtap 源码中编译出可用的 systemtap。
编译的过程参考 systemtap 的这篇文档：
https://sourceware.org/git/?p=systemtap.git;a=blob_plain;f=README;hb=HEAD

大体上就这几步：
```
# 下载依赖……
sudo apt install elfutils
sudo apt-get build-dep systemtap

# 下载最新的版本
wget/git ...

# 构建，并祈祷能一次成功
./configure
make all
[sudo] make install
```

#### 火焰图绘制

首先，需要下载 stapxx 工具包：[Github地址](https://github.com/openresty/stapxx)。
该工具包中包含用 perl 写的，会生成 stap 探测代码并运行的脚本。如果是要抓 Lua 级别的情况，请使用其中的 lj-lua-stacks.sxx。
由于 lj-lua-stacks.sxx 输出的是文件绝对路径和行号，要想匹配具体的 Lua 代码，需要用 [fix-lua-bt](https://github.com/openresty/openresty-systemtap-toolkit#fix-lua-bt) 进行转换。

```
# ps -ef | grep nginx  （ps：得到类似这样的输出，其中15010即使worker进程的pid，后面需要用到）
hippo    14857     1  0 Jul01 ?        00:00:00 nginx: master process /opt/openresty/nginx/sbin/nginx -p /home/hippo/skylar_server_code/nginx/main_server/ -c conf/nginx.conf
hippo    15010 14857  0 Jul01 ?        00:00:12 nginx: worker process
# ./samples/lj-lua-stacks.sxx --arg time=5 --skip-badvars -x 15010 > tmp.bt （-x 是要抓的进程的 pid， 探测结果输出到 tmp.bt）
# ./fix-lua-bt tmp.bt > flame.bt  (处理 lj-lua-stacks.sxx 的输出，使其可读性更佳)
```

其次，下载 Flame-Graphic 生成包：[Github地址](https://github.com/brendangregg/FlameGraph),该工具包中包含多个火焰图生成工具，其中，stackcollapse-stap.pl 才是为 SystemTap 抓取的栈信息的生成工具

```
# stackcollapse-stap.pl flame.bt > flame.cbt
# flamegraph.pl flame.cbt > flame.svg
```
如果一切正常，那么会生成 flame.svg，这便是火焰图，用浏览器打开即可。

ps：如果在执行 lj-lua-stacks.sxx 的时间周期内（上面的命令是 5 秒）, 抓取的 worker 没有任何业务在跑，那么生成的火焰图便没有业务内容。为了让生成的火焰图更有代表性，我们通常都会在抓取的同时进行压测。
