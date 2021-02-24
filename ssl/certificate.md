# 动态加载证书和 OCSP stapling

一个标准的 Nginx ssl 配置必然包含这两行：

```nginx
ssl_certificate     example.com.crt;
ssl_certificate_key example.com.key;
```

Nginx 启动时会读取配置的证书内容，并经过一系列解析后，最终通过调用 OpenSSL 的 `SSL_use_certificate` 来设置证书。
对于匹配的私钥，Nginx 调用的是 `SSL_use_PrivateKey`。

于是有了个新的想法：既然 OpenSSL 允许我们动态地设置证书和私钥，也许我们可以在建立连接前才设置证书和私钥呢？
这样一来，我们可以结合 SNI，针对不同的请求域名动态设置不同的证书和私钥，而无需事先把可能用到的证书和私钥都准备好。

### 动态加载证书

借助 OpenResty，我们可以轻易地把这个想法变成现实。
所需的，是 `ssl_certificate_by_lua*` 指令和来自 `lua-resty-core` 的 `ngx.ssl` 模块。另外，编译 OpenResty 时指定的 OpenSSL 需要 1.0.2e 或以上的版本。

> 见下面的示例代码：

```nginx
server {
    listen 443 ssl;
    server_name   test.com;

    # 用于满足 Nginx 配置的占位符
    ssl_certificate fake.crt;
    ssl_certificate_key fake.key;

    ssl_certificate_by_lua_block {
        local ssl = require "ngx.ssl"

        -- 清除之前设置的证书和私钥
        local ok, err = ssl.clear_certs()
        if not ok then
            ngx.log(ngx.ERR, "failed to clear existing (fallback) certificates")
            return ngx.exit(ngx.ERROR)
        end

        -- 后续代码见下文
    }
}
```

证书/私钥的格式分两种，一种是文本格式的 PEM，另一种是二进制格式的 DER。我们看到的证书一般是 PEM 格式的。
这两种不同的格式，处理代码有所不同。

> 先看 PEM 的处理方式：
```lua
-- 获取证书内容，比如 io.open("my.crt"):read("*a")
local cert_data, err = get_my_pem_cert_data()
if not cert_data then
    ngx.log(ngx.ERR, "failed to get PEM cert: ", err)
    return
end

-- 解析出 cdata 类型的证书值，你可以用 lua-resty-lrucache 缓存解析结果
local cert, err = ssl.parse_pem_cert(cert_data)
if not cert then
    ngx.log(ngx.ERR, "failed to parse PEM cert: ", err)
    return
end

local ok, err = ssl.set_cert(cert)
if not ok then
    ngx.log(ngx.ERR, "failed to set cert: ", err)
    return
end

local pkey_data, err = get_my_pem_priv_key_data()
if not pkey_data then
    ngx.log(ngx.ERR, "failed to get DER private key: ", err)
    return
end

local pkey, err = ssl.parse_pem_priv_key(pkey_data)
if not pkey then
    ngx.log(ngx.ERR, "failed to parse pem key: ", err)
    return
end

local ok, err = ssl.set_priv_key(pkey)
if not ok then
    ngx.log(ngx.ERR, "failed to set private key: ", err)
    return
end
```

> 再看 DER 的处理方式：
```lua
-- 获取证书内容，比如 io.open("my.crt.der"):read("*a")
local cert_data, err = get_my_der_cert_data()
-- 你也可以把 pem 格式的证书直接转换成 der 格式的，像这样：
-- local cert_pem_data = get_my_pem_cert_data()
-- local cert_data, err = ssl.cert_pem_to_der(cert_pem_data)
if not cert_data then
    ngx.log(ngx.ERR, "failed to get DER cert: ", err)
    return
end

-- 这里的 cert_data 是 string 类型的，所以可以直接缓存到 lua_shared_dict 当中
local ok, err = ssl.set_der_cert(cert_data)
if not ok then
    ngx.log(ngx.ERR, "failed to set DER cert: ", err)
    return
end

local pkey_data, err = get_my_der_priv_key_data()
-- 你也可以把 pem 格式的私钥直接转换成 der 格式的，像这样：
-- local pkey_pem_data = get_my_pem_priv_key_data()
-- local pkey_data, err = ssl.priv_key_pem_to_der(pkey_pem_data)
if not pkey_data then
    ngx.log(ngx.ERR, "failed to get DER private key: ", err)
    return
end

local ok, err = ssl.set_der_priv_key(pkey_data)
if not ok then
    ngx.log(ngx.ERR, "failed to set DER private key: ", err)
    return
end
```

### OCSP stapling

基于 CA 的 Public key infrastructure（PKI）需要有及时更新证书吊销情况的机制。
目前的主流方式是 [Online Certificate Status Protocol (OCSP)](https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol)。
即在获取到证书信息时，由浏览器负责向对应的 CA 发起证书吊销状态的查询。除了 Chrome [另辟蹊径](http://www.zdnet.com/article/chrome-does-certificate-revocation-better)，其他浏览器都支持这一协议。

该方式有两个问题：
- 1、每个浏览器访问同一网站时，都会发起独立的查询，这将会导致 CA 的服务面临较大的压力。
- 2、只有在 OCSP 查询结果出来后，浏览器才能信任所给的证书。所以一旦需要进行 OCSP 查询，会对页面加载时间造成明显影响。

作为开发者，我们并不关心第一点。但第二点却不能不解决。
还好 OCSP 有一个“补丁”，叫 [OCSP stapling](https://en.wikipedia.org/wiki/OCSP_stapling)。
Web 应用可以定期通过 OCSP stapling 从 CA 处获取自己证书的吊销状态，然后在 SSL 握手时把结果返回给浏览器。

既然我们的证书已经是动态加载的，我们也需要实现动态的 OCSP stapling。

> 看下面的示例代码：
```lua
-- ngx.ocsp 来自于 lua-resty-core 标准库
local ocsp = require "ngx.ocsp"
local http = require "resty.http"

-- 上接动态获取 DER 格式的证书
-- 当前 OCSP 接口只支持 DER 格式的证书
local ocsp_url, err = ocsp.get_ocsp_responder_from_der_chain(cert_der_data)
if not ocsp_url then
    ngx.log(ngx.ERR, "failed to get OCSP responder: ", err)
    return ngx.exit(ngx.ERROR)
end

-- 生成 OCSP 请求体
local ocsp_req, ocsp_request_err = ocsp.create_ocsp_request(cert_der_data)
if not ocsp_req then
    ngx.log(ngx.ERR, "failed to create OCSP request: ", err)
    return ngx.exit(ngx.ERROR)
end

local httpc = http.new()
httpc:set_timeout(10000)
local res, req_err = httpc:request_uri(ocsp_url, {
    method = "POST",
    body = ocsp_req,
    headers = {
        ["Content-Type"] = "application/ocsp-request",
    }
})

-- 校验 CA 的返回结果
if not res then
    ngx.log(ngx.ERR, "OCSP responder query failed: ", err)
    return ngx.exit(ngx.ERROR)
end

local http_status = res.status

if http_status ~= 200 then
    ngx.log(ngx.ERR, "OCSP responder returns bad HTTP status code ",
            http_status)
    return ngx.exit(ngx.ERROR)
end

local ocsp_resp = res.body

if ocsp_resp and #ocsp_resp > 0 then
    local ok, err = ocsp.validate_ocsp_response(ocsp_resp, der_cert_chain)
    if not ok then
        ngx.log(ngx.ERR, "failed to validate OCSP response: ", err)
        return ngx.exit(ngx.ERROR)
    end

    -- 设置当前 SSL 连接的 OCSP stapling
    ok, err = ocsp.set_ocsp_status_resp(ocsp_resp)
    if not ok then
        ngx.log(ngx.ERR, "failed to set ocsp status resp: ", err)
        return ngx.exit(ngx.ERROR)
    end
end
```

CA 返回的 OCSP stapling 结果需要缓存起来，直到需要刷新为止。目前 OpenResty 还缺乏提取 OCSP stapling 有效时间 `(nextUpdate - thisUpdate)` 的接口。

有一个相关的 [PR](https://github.com/openresty/lua-nginx-module/pull/1041/files)，需要的话，你可以参照着在一个独立的 Nginx C 模块里实现对应功能。
作为参照，Nginx 计算刷新时间的公式是 `max(min(nextUpdate - now - 5m, 1h), now + 5m)`，即 5 分钟到 1 小时之间。而另一个服务器 Caddy，则采用 `(nextUpdate - thisUpdate) / 2` 作为刷新的时间。

具体缓存多久会比较好，你也可以咨询下签发证书的 CA。
