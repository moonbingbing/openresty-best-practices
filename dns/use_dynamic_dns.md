# 使用动态DNS来完成HTTP请求

其实针对大多应用场景，DNS是不会频繁变更的。使用最古老的resolver配置方式就可以解决。

奇虎360企业版，由于存在二次分发问题，需要支持的系统众多：win、centos、ubuntu等，不同的操作系统获取dns的方法都不太一样。再加上我们使用docker，导致我们在容器内部获取dns变得更加难以精准。

如何能够让Nginx使用随时可以变化的DNS源，成为我们急待解决的问题。

当我们需要在某一个请求内部发起这样一个http查询，采用proxy_pass是不行的（依赖resolver的dns，如果dns有变化，必须要重新加载配置），并且由于proxy_pass不能直接设置keepconn，导致每次请求都是短链接，性能损失严重。

使用resty.http，目前这个库只支持ip：port的方式定义url，其内部实现并没有支持domain解析。resty.http是支持set_keepalive完成长连接，这样我们只需要让他支持dns解析就能有完美解决方案了。

```lua
local resolver = require "resty.dns.resolver"
local http     = require "resty.http"

function get_domain_ip_by_dns( domain )
  -- 这里写死了google的域名服务ip，要根据实际情况做调整（例如放到指定配置或数据库中）
  local dns = "8.8.8.8"

  local r, err = resolver:new{
      nameservers = {dns, {dns, 53} },
      retrans = 5,  -- 5 retransmissions on receive timeout
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

    -- httpc:request_uri 内部已经调用了keepalive，默认支持长连接
    -- httpc:set_keepalive(1000, 100)
    return res
end
```

动态DNS，域名访问，长连接，这些都具备了，貌似可以安稳一下。在压力测试中发现这里面有个机制不太好，就是对于指定域名解析，每次都要和DNS服务回话询问IP地址，实际上这是不需要的。普通的浏览器，都会对DNS的结果进行一定的缓存，那么这里也必须要使用了。

对于缓存实现代码，请参考ngx_lua相关章节，肯定会有惊喜等着你挖掘碰撞。
