# 与Docker使用的网络瓶颈

Docker 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口（类似 iPhone 的 app）。几乎没有性能开销,可以很容易地在机器和数据中心中运行。最重要的是,他们不依赖于任何语言、框架包括系统。

Docker自2013年以来非常火热，无论是从 github 上的代码活跃度，还是Redhat在RHEL6.5中集成对Docker的支持, 就连 Google 的 Compute Engine 也支持 docker 在其之上运行。

在360企业版安全中，我们使用Docker的原因和目的，可能与其他公司不太一样。我们一直存在比较特殊的"分发"需求，Docker主要是用来屏蔽企业用户平台的不一致性。我们的企业用户使用的系统比较杂，仅仅主流系统就有Ubantu, Centos，RedHat，AIX，还有一些定制裁减系统等，百花齐放。

虽然OpenResty具有良好的跨平台特性，无奈我们的安全项目比较重，组件比较多，是不可能逐一适配不通平台的，工作量、稳定性等，难度和后期维护复杂度是难以想象的。如果您的应用和我们一样需要二次分发，非常建议考虑使用docker。这个年代是云的时代，二次分发其实成本很高，后期维护陈本也很高，所以尽量做到云端。

说说Docker与OpenResty之间的"坑"吧，你们肯定对这个更感兴趣。

我们刚开始使用的时候，是这样启动的：

```
docker run -d -p 80:80 openresty 
```

首次压测过程中发现Docker进程CPU占用率100%，单机接口4-5万的QPS就上不去了。经过我们多方探讨交流，终于明白原来是网络瓶颈所致（OpenResty太彪悍，Docker默认的虚拟网卡受不了了 ^_^）。

最终我们绕过这个默认的桥接网卡，使用`--net`参数即可完成。

```
docker run -d -p --net=host 80:80 openresty 
```

多么简单，就这么一个参数，居然困扰了我们好几天。一度怀疑我们是否要忍受引入docker带来的低效率网络。所以有时候多出来交流、学习，真的可以让我们学到好多。虽然这个点是我们自己挖出来的，但是在交流过程中还学到了很多好东西。

> Docker Network settings，引自：http://www.lupaworld.com/article-250439-1.html

```
默认情况下，所有的容器都开启了网络接口，同时可以接受任何外部的数据请求。
--dns=[]         : Set custom dns servers for the container
--net="bridge"   : Set the Network mode for the container
                          'bridge': creates a new network stack for the container on the docker bridge
                          'none': no networking for this container
                          'container:<name|id>': reuses another container network stack
                          'host': use the host network stack inside the container
--add-host=""    : Add a line to /etc/hosts (host:IP)
--mac-address="" : Sets the container's Ethernet device's MAC address
```


你可以通过`docker run --net none`来关闭网络接口，此时将关闭所有网络数据的输入输出，你只能通过STDIN、STDOUT或者files来完成I/O操作。默认情况下，容器使用主机的DNS设置，你也可以通过`--dns`来覆盖容器内的DNS设置。同时Docker为容器默认生成一个MAC地址，你可以通过`--mac-address 12:34:56:78:9a:bc`来设置你自己的MAC地址。

Docker支持的网络模式有：

* none。关闭容器内的网络连接
* bridge。通过veth接口来连接容器，默认配置。
* host。允许容器使用host的网络堆栈信息。 注意：这种方式将允许容器访问host中类似D-BUS之类的系统服务，所以认为是不安全的。
* container。使用另外一个容器的网络堆栈信息。 　　

#### None模式

将网络模式设置为none时，这个容器将不允许访问任何外部router。这个容器内部只会有一个loopback接口，而且不存在任何可以访问外部网络的router。

#### Bridge模式

Docker默认会将容器设置为bridge模式。此时在主机上面将会存在一个docker0的网络接口，同时会针对容器创建一对veth接口。其中一个veth接口是在主机充当网卡桥接作用，另外一个veth接口存在于容器的命名空间中，并且指向容器的loopback。Docker会自动给这个容器分配一个IP，并且将容器内的数据通过桥接转发到外部。

#### Host模式

当网络模式设置为host时，这个容器将完全共享host的网络堆栈。host所有的网络接口将完全对容器开放。容器的主机名也会存在于主机的hostname中。这时，容器所有对外暴露的端口和对其它容器的连接，将完全失效。

#### Container模式

当网络模式设置为Container时，这个容器将完全复用另外一个容器的网络堆栈。同时使用时这个容器的名称必须要符合下面的格式：--net container:<name|id>.

比如当前有一个绑定了本地地址localhost的Redis容器。如果另外一个容器需要复用这个网络堆栈，则需要如下操作：

```
$ sudo docker run -d --name redis example/redis --bind 127.0.0.1
$ # use the redis container's network stack to access localhost
$ sudo docker run --rm -ti --net container:redis example/redis-cli -h 127.0.0.1
```
