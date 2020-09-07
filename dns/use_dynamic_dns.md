# 使用动态 DNS 来完成 HTTP 请求

其实针对大多应用场景，DNS 是不会频繁变更的，使用 Nginx 默认的 resolver 配置方式就能解决。

对于部分应用场景，可能需要支持的系统众多：Windows、CentOS、Ubuntu 等，不同的操作系统获取 DNS 的方法都不太一样。再加上我们使用 Docker，导致我们在容器内部获取 DNS 变得更加难以准确。

如何能够让 Nginx 使用随时可以变化的 DNS 源，成为我们急待解决的问题。

当我们需要在某一个请求内部发起这样一个 http 查询，采用 `proxy_pass` 是不行的（依赖 resolver 的 DNS，如果 DNS 有变化，必须要重新加载配置），并且由于 `proxy_pass` 不能直接设置 `keepalive`，导致每次请求都是短连接，性能损失严重。

使用 `resty.http`，目前这个库只支持 IP : Port 的方式定义 URL，其内部实现并没有支持 domain 解析。`resty.http` 是支持 `set_keepalive` 完成长连接的，这样我们只需要让它支持 DNS 解析就能有完美解决方案了。

```lua
local resolver = require "resty.dns.resolver"
local http = require "resty.http"

function get_domain_ip_by_dns( domain )
  -- 这里写死了 google 的域名服务 IP，要根据实际情况做调整（例如放到指定配置或数据库中）
  local dns = "8.8.8.8"

  local r, err = resolver:new{
      nameservers = {dns, {dns, 53} },
      retrans = 5,     -- 5 retransmissions on receive timeout
      timeout = 2000,  -- 2 sec
  }

  if not r then
      return nil, "failed to instantiate the resolver: " .. err
  end

  local answers, err = r:query(domain)
  if not answers then
      return nil, "failed to query the DNS server: " .. err
  end

  if answers.errcode then
      return nil, "server returned error code: " .. answers.errcode .. ": " .. answers.errstr
  end

  for i, ans in ipairs(answers) do
      if ans.address then
          return ans.address
      end
  end

  return nil, "not founded"
end

function http_request_with_dns( url, param )
    -- get domain
    local domain = ngx.re.match(url, [[//([\S]+?)/]])
    domain = (domain and 1 == #domain and domain[1]) or nil
    if not domain then
        ngx.log(ngx.ERR, "get the domain fail from url:", url)
        return {status=ngx.HTTP_BAD_REQUEST}
    end

    -- add param
    if not param.headers then
        param.headers = {}
    end
    param.headers.Host = domain

    -- get domain's ip
    local domain_ip, err = get_domain_ip_by_dns(domain)
    if not domain_ip then
        ngx.log(ngx.ERR, "get the domain[", domain ,"] ip by dns failed:", err)
        return {status=ngx.HTTP_SERVICE_UNAVAILABLE}
    end

    -- http request
    local httpc = http.new()
    local temp_url = ngx.re.gsub(url, "//"..domain.."/", string.format("//%s/", domain_ip))

    local res, err = httpc:request_uri(temp_url, param)
    if err then
        return {status=ngx.HTTP_SERVICE_UNAVAILABLE}
    end

    -- httpc:request_uri 内部已经调用了 keepalive，默认支持长连接
    -- httpc:set_keepalive(1000, 100)
    return res
end
```

**动态 DNS**、 **域名访问**、 **长连接**，这些都具备了，貌似可以安稳一下。

在压力测试中发现这里面有个机制不太好，就是对于指定域名解析，每次都要和 DNS 服务会话，询问 IP 地址，实际上这是不需要的。普通的浏览器，都会对 DNS 的结果进行一定的缓存，那么这里也必须要使用了。

对于缓存实现代码，请参考 ngx_lua 相关章节，肯定会有惊喜等着你挖掘碰撞。
