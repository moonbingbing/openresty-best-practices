# 协议无痛升级

使用度最高的通讯协议，一定是 HTTP 了。优点有多少，相信大家肯定有切身体会。我相信每家公司对 HTTP 的使用都有自己的规则，甚至偏好。这东西没有谁对谁错，符合业务需求、量体裁衣是王道。这里我们想通过亲身体验，告诉大家用好 OpenResty 的一些特性，会给我们带来惊喜。

在产品开发初期，由于其存在极大的不确定性、不稳定性，所以要暴露给开发团队、测试团队完全透明的传输协议，所以我们 1.0 版本就是一个没有任何安全处理的明文版本： HTTP + JSON。但随着产品功能的丰富，质量的逐步提高，具备了一定的交付能力，这时候通讯协议就必须要升级了。

为了更好的安全、效率控制，我们需要支持压缩、防篡改、防重复、简单加密等特性，为此我们设计了全新 2.0 通讯协议。如何让这个协议升级无感知、改动少，并且简单呢？

> 1.0 明文协议配置

```nginx
location ~ ^/api/([-_a-zA-Z0-9/]+).json {
    content_by_lua_file /path/to/lua/api/$1.lua;
}
```

> 1.0 明文协议引用示例：

```shell
# curl http://ip:port/api/hearbeat.json?key=value -d '...'
```

> 2.0 密文协议引用示例：

```shell
# curl http://ip:port/api/hearbeat.json?key=value&ver=2.0 -d '...'
```

从引用示例中看到，我们的密文协议主要都是在请求 `body` 中做的处理。最生硬的办法就是我们在每个业务入口、出口分别做协议的解析、编码处理。如果你只有几个 API 接口，那么直来直去的修改所有 API 接口源码，最为直接，容易理解。但如果你需要修改几十个 API 入口，那就要静下来考虑一下，修改的代价是否完全可控。

最后我们使用了 OpenResty 阶段的概念完成协议的转换。

```nginx
location ~ ^/api/([-_a-zA-Z0-9/]+).json {
    access_by_lua_file  /path/to/lua/api/protocal_decode.lua;
    content_by_lua_file /path/to/lua/api/$1.lua;
    body_filter_by_lua_file  /path/to/lua/api/protocal_encode.lua;
}
```

> 内部处理流程说明：

* Nginx 中这三个阶段的执行顺序：access --> content --> body_filter；
* access_by_lua_file：获取协议版本 --> 获取 body 数据 --> 协议解码 --> 设置 body 数据；
* content_by_lua_file：正常业务逻辑处理，零修改；
* body_filter_by_lua_file：判断协议版本 --> 协议编码。

刚好前些日子春哥公开了一篇 GitHub 通过引入 OpenResty 解决了 SSL 证书的问题，他们的解决思路和我们差不多。都是利用 `access` 阶段做一些非标准 HTTP(S)上的自定义修改，但对于已有业务是不需要任何感知的。

我们这个通讯协议的无痛升级，实际上是有很多玩法可以实现，如果我们的业务从一开始有个相对稳定的框架，可能完全不需要操这个心。没有引入框架的原因，一来是现在没有哪个框架比较成熟，二来是从基础开始更容易摸到细节。对于目前 OpenResty 可参考资料少的情况下，我们更倾向于从最小工作集开始，减少不确定性、降低复杂度。

也许在后面，我们会推出自有的开发框架，用来统一规避现在碰到的问题，提供完整、可靠、高效的解决方案，我们正在努力ing，请大家拭目以待。

