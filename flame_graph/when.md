# 什么时候使用

一般来说，当发现 CPU 的占用率和实际业务应该出现的占用率不相符，或者对 Nginx worker 的资源使用率（CPU，内存，磁盘 IO ）出现怀疑的情况下，都可以使用火焰图进行抓取。另外，对 CPU 占用率低、吐吞量低的情况也可以使用火焰图的方式排查程序中是否有阻塞调用导致整个架构的吞吐量低下。


[OpenResty 官方](https://github.com/openresty/nginx-systemtap-toolkit)提供的由 perl 实现的栈抓取的程序是一个傻瓜化的 stap 脚本，如果有需要可以自行使用 stap 进行栈的抓取并生成火焰图，各位看官可以自行尝试。
