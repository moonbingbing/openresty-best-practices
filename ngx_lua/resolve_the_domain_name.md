## 为什么我们的域名不能被解析

最近经常有朋友在使用一个域名地址时发现无法被正确解析

比如在使用 `Mysql` 实例时某些云会给一个私有的域名搭配自有的 `nameserver` 使用

```lua
local client = mysql:new()
client:connect({
	host = "rdsmxxxxxx.mysql.rds.xxxx.com",
	port = 3306,
	database = "test",
	user = "test",
	password = "123456"
})
```

以上代码在直接使用时往往会报一个无法解析的错误。那么怎么在 `openresty` 中使用域名呢


<!-- more -->

## 搭配 resolver 指令

我们可以直接在 `nginx` 的配置文件中使用 `resolver` 指令直接设置使用的 `nameserver` 地址。

官方文档中是这么描述的

```conf
Syntax:	resolver address ... [valid=time] [ipv6=on|off];
Default:	 —
Context:	http, server, location
```

一个简单的例子

```conf
resolver 8.8.8.8 114.114.114.114 valid=3600s;
```

不过这样的问题在于 `nameserver` 被写死在配置文件中，如果使用场景比较复杂或有内部 `dns` 服务时维护比较麻烦。


## 进阶玩法

我们的代码常常运行在各种云上，为了减少维护成本，我采用了动态读取本机 `/etc/resolv.conf` 的方法来做。

废话不说，让我们一睹为快。


```lua
local pcall = pcall
local io_open = io.open
local ngx_re_gmatch = ngx.re.gmatch

local ok, new_tab = pcall(require, "table.new")

if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _dns_servers = new_tab(5, 0)

local _read_file_data = function(path)
    local f, err = io_open(path, 'r')

    if not f or err then
        return nil, err
    end

    local data = f:read('*all')
    f:close()
    return data, nil
end

local _read_dns_servers_from_resolv_file = function()
    local text = _read_file_data('/etc/resolv.conf')

    local captures, it, err
    it, err = ngx_re_gmatch(text, [[^nameserver\s+(\d+?\.\d+?\.\d+?\.\d+$)]], "jomi")

    for captures, err in it do
        if not err then
            _dns_servers[#_dns_servers + 1] = captures[1]
        end
    end
end

_read_dns_servers_from_resolv_file()
```

通过上述代码我们成功动态拿到了一组 `nameserver` 的地址，下面就可以通过 `resty.dns.resolver` 大杀四方了

```lua
local require = require
local ngx_re_find = ngx.re.find
local lrucache = require "resty.lrucache"
local resolver = require "resty.dns.resolver"
local cache_storage = lrucache.new(200)

local _is_addr = function(hostname)
    return ngx_re_find(hostname, [[\d+?\.\d+?\.\d+?\.\d+$]], "jo")
end

local _get_addr = function(hostname)
    if _is_addr(hostname) then
        return hostname, hostname
    end

    local addr = cache_storage:get(hostname)

    if addr then
        return addr, hostname
    end

    local r, err = resolver:new({
        nameservers = _dns_servers,
        retrans = 5,  -- 5 retransmissions on receive timeout
        timeout = 2000,  -- 2 sec
    })

    if not r then
        return nil, hostname
    end

    local answers, err = r:query(hostname, {qtype = r.TYPE_A})

    if not answers or answers.errcode then
        return nil, hostname
    end

    for i, ans in ipairs(answers) do
        if ans.address then
            cache_storage:set(hostname, ans.address, 300)
            return ans.address, hostname
        end
    end

    return nil, hostname
end

ngx.say(_get_addr("www.baidu.com"))
ngx.say(_get_addr("192.168.0.1"))
```

我这边把解析的结果放入了 `lrucache` 缓存了 5 分钟，你们同样可以把结果放入 `shared` 中来减少 `worker` 查询次数。

## 高阶玩法

现在我们已经实现了自缓存体系的 `dns` 查询，如果搭配 `resty.http` 就会达到更好的效果。

一个简单的例子是，通过解析 `uri` 得到 `hostname`、`port`、`path`，把 `hostname` 扔给自缓存 `dns` 获取结果

发起 `request` 请求，`addr` + `port` connect 之，设置 `header` 的 `host` 为 `hostname`，`path` 等值来实现 `ip` 直接访问等高阶用法。

这里就不过多的阐述了。

## 最终的演示例子如下

```lua
local client = mysql:new()
client:connect({
	host = _get_addr(conf.mysql_hostname),
	port = 3306,
	database = "test",
	user = "test",
	password = "123456"
})
```

## 如何使用 /etc/hosts 自定义域名

还有些同学可能会在 `hosts` 文件中自定义域名和 `ip`，这时候 `resolve` 是无法正常解析的。

这个时候可以借助 `dnsmasq` 这个服务来缓存我们的 `dns` 结果，`hosts` 的定义可以被该服务识别。

需要在 `nginx` 的配置文件中，设置 `resolver` 为 `dnsmasq` 服务的监听地址即可。

See:
[http://hambut.com/2016/09/09/how-to-resolve-the-domain-name-in-openresty/](http://hambut.com/2016/09/09/how-to-resolve-the-domain-name-in-openresty/)
