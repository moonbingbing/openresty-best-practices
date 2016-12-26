# 集群功能
kong 是基于 OpenResty 开发的，简单来说就是 Nginx + Lua，Nginx 本身并没有提供集群功能，因此，kong 团队选择了第三方软件来实现[serf](https://www.serf.io/)。

```
Serf is a decentralized solution for cluster membership, failure detection, and orchestration. Lightweight and highly available.
```


## 为什么需要集群功能


## 集群功能实现方式
安装完成之后，就可以执行 serf 啦，kong 的安装包包含了 serf 的二进制版本，所以不需要编译。serf 是使用 go 语言实现的。
```
[vagrant@vagrant-102 ~]$ serf version
Serf v0.7.0
Agent Protocol: 4 (Understands back to: 2)
```

主要实现代码在 kong/serf.Lua, 简单来说就是封装了一下命令行程序 serf，当集群加入新节点的时候，或是有 API 配置更新时，更新数据库并通知其他集群成员。

**需要注意的是，serf 底层使用 gossip 协议实现，而 gossip 协议使用 UDP 协议通信，这就决定了自定义事件的参数字节数不能超过 512 字节**
