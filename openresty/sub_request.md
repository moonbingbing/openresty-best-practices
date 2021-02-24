# 子请求

Nginx 子请求是一种非常强有力的请求方式，它可以发起 **非阻塞的内部请求** 访问目标 location。
目标 location 可以是配置文件中其他文件目录，或 **任何** 其他 Nginx C 模块，包括 `ngx_proxy`、`ngx_fastcgi`、`ngx_memc`、`ngx_postgres`、`ngx_drizzle`，甚至 `ngx_lua` 自身等等 。

### API 方法
#### 1、`ngx.location.capture()`

- **1.1 语法:**

    ```lua
    -- 单个请求
    res = ngx.location.capture(uri, options?)
    ```

- **1.2 作用域:** `rewrite_by_lua*`, `access_by_lua*`, `content_by_lua*`

- **1.3 options:**

    - method:  请求方法，默认为 `ngx.HTTP_GET`
    - body: 请求内容，仅限于 `string` 或 `nil`
    - args: 请求参数，支持 `string` 或 `table`
    - vars: 变量，仅限于 `table`
    - ctx:  特殊的 `ngx.ctx` 变量，可以被当前请求赋值，也可以在子请求使用，
        父子请求共享的变量
    - copy_all_vars: 复制变量
    - share_all_vars: 共享变量
    - always_forward_body:
        - 默认是 `false`，仅转发 `put` 和 `post` 请求方式中的 body。
        - 当设置为 `true` 时，父请求中的 body 转发到子请求。
        - 如果设置 body 选项，则该项设置失效。

#### 2、`ngx.location.capture_multi()`

- **2.1 语法:**

    ```lua
    -- 同时并发多个请求（各请求相互之间没有依赖关系）
    res1, res2, ... = ngx.location.capture_multi({
        {uri, options?},
        {uri, options?},
        ...
    })

    -- 示例
    res1, res2, res3 = ngx.location.capture_multi({
         { "/foo", { args = "a=3&b=4" } },
         { "/bar" },
         { "/baz", { method = ngx.HTTP_POST, body = "hello" } },
     })
    ```

- **2.2 作用域:**  同上
- **2.3 options:**  同上

### 为何如此高效

子请求 **只是模拟** HTTP 接口的形式， **没有** 额外的 HTTP/TCP 流量，**也没有** IPC (进程间通信) 调用。所有工作均在内部、在 C 语言级别高效地完成。


### 子请求与重定向
子请求与 HTTP 301/302 重定向指令 (通过 [ngx.redirect](https://github.com/openresty/lua-nginx-module#ngxredirect)) 完全不同，也与内部重定向 (通过 [ngx.exec](https://github.com/openresty/lua-nginx-module#ngxexec)) 完全不同，如下表所示：

| 序号 | 指令或函数 | 用途 | 作用范围 |
|:----:|----|----|----|
| 1 | ngx.exec() | Nginx 跳转 | 仅限 Nginx 内部的 location |
| 2 | ngx.redirect() | HTTP 301/302 重定向 | 支持外部跳转 |
| 3 | ngx.location.capture()，<br>ngx.location.capture_multi() | 子请求，并发子请求 | 仅限 Nginx 内部的 location |
| 4 | http 包中的 multi() 方法 | 概念上与 ngx.location.capture_multi() 相似 | 支持外部接口 |

### 对请求体的处理
在发起子请求前，用户程序应总是读取完整的 HTTP 请求体 (通过调用 [ngx.req.read_body](https://github.com/openresty/lua-nginx-module#ngxreqread_body) 或设置 [lua_need_request_body](https://github.com/openresty/lua-nginx-module#lua_need_request_body) 指令为 `on`)。

子请求的 API 方法 **总是缓冲整个请求体到内存中**。因此，当需要处理一个大的子请求响应，用户程序应使用 [cosockets](https://github.com/openresty/lua-nginx-module#ngxsockettcp) 进行流式处理，否则内存会被大量消耗，性能急速下降，甚至...。

### 用法示例
#### 示例 1、子请求的返回值，例如：

```lua
res = ngx.location.capture(uri)
```

返回一个包含四个元素的 Lua 表 (`res.status`、 `res.header`、 `res.body` 和 `res.truncated`)。

- `res.status` (状态) ：保存子请求的响应状态码。

- `res.header` (头) ：用一个标准 Lua 表来存储子请求响应的所有头信息。
    如果是“多值”响应头，这些值将使用 Lua 表 (作为数组使用) 顺序存储。例如，如果子请求响应头包含下面的行：

    ```bash
    Set-Cookie: a=3
    Set-Cookie: foo=bar
    Set-Cookie: baz=blah
    ```

    则 `res.header["Set-Cookie"]` 将存储 Lua 表 `{"a=3", "foo=bar", "baz=blah"}`。

- `res.body` (体)：保存子请求的响应体数据，它可能被截断。

- `res.truncated` (截断)：一个布尔值标记。

    用户需要检测这个布尔值来判断 `res.body` 是否包含截断的数据。这种数据截断的原因只可能是因为子请求发生了不可恢复的错误，例如远端在发送响应体时 **过早中断了连接**，或子请求在接收远端响应体时 **超时**。

#### 示例 2、子请求的 URI，例如：

- GET 子请求：URI 请求串可以与 URI 本身连在一起
    ```lua
    res = ngx.location.capture('/foo/bar?a=3&b=4')
    ```

    因为 Nginx 内核限制，子请求不允许类似 `@foo` 命名 location。请使用标准 location，并设置 `internal` 指令，仅服务内部请求。

- POST 子请求，可以这样做：

    ```lua
    res = ngx.location.capture(
        '/foo/bar',
        { method = ngx.HTTP_POST, body = 'hello, world' }
    )
    ```

    除了 POST，其他 HTTP 请求方法请参考 [HTTP method constants](https://github.com/openresty/lua-nginx-module#http-method-constants)。 `method` 选项默认值是 `ngx.HTTP_GET`。

#### 示例 3、args 选项，例如：
- `args` 选项可以设置附加的 URI 参数，例如：

    ```lua
    ngx.location.capture(
        '/foo?a=1',
        { args = { b = 3, c = ':' } }
    )
    ```

    等同于

    ```lua
    ngx.location.capture('/foo?a=1&b=3&c=%3a')
    ```

    也就是说，这个方法将根据 URI 规则转义参数键和值，并将它们拼接在一起组成一个完整的请求串。`args` 选项要求的 Lua 表的格式与 [ngx.encode_args](https://github.com/openresty/lua-nginx-module#ngxencode_args) 方法中使用的完全相同。

- `args` 选项也可以直接包含 (转义过的) 请求串：

    ```lua
    ngx.location.capture(
        '/foo?a=1',
        { args = 'b=3&c=%3a' } }
    )
    ```

    这个例子与上个例子的功能相同。


### 注意事项
#### 1、 请求头信息
请注意，通过 [ngx.location.capture](https://github.com/openresty/lua-nginx-module#ngxlocationcapture) 创建的子请求 **默认继承** 当前请求的所有请求头信息，这有可能导致子请求响应中不可预测的副作用。

例如，当使用标准的 `ngx_proxy` 模块服务子请求时，如果主请求头中包含 "Accept-Encoding: gzip"，可能导致子请求返回 Lua 代码无法正确处理的 gzip 压缩过的结果。

##### 解决方案
- 通过设置 [proxy_pass_request_headers](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass_request_headers) 为 `off` ，在子请求 location 中忽略原始请求头；
- 在子请求中设置 `proxy_set_header Accept-Encoding "";` 忽略 Accept-Encoding 头。

#### 2、 无法共同工作的指令
请注意，[ngx.location.capture](https://github.com/openresty/lua-nginx-module#ngxlocationcapture) 和 [ngx.location.capture_multi](https://github.com/openresty/lua-nginx-module#ngxlocationcapture_multi) 指令无法抓取包含以下指令的 location：
- [add_before_body](http://nginx.org/en/docs/http/ngx_http_addition_module.html#add_before_body)
- [add_after_body](http://nginx.org/en/docs/http/ngx_http_addition_module.html#add_after_body)
- [auth_request](http://nginx.org/en/docs/http/ngx_http_auth_request_module.html#auth_request)
- [echo_location](http://github.com/openresty/echo-nginx-module#echo_location)
- [echo_location_async](http://github.com/openresty/echo-nginx-module#echo_location_async)
- [echo_subrequest](http://github.com/openresty/echo-nginx-module#echo_subrequest)
- [echo_subrequest_async](http://github.com/openresty/echo-nginx-module#echo_subrequest_async)

```nginx
location /foo {
    content_by_lua_block {
        res = ngx.location.capture("/bar")
    }
}
location /bar {
    echo_location /blah;  # 无法共同工作的指令
}
location /blah {
    echo "Success!";
}
```

```nginx
$ curl -i http://example.com/foo
```

他们将不会按照预期工作。
