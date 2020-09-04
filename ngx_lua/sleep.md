# sleep

这是一个比较常见的功能，你会怎么做呢？Google 一下，你会找到 [Lua 的官方指南](http://lua-users.org/wiki/SleepFunction)，里面介绍了 10 种 sleep 不同的方法（操作系统不一样，方法还有区别），选择一个用，然后你就杯具了:( 你会发现 Nginx 高并发的特性不见了！

在 OpenResty 里面选择使用库的时候，有一个基本的原则：***尽量使用 OpenResty 的库函数，尽量不用 Lua 的库函数，因为 Lua 的库都是同步阻塞的。***

```nginx
# you do not need the following line if you are using
# the ngx_openresty bundle:
lua_package_path "/path/to/lua-resty-redis/lib/?.lua;;";

server {
    location /non_block {
        content_by_lua_block {
            ngx.sleep(0.1)
        }
    }
}
```

本章节内容好少，只是想通过一个真实的例子，来提醒大家，做 OpenResty 开发，[lua-nginx-module 的文档](https://github.com/openresty/lua-nginx-module) 是你的首选，Lua 语言的库都是同步阻塞的，用的时候要三思。

再来一个例子来说明阻塞 API 的调用对 Nginx 并发性能的影响
```nginx
location /sleep_1 {
    default_type 'text/plain';
    content_by_lua_block {
        ngx.sleep(0.01)
        ngx.say("ok")
    }
}

location /sleep_2 {
    default_type 'text/plain';
    content_by_lua_block {
        function sleep(n)
            os.execute("sleep " .. n)
        end
        sleep(0.01)
        ngx.say("ok")
    }
}
```

ab 测试一下
```shell
➜  nginx git:(master) ab -c 10 -n 20  http://127.0.0.1/sleep_1
...
Requests per second:    860.33 [#/sec] (mean)
...
➜  nginx git:(master) ab -c 10 -n 20  http://127.0.0.1/sleep_2
...
Requests per second:    56.87 [#/sec] (mean)
...
```

可以看到，如果不使用 `ngx_lua` 提供的 `sleep` 函数，Nginx 并发处理性能会下降 15 倍左右。

### 为什么会这样？

原因是 sleep_1 接口使用了 OpenResty 提供的非阻塞 API，而 sleep_2 使用了系统自带的阻塞 API。前者只会引起 (进程内) 协程的切换，但进程还是处于运行状态 (其他协程还在运行)，而后者却会触发进程切换，当前进程会变成睡眠状态, 结果 CPU 就进入空闲状态。很明显，非阻塞的 API 的性能会更高。
