# 如何定位问题

一个正常的火焰图，应该呈现出如[官网](http://openresty.org/download/user-flamegraph.svg)给出的样例（官网的火焰图是抓C级别函数）：
![正常](Flame-Graphic.svg)

从上图可以看出，正常业务下的火焰图形状类似的“山脉”，“山脉”的“海拔”表示worker中业务函数的调用深度，“山脉”的“长度”表示worker中业务函数占用cpu的比例。

下面将用一个实际应用中遇到问题抽象出来的示例来说明如何通过火焰图定位问题。

问题表现，nginx worker运行一段时间后出现CPU占用100%的情况，reload后一段时间后复现，当出现CPU占用率高情况的时候是某个worker 占用率高。

问题分析，单worker cpu高的情况一定是某个input中包含的信息不能被lua函数以正确地方式处理导致的，因此上火焰图找出具体的函数，抓取的过程需要抓取C级别的函数和lua级别的函数，抓取相同的时间，两张图一起分析才能得到准确的结果。

抓取步骤：

1. [安装SystemTap](install.md);
2. 获取CPU异常的worker的进程ID；
>ps -ef | grep nginx

3. 使用[ngx-sample-lua-bt](https://github.com/openresty/nginx-systemtap-toolkit)抓取栈信息,并用fix-lua-bt工具处理；
>./ngx-sample-lua-bt -p 9768 --luajit20 -t 5 > tmp.bt  
./fix-lua-bt tmp.bt > a.bt
4. 使用[stackcollapse-stap.pl和](https://github.com/brendangregg/FlameGraph)；
>./stackcollapse-stap.pl a.bt > a.cbt  
./flamegraph.pl a.cbt > a.svg
5. a.svg即是火焰图，拖入浏览器即可，
![problem](flame_graphic_problem.svg)
6. 从上图可以清楚的看到get_serial_id这个函数占用了绝大部分的CPU比例，问题的排查可以从这里入手，找到其调用栈中异常的函数。


ps：一般来说一个正常的火焰图看起来像一座座连绵起伏的“山峰”，而一个异常的火焰图看起来像一座“平顶山”。

