# 什么时候使用

一般来说，当发现 CPU 的占用率和实际业务应该出现的占用率不相符，或者对 Nginx worker 的资源使用率（CPU，内存，磁盘 IO ）出现怀疑的情况下，都可以使用火焰图进行抓取。另外，对 CPU 占用率低、吐吞量低的情况也可以使用火焰图的方式排查程序中是否有阻塞调用导致整个架构的吞吐量低下。

常用的火焰图有三种：
* [lj-lua-stacks.sxx](https://github.com/openresty/stapxx#lj-lua-stacks) 用于绘制 Lua 代码的火焰图
* [sample-bt](https://github.com/openresty/openresty-systemtap-toolkit#sample-bt) 用于绘制 C 代码的火焰图
* [sample-bt-off-cpu](https://github.com/openresty/openresty-systemtap-toolkit#sample-bt-off-cpu) 用于绘制 C 代码执行过程中让出 CPU 的时间（阻塞时间）的火焰图

这三种火焰图的用法相似，输出格式一致，所以接下的章节中我们只介绍最为常用的 lj-lua-stacks.sxx。
