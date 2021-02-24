# API 测试

**API（Application Programming Interface）测试** 的自动化是软件测试最基本的一种类型。从本质上来说，API 测试是用来验证组成软件的那些单个方法的正确性，而不是测试整个系统本身。

API 测试也称为单元测试（Unit Testing）、模块测试（Module Testing）、组件测试（Component Testing）以及元件测试（Element Testing）。从技术上来说，这些术语是有很大的差别的，但是在日常应用中，你可以认为它们是大致相同的意思。它们背后的思想就是，必须确定系统中每个单独的模块工作正常，否则，这个系统作为一个整体不可能是正确的。毫无疑问，API 测试对于任何重要的软件系统来说都是必不可少的。

我们对 API 测试的定位是服务对外输出的 API 接口测试，属于黑盒、偏重业务的测试步骤。

看过上一章内容的朋友还记得 [lua-resty-test](https://github.com/membphis/lua-resty-test)，我们的 API 测试同样也是需要它来完成。 `get_client_tasks` 是终端用来获取当前可执行任务清单的 API，我们用它当做例子给大家做个介绍。

> nginx conf:

```nginx
location ~* /api/([\w_]+?)\.json {
    content_by_lua_file lua/$1.lua;
}

location ~* /unit_test/([\w_]+?)\.json {
    lua_check_client_abort on;
    content_by_lua_file test_case_lua/unit/$1.lua;
}
```

> API 测试代码：

```lua
-- unit test for /api/get_client_tasks.json
local tb = require "resty.iresty_test"
local json = require("cjson")
local test = tb.new({unit_name="get_client_tasks"})

function tb:init()
    self.mid = string.rep('0',32)
end

function tb:test_0000()
    -- 正常请求
    local res = ngx.location.capture(
        '/api/get_client_tasks.json?mid='..self.mid,
        { method = ngx.HTTP_POST, body=[[{"type":[1600,1700]}]] }
    )

    if 200 ~= res.status then
        error("failed code:" .. res.status)
    end
end

function tb:test_0001()
    -- 缺少body
    local res = ngx.location.capture(
        '/api/get_client_tasks.json?mid='..self.mid,
        { method = ngx.HTTP_POST }
    )

    if 400 ~= res.status then
        error("failed code:" .. res.status)
    end
end

function tb:test_0002()
    -- 错误的json内容
    local res = ngx.location.capture(
        '/api/get_client_tasks.json?mid='..self.mid,
        { method = ngx.HTTP_POST, body=[[{"type":"[1600,1700]}]] }
    )

    if 400 ~= res.status then
        error("failed code:" .. res.status)
    end
end

function tb:test_0003()
    -- 错误的json格式
    local res = ngx.location.capture(
        '/api/get_client_tasks.json?mid='..self.mid,
        { method = ngx.HTTP_POST, body=[[{"type":"[1600,1700]"}]] }
    )

    if 400 ~= res.status then
        error("failed code:" .. res.status)
    end
end

test:run()
```

Nginx output:
```shell
0.000  [get_client_tasks] unit test start
0.001    \_[test_0000] PASS
0.001    \_[test_0001] PASS
0.001    \_[test_0002] PASS
0.001    \_[test_0003] PASS
0.001  [get_client_tasks] unit test complete
```

使用 `ngx.location.capture` 来模拟请求，其实是不靠谱的。如果我们要完全 100% 模拟客户请求，这时候就要使用第三方 cosocket 库，例如 [lua-resty-http](https://github.com/pintsized/lua-resty-http)，这样我们才可以完全指定 http 参数。

