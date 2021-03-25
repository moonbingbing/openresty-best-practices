# 单元测试

**单元测试（Unit Testing）**，是指对软件中的最小可测试单元进行检查和验证。对于单元测试中 **单元的含义**，一般来说，要根据实际情况去判定其具体含义，如 C 语言中单元指一个函数，Java 里单元指一个类，图形化的软件中可以指一个窗口或一个菜单等。总的来说，单元就是人为规定的最小的被测功能模块。单元测试是在软件开发过程中要进行的最低级别的测试活动，软件的独立单元将在与程序的其他部分相隔离的情况下进行测试。

单元测试的编写、验证，互联网公司几乎都是研发自己完成的，我们要保证代码出手时可交付、符合预期。如果连自己的预期都没达到，后面所有的工作，都将是额外无用功。

Lua 中我们没有找到比较好的测试库，参考了 Golang、Python 等语言的单元测试编写方法以及调用规则，编写了 [lua-resty-test](https://github.com/membphis/lua-resty-test) 测试库，这里给自己的库推广一下，希望这东东也会是你们的真爱。

> nginx.conf 中的示例配置：

```nginx
#you do not need the following line if you are using
#the ngx_openresty bundle:

lua_package_path "/path/to/lua-resty-redis/lib/?.lua;;";

server {
    location /test {
        content_by_lua_file test_case_lua/unit/test_example.lua;
    }
}
```

> test_case_lua/unit/test_example.lua 文件：

```lua
local iresty_test = require("resty.iresty_test")
local tb = iresty_test.new({unit_name="example"})

function tb:init()
    self:log("init complete")
end

function tb:test_00001()
    error("invalid input")
end

function tb:atest_00002()
    self:log("never be called")
end

function tb:test_00003()
   self:log("ok")
end

-- units test
tb:run()
```

* 在 `init()` 里面我们可以完成一些基础、公共变量的初始化，例如特定的 URL 等；
* `test_*****` 函数中添加我们的单元测试代码；
* 搞定测试代码，它即是单元测试，也是成压力测试。

> 输出日志：

```
TIME   Name            Log
0.000  [example] unit test start
0.000  [example] init complete
0.000    \_[test_00001] fail ...de/nginx/main_server/test_case_lua/unit/test_example.lua:9: invalid input
0.000    \_[test_00003] ↓ ok
0.000    \_[test_00003] PASS
0.000  [example] unit test complete
```
