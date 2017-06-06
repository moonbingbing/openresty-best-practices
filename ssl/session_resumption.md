# TLS session resumption

在上一节我们介绍了 OCSP stapling。本节我们介绍另一种 HTTPS 性能优化的技巧，TLS session resumption。

一个完整的 TLS 握手需要两次：
1. Client 发送 ClientHello；Server 回复 ServerHello
1. Client 回复最终确定的 Key，Finished；Server 回复 Finished
1. 握手完毕，Client 发送加密后的 HTTP 请求；Server 回复加密后的 HTTP 响应

这一过程的花费是 2RTT（Round-Trip-Time）。意味着仅仅部署了 HTTPS，就会让你的 Web 应用的响应都慢上 2RTT。
花在信息传递过程中的延迟在整个响应时间的占比不容小觑，看看国内有多少 CDN 厂商就知道了。

为什么强调是“完整的”呢？因为通过 TLS session resumption，我们可以复用未过期的会话，把 RTT 减低到 1，甚至更低。

#### Session ID

Session ID 是最早的 TLS session resumption 方案。除了某些上古浏览器，大部分客户端都支持它。
Client 发送的 ClientHello 当中，就包含了一个 Session ID。服务器接收到 Session ID 之后，会返回之前存储的 SSL 会话。这么一来，
重建连接就只需一次 TLS 握手。

1. Client 发送 ClientHello（包含 Session ID）；Server 回复 ServerHello 和 Finished
1. 握手完毕，Client 发送加密后的 HTTP 请求；Server 回复加密后的 HTTP 响应

Nginx 自身支持 Session ID，但有个问题，它的会话最多只能存储在共享内存里面。服务器和客户端上次握手建立的会话，只有某个服务器自己
认得，换个服务器就忘光光了。当然你也可以要求负载均衡的时候只用 IP hash，尽管在实际情况中这么做不太现实。

OpenResty 提供了 `ssl_session_fetch_by_lua*` 和 `ssl_session_store_by_lua*` 这两个支持协程的阶段，
以及跟 Session id 相关的 `ngx.ssl.session` [模块](https://github.com/openresty/lua-resty-core/blob/master/lib/ngx/ssl/session.md)，
把存储的决定权交给开发者手中。
你可以把 session 放到独立的 Redis 或 Memcached 服务器上。

#### Session Tickets

不过你可能已经不需要额外折腾 `ssl_session_*` 的代码。因为 Session ID 已经过时了。
TLSv1.2 提供了名为 Session Tickets 的拓展，用来代替之前的 Session ID 方案。

Session ID 方案要求服务端记住会话状态，有违于 HTTP 服务无状态的特点。Session Tickets 方案旨在解决这个问题。

Session Tickets 跟 Session ID 差不多，只是有点关键上的不同：现在轮到由客户端记住会话状态。
服务端仅需记住当初用于加密返回给客户端的 Ticket 的密钥，以。
这么一来，只要在不同的服务器间共享同一个密钥，就能避免会话丢失的问题，不再需要独立的 Redis 或 Memcached 服务器。

1. Client 发送 ClientHello（包含 Session Ticket）；Server 回复 ServerHello 和 Finished
1. 握手完毕，Client 发送加密后的 HTTP 请求；Server 回复加密后的 HTTP 响应

对于 Nginx，你需要关注两个指令：`ssl_session_tickets` 和 `ssl_session_ticket_file`。

在高兴之余看下两个坏消息：
1. Session Tickets 不具有前向安全性，所以你需要定期轮换服务端用于加密的 ticket key。
2. 只有现代浏览器才支持这一 TLS 拓展。比如 Win7 下的 IE 就不支持。

#### 0 RTT!?

既然通过 Session ID/Tickets，我们已经把 RTT 减到了 1，能不能更进一步，减到 0？
初看像是天方夜谭，但最新的 TLSv1.3 确实允许做到这一点。

在继续之前先看下 TLSv1.3 的支持情况：Nginx 需要 1.13+ 的版本，外加 OpenSSL 1.1.1。客户端方面，截止到写作本文的时间，Firefox 和 Chrome 的 nightly build 版本均支持。

0 RTT 是 TLSv1.3 的可选功能。客户端和服务器第一次建立会话时，会生成一个 PSK（pre-shared key）。服务器会用 ticket key 去加密 PSK，作为 Session Ticket 返回。
客户端再次和服务器建立会话时，会先用 PSK 去加密 HTTP 请求，然后把加密后的内容发给服务器。服务器解密 PSK，然后再用 PSK 去解密 HTTP 请求，并加密 HTTP 响应。

1. Client 发送 ClientHello（包含 PSK）和加密后的 HTTP 请求；Server 回复 ServerHello 和 Finished 和加密后的 HTTP 响应。

这就完事了。

由于 HTTPS 握手已经跟 HTTP 请求合并到一起，确实是当之无愧的 0 RTT 呢。

在高兴之余看下两个坏消息：
1. PSK 不具有前向安全性，所以你依然需要定期轮换服务端用于加密的 ticket key。
2. 0 RTT 不提供 non-replayable 的保障，所以需要更上层的 HTTP 协议提供防重放的保障。比如只在幂等的 HTTP 方法中启用 0 RTT，或者实现额外的时序标记。
