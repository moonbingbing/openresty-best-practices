# 禁止某些终端访问

不同的业务应用场景，会有完全不同的非法终端控制策略，常见的限制策略有终端IP、访问域名端口，这些可以通过防火墙等很多成熟手段完成。可也有一些特定限制策略，例如特定cookie、url、location，甚至请求body包含有特殊内容，这种情况下普通防火墙就比较难限制。

Nginx的是HTTP 7层协议的实现着，相对普通防火墙从通讯协议有自己的弱势，同等的配置下的性能表现绝对远不如防火墙，但它的优势胜在价格便宜、调整方便，还可以完成HTTP协议上一些更具体的控制策略，与iptable的联合使用，可以让Nginx完成玩法。

##列举几个限制策略来源

* IP地址
* 域名、端口
* Cookie特定标识
* location
* body中特定标识

> 示例配置（allow、deny） 

```
location / {
    deny  192.168.1.1;
    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    deny  all;
}
```

这些规则都是按照顺序解析执行直到某一条匹配成功。在这里示例中，10.1.1.0/16 and 192.168.1.0/24都是用来限制IPv4的，2001:0db8::/32的配置是用来限制IPv6。具体有关allow、deny配置，请参考[这里](http://nginx.org/en/docs/http/ngx_http_access_module.html)。

> 示例配置（geo）

```
Example:

geo $country {
    default        ZZ;
    proxy          192.168.100.0/24;

    127.0.0.0/24   US;
    127.0.0.1/32   RU;
    10.1.0.0/16    RU;
    192.168.1.0/24 UK;
}

if ($country == ZZ){
    return 403;
}
```

使用geo，让我们有更多的分之条件。注意：在Nginx的配置中，尽量少用或者不用if，因为"if is evil"。[点击查看](http://wiki.nginx.org/IfIsEvil)

目前为止所有的控制，都是用Nginx模块完成，执行效率、配置明确是它的优点。缺点也比较明显，修改配置代价比较高（reload服务）。并且无法完成与第三方服务的对接功能交互（例如调用iptable）。

在Openresty里面，这些问题就都容易解决，还记得access_by_lua么？推荐一个第三方库[lua-resty-iputils](https://github.com/hamishforbes/lua-resty-iputils)。

> 示例代码：

```
init_by_lua '
  local iputils = require("resty.iputils")
  iputils.enable_lrucache()
  local whitelist_ips = {
      "127.0.0.1",
      "10.10.10.0/24",
      "192.168.0.0/16",
  }

  -- WARNING: Global variable, recommend this is cached at the module level
  -- https://github.com/openresty/lua-nginx-module#data-sharing-within-an-nginx-worker
  whitelist = iputils.parse_cidrs(whitelist_ips)
';

access_by_lua '
    local iputils = require("resty.iputils")
    if not iputils.ip_in_cidrs(ngx.var.remote_addr, whitelist) then
      return ngx.exit(ngx.HTTP_FORBIDDEN)
    end
';
```

以次类推，我们想要完成域名、Cookie、location、特定body的准入控制，甚至可以做到与本地iptable防火墙联动。我们可以把IP规则存到数据库中，这样我们就再也不用reload数据库了。

思路打开，大家后面多尝试各种玩法吧。
