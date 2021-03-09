# 如何定位问题

一个正常的火焰图，应该呈现出如 [官网](http://openresty.org/download/user-flamegraph.svg) 给出的样例（官网的火焰图是抓 C 级别函数）：
![正常](../images/Flame-Graphic.svg)

从上图可以看出，正常业务下的火焰图形状类似的“山脉”，“山脉”的“海拔”表示 worker 中业务函数的调用深度，“山脉”的“长度”表示 worker 中业务函数占用 CPU 的比例。

## 具体案例

下面将用一个实际应用中遇到的问题抽象出来的示例（CPU 占用过高）来说明如何通过火焰图定位问题。

#### 问题表现：
Nginx worker 运行一段时间后出现 CPU 占用 100% 的情况，reload 后一段时间后复现，当出现 CPU 占用率高情况的时候是某个 worker 占用率高。

#### 问题分析：
单 worker CPU 高的情况一定是某个 input 中包含的信息不能被 Lua 函数以正确地方式处理导致的，因此上火焰图找出具体的函数，抓取的过程需要抓取 C 级别的函数和 Lua 级别的函数，抓取相同的时间，两张图一起分析才能得到准确的结果。

## 绘制流程

要生成火焰图，必须要有一个顺手的动态追踪工具，如果操作系统是 Linux 的话，那么通常通常是 perf 或者 systemtap 中的一种。其中 perf 相对更常用，多数 Linux 都包含了 perf 这个工具，可以直接使用；SystemTap 则功能更为强大，监控也更为灵活。网上关于如何使用 perf 绘制火焰图的文章非常多而且丰富，所以本文将以 SystemTap 为例。

使用 SystemTap 绘制火焰图的主要流程如下：

* 安装 SystemTap 以及 操作系统符号调试表
* 根据自己所需绘制的火焰图类型以及进程类型选择合适的脚本
* 生成内核模块
* 运行 SystemTap 或者运行生成的内核模块统计数据
* 将统计数据转换成火焰图

### 安装 SystemTap 以及 操作系统符号调试表

使用 yum 工具安装 systemtap:

```plain
yum install systemtap systemtap-runtime
```

由于 systemtap 工具依赖于完整的调试符号表，而且生产环境不同机器的内核版本不同（虽然都是 Tlinux 2.2 版本，但是内核版本后面的小版本不一样，可以通过 `uname -a` 命令查看）所以我们还需要安装 kernel-debuginfo 包、 kernel-devel 包

我这里是安装了这两个依赖包

```plain
kernel-devel-3.10.107-1-tlinux2-0046.x86_64
kernel-debuginfo-3.10.107-1-tlinux2-0046.x86_64
```

### 根据自己所需绘制的火焰图类型以及进程类型选择合适的脚本

使用 SystemTap 统计相关数据往往需要自己依照它的语法，编写脚本，具有一定门槛。幸运的是，github 上春哥（agentzh）开源了两组他常用的 SystemTap 脚本：[openresty-systemtap-toolkit](https://github.com/openresty/openresty-systemtap-toolkit) 和 [stapxx](https://github.com/openresty/stapxx)，这两个工具集能够覆盖大部分 C 进程、nginx 进程以及 Openresty 进程的性能问题场景。

### 初探 SystemTap 机制

Systemtap 执行流程如下：

![](https://cdn.jsdelivr.net/gh/Miss-you/img/picgo/flame3.png)

* parse：分析脚本语法
* elaborate：展开脚本 中定义的探针和连接预定义脚本库，分析内核和内核模块的调试信息
* translate：. 将脚本编译成 c 语言内核模块文件放 在$HOME/xxx.c 缓存起来，避免同一脚本多次编译
* build：将 c 语言模块文件编译成。ko 的内核模块，也缓存起来。
* 把模块交给 staprun，staprun 加载内核模块到内核空间，stapio 连接内核模块和用户空间，提供交互 IO 通道，采集数据。

### 采集数据

* 获取 CPU 异常的 worker 的进程 ID ：

    ```shell
    $ ps -ef | grep nginx
    ```

* 使用 [lj-lua-stacks.sxx](https://github.com/openresty/stapxx#lj-lua-stacks) 抓取栈信息，并用 [fix-lua-bt](https://github.com/openresty/openresty-systemtap-toolkit#fix-lua-bt) 工具处理：

    ```shell
    # making the ./stap++ tool visible in PATH:
    $ export PATH=$PWD:$PATH

    # assuming the nginx worker process pid is 6949:
    $ ./samples/lj-lua-stacks.sxx --arg time=5 --skip-badvars -x 6949 > tmp.bt
    Start tracing 6949 (/opt/nginx/sbin/nginx)
    Please wait for 5 seconds

    $ ./fix-lua-bt tmp.bt > a.bt
    ```

### 将数据转换成火焰图

获得了统计数据 `a.bt` 后，便可以使用火焰图工具绘制火焰图了

* 使用 [stackcollapse-stap.pl 和 flamegraph.pl](https://github.com/brendangregg/FlameGraph)：

    ```shell
    $ ./stackcollapse-stap.pl a.bt > a.cbt
    $ ./flamegraph.pl a.cbt > a.svg
    ```
    
* a.svg 即是火焰图，拖入浏览器即可：
![problem](../images/flame_graphic_problem.svg)

* 从上图可以清楚地看到 `get_serial_id` 这个函数占用了绝大部分的 CPU 比例，问题的排查可以从这里入手，找到其调用栈中异常的函数。

## 火焰图分析技巧

1. 纵轴代表调用栈的深度（栈桢数），用于表示函数间调用关系：下面的函数是上面函数的父函数；
2. 横轴代表调用频次，一个格子的宽度越大，越说明其可能是瓶颈原因；
3. 不同类型火焰图适合优化的场景不同，比如 on-cpu 火焰图适合分析 cpu 占用高的问题函数，off-cpu 火焰图适合解决阻塞和锁抢占问题；
4. 无意义的事情：横向先后顺序是为了聚合，跟函数间依赖或调用关系无关；火焰图各种颜色是为方便区分，本身不具有特殊含义；
5. 多练习：进行性能优化有意识的使用火焰图的方式进行性能调优（如果时间充裕）；
