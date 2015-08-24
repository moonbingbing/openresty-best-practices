# sleep
这是一个比较常见的功能，你会怎么做呢？Google一下，你会找到[lua的官方指南](http://lua-users.org/wiki/SleepFunction)，
里面介绍了10种sleep不同的方法，没错，有10种，选择一个用，然后你就杯具了:( 你会发现nginx高并发的特性不见了！

在OpenResty里面选择使用库的时候，有一个基本的原则：***尽量使用ngx lua的库函数，尽量不用lua的库函数，因为lua的库都是同步阻塞的。***
```lua
ngx.sleep(0.1)
```
本章节内容好少，只是想通过一个真实的例子，来提醒大家，做OpenResty开发，[ngx lua的文档](http://wiki.nginx.org/HttpLuaModule)是你的首选，lua语言的库都是同步阻塞的，用的时候要三思。

再来一个例子来说明阻塞API的调用对nginx并发性能的影响
```
location /sleep_1 {
    default_type 'text/plain';
    content_by_lua '
        ngx.sleep(0.01)
        ngx.say("ok")
    ';
}

location /sleep_2 {
    default_type 'text/plain';
    content_by_lua '
        function sleep(n)
            os.execute("sleep " .. n)
        end
        sleep(0.01)
        ngx.say("ok")
    ';
}
```

ab测试一下
```
➜  nginx git:(master) ab -c 10 -n 20  http://127.0.0.1/sleep_1
...
Requests per second:    860.33 [#/sec] (mean)
...
➜  nginx git:(master) ab -c 10 -n 20  http://127.0.0.1/sleep_2
...
Requests per second:    56.87 [#/sec] (mean)
...
```

可以看到，如果不使用ngx_lua提供的sleep函数，nginx并发处理性能会下降15倍左右。

# 为什么会这样？
原因是sleep_1接口使用了ngx_lua提供的非阻塞API，而sleep_2使用了系统自带的阻塞API。前者只会引起(进程内)协程的切换，但进程还是处于运行状态(其他协程还在运行)，而后者却会触发进程切换，当前进程会变成睡眠状态, 结果CPU就进入空闲状态。很明显，非阻塞的API的性能会更高。
