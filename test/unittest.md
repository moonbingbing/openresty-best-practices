# 单元测试

单元测试（unit testing），是指对软件中的最小可测试单元进行检查和验证。对于单元测试中单元的含义，一般来说，要根据实际情况去判定其具体含义，如C语言中单元指一个函数，Java里单元指一个类，图形化的软件中可以指一个窗口或一个菜单等。总的来说，单元就是人为规定的最小的被测功能模块。单元测试是在软件开发过程中要进行的最低级别的测试活动，软件的独立单元将在与程序的其他部分相隔离的情况下进行测试。

单元测试的书写、验证，互联网公司几乎都是研发自己完成的，我们要保证代码出手时可交付、符合预期。如果连自己的预期都没达到，后面所有的工作，都将是额外无用功。

Lua中我们没有找到比较好的测试库，参考了Golang、Python等语言的单元测试书写方法以及调用规则，我们编写了[lua-resty-test](https://github.com/membphis/lua-resty-test)测试库，这里给自己的库推广一下，希望这东东也是你们的真爱。

> nginx示例配置

```
    #you do not need the following line if you are using
    #the ngx_openresty bundle:

    lua_package_path "/path/to/lua-resty-redis/lib/?.lua;;";

    server {
        location /test {
            content_by_lua_file test_case_lua/unit/test_example.lua;
        }
    }
```

> test_case_lua/unit/test_example.lua:

```lua
local tb    = require "resty.iresty_test"
local test = tb.new({unit_name="bench_example"})

function tb:init(  )
    self:log("init complete")
end

function tb:test_00001(  )
    error("invalid input")
end

function tb:atest_00002()
    self:log("never be called")
end

function tb:test_00003(  )
   self:log("ok")
end

-- units test
test:run()

-- bench test(total_count, micro_count, parallels)
test:bench_run(100000, 25, 20)
```

* init里面我们可以完成一些基础、公共变量的初始化，例如特定的url等
* test_\*\*\*\*\*函数中添加我们的单元测试代码
* 搞定测试代码，它即是单元测试，也是成压力测试

> 输出日志：

```
TIME   Name            Log
0.000  [bench_example] unit test start
0.000  [bench_example] init complete
0.000    \_[test_00001] fail ...de/nginx/test_case_lua/unit/test_example.lua:9: invalid input
0.000    \_[test_00003] ↓ ok
0.000    \_[test_00003] PASS
0.000  [bench_example] unit test complete

0.000  [bench_example] !!!BENCH TEST START!!
0.484  [bench_example] succ count:   100001     QPS:     206613.65
0.484  [bench_example] fail count:   100001     QPS:     206613.65
0.484  [bench_example] loop count:   100000     QPS:     206611.58
0.484  [bench_example] !!!BENCH TEST ALL DONE!!!
```

埋个伏笔：在压力测试例子中，测试到的QPS大约21万的，这是我本机一台Mac Mini压测的结果。构架好，姿势正确，我们可以很轻松做出好产品。

后面会详细说一下用这个工具进行压力测试的独到魅力，做出一个NB的网络处理应用，这个测试库应该是你的利器。

