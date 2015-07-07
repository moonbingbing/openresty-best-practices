# sleep
这是一个比较常见的功能，你会怎么做呢？Google一下，你会找到[lua的官方指南](http://lua-users.org/wiki/SleepFunction)，
里面介绍了10种sleep不同的方法，没错，有10种，选择一个用，然后你就杯具了:( 你会发现nginx高并发的特性不见了！

在OpenResty里面选择使用库的时候，有一个基本的原则：***尽量使用ngx lua的库函数，尽量不用lua的库函数，因为lua的库都是同步阻塞的。***
```lua
ngx.sleep(0.1)
```
本章节内容好少，只是想通过一个真实的例子，来提醒大家，做OpenResty开发，[ngx lua的文档](http://wiki.nginx.org/HttpLuaModule)是你的首选，lua语言的库都是同步阻塞的，用的时候要三思。
