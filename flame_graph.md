# 火焰图

火焰图是定位疑难杂症的神器，比如CPU占用高、内存泄漏等问题。特别是Lua级别的火焰图，可以定位到函数和代码级别。

下图来自openresty的[官网](http://openresty.org/download/user-flamegraph.svg)，显示的是一个正常运行的openresty应用的火焰图，先不用了解细节，有一个直观的了解。

![Alt text](http://openresty.org/download/user-flamegraph.svg)

里面的颜色是随机选取的，并没有特殊含义。火焰图的数据来源，是通过[systemtap](https://sourceware.org/systemtap/)定期收集。