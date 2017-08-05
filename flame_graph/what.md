# 什么是火焰图

火焰图和直方图、曲线图一样，是一种分析数据的方式，它可以更直观、更形象地展示数据，让人很容易发现数据中的隐藏信息。之所以叫火焰图，是因为这种图很像一簇火焰。

火焰图展现的一般是从进程（或线程）的堆栈中采集来的数据，即函数之间的调用关系。从堆栈中采集数据有很多方式，下面是几种常见的采集工具：

* Performance Event
* SystemTap
* DTrace
* OProfile
* Gprof

数据采集到了，怎么分析它呢？为此，[Brendan Gregg](http://www.brendangregg.com/)开发了专门把采样到的堆栈轨迹（Stack Trace）转化为直观图片显示的工具——[Flame Graph](https://github.com/brendangregg/FlameGraph)，这样就很容易生成火焰图了。

可见，火线图本身其实很简单，难的是从火焰图中发现问题，并且能够解释这种现象，从而找到优化系统或者解决问题的方法。
