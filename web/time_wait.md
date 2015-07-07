# TIME_WAIT
这个是高并发服务端常见的一个问题，一般的做法是修改sysctl的参数来解决。
但是，做为一个有追求的程序猿，你需要多问几个为什么，为什么会出现TIME_WAIT？出现这个合理吗？

我们需要先回顾下tcp的知识，请看下面的状态转换图（图片来自[「The TCP/IP Guide」](http://www.tcpipguide.com/)）：
![tcp](/web/tcp.png)

因为TCP连接是双向的，所以在关闭连接的时候，两个方向各自都需要关闭。
先发FIN包的一方执行的是主动关闭；后发FIN包的一方执行的是被动关闭。
***主动关闭的一方会进入TIME_WAIT状态，并且在此状态停留两倍的MSL时长。***

修改sysctl的参数，只是控制TIME_WAIT的数量。在你的应用场景里面，

注：本文内容参考了[火丁笔记](http://huoding.com/2013/12/31/316)和[Nginx开发从入门到精通 ](http://tengine.taobao.org/book/chapter_02.html)，感谢大牛的分享。
