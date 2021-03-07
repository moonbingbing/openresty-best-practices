# 什么是火焰图

火焰图（[Flame Graph](https://github.com/brendangregg/FlameGraph)）是由 Linux 性能优化大师 [Brendan Gregg](http://www.brendangregg.com/) 发明的，和所有其他的 profiling 方法不同的是，火焰图以一个全局的视野来看待时间分布，它从底部往顶部，列出所有可能导致性能瓶颈的调用栈。

![](https://cdn.jsdelivr.net/gh/Miss-you/img/picgo/20201125024338.png)

火焰图整个图形看起来就像一个跳动的火焰，这就是它名字的由来。

火焰图有以下特征（这里以 on-cpu 火焰图为例）：

* 每一列代表一个调用栈，每一个格子代表一个函数；
* 纵轴展示了栈的深度，按照调用关系从下到上排列，最顶上格子代表采样时，正在占用 cpu 的函数；
* 横轴的意义是指：火焰图将采集的多个调用栈信息，通过按字母横向排序的方式将众多信息聚合在一起。需要注意的是它并不代表时间；
* 横轴格子的宽度代表其在采样中出现频率，所以一个格子的宽度越大，说明它是瓶颈原因的可能性就越大；
* 火焰图格子的颜色是随机的暖色调，方便区分各个调用信息；
* 其他的采样方式也可以使用火焰图， on-cpu 火焰图横轴是指 cpu 占用时间，off-cpu 火焰图横轴则代表阻塞时间；
* 采样可以是单线程、多线程、多进程甚至是多 host

## 常见采集工具

火焰图展现的一般是从进程（或线程）的堆栈中采集来的数据，即函数之间的调用关系。从堆栈中采集数据有很多方式，下面是几种常见的采集工具：

* perf
* eBPF
* SystemTap
* Performance Event
* DTrace
* OProfile
* Gprof

## 火焰图类型

常见的火焰图类型有 On-CPU，Off-CPU，还有 Memory，Hot/Cold，Differential 等等。他们分别适合处理什么样的问题呢？

这里笔者主要使用到的是 On-CPU、Off-CPU 以及 Memory 火焰图，所以这里仅仅对这三种火焰图作比较，也欢迎大家补充和斧正。

![](https://cdn.jsdelivr.net/gh/Miss-you/img/picgo/flame2.png)

> 可见，火焰图本身其实很简单，难的是从火焰图中发现问题，并且能够解释这种现象，从而找到优化系统或者解决问题的方法。
