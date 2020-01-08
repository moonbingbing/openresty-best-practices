OpenResty 最佳实践
=======

我们提供 OpenResty、Apache APISIX 以及 API 网关方面相关的咨询、培训、性能优化、定制开发等商业支持服务，欢迎联系。
微信：ming69371, 邮箱：wenming#apache.org
- - -

在 2012 年的时候，加入到奇虎 360 公司，为新的产品做技术选型。由于之前一直混迹在 Python 圈子里面，也接触过 Nginx C 模块的高性能开发，一直想找到一个兼备 Python 快速开发和 Nginx C 模块高性能的产品。看到 OpenResty 后，有发现新大陆的感觉。

于是在新产品里面力推 OpenResty，团队里面几乎没人支持，经过几轮性能测试，虽然轻松击败所有的其他方案，但是其他开发人员并不愿意参与到基于 OpenResty 这个“陌生”框架的开发中来。于是我开始了一个人的 OpenResty 之旅，刚开始经历了各种技术挑战，庆幸有详细的文档，以及春哥和邮件列表里面热情的帮助，成了团队里面 bug 最少和几乎不用加班的同学。

2014 年，团队进来了一批新鲜血液，很有技术品味，先后选择 OpenResty 来作为技术方向。不再是一个人在战斗，而另外一个新问题摆在团队面前，如何保证大家都能写出高质量的代码，都能对 OpenResty 有深入的了解？知识的沉淀和升华，成为一个迫在眉睫的问题。

我们选择把这几年的一些浅薄甚至可能是错误的实践，通过 gitbook 的方式公开出来，一方面有利于团队自身的技术积累，另一方面，也能让更多的高手一起加入，让 OpenResty 的使用变得更加简单，更多的应用到服务端开发中，毕竟人生苦短，少一些加班，多一些陪家人。

这本书的定位是最佳实践，同时会对 OpenResty 做简单的基础介绍。但是我们对初学者的建议是，在看书的同时下载并安装 OpenResty，把[官方网站](http://openresty.org/)的 Presentations 浏览和实践几遍。

请 **一直** 使用最新的 OpenResty 版本来运行本书的代码。

希望你能 enjoy OpenResty 之旅！

- - -

[在 gitbook 上查看本书](http://moonbingbing.gitbooks.io/openresty-best-practices/content/index.html)

本书源码在 GitHub 上维护，欢迎参与：[我要写书](https://github.com/moonbingbing/openresty-best-practices)。也可以加入 QQ 群来和我们交流：

- 34782325（技术交流 ①群）
- 481213820（技术交流 ②群）
- 124613000（技术交流 ③群 已满）
- 679145170（技术交流 ④群）

**作者极客时间专栏：[《OpenResty 从入门到实战》](http://gk.link/a/103tv)**
![](./images/OpenResty图谱-二维码.jpg)
