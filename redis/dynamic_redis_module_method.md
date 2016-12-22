# 动态生成的 lua-resty-redis 模块方法

刚接触 lua-resty-redis 的文档的时候，你可能会惊讶于上面列出的方法之少。
Redis 有好几十个命令，而[Method](https://github.com/openresty/lua-resty-redis#methods)一节列出的方法却寥寥无几。
事实上，如果仔细阅读了文档，你会在 Method 一节的开头读到这么一段话：

> All of the Redis commands have their own methods with the same name except all in lower case.
> You can find the complete list of Redis commands here:
> http://redis.io/commands
> ...
> In addition to all those redis command methods, the following methods are also provided:

看来不是 lua-resty-redis 支持的方法少，而是大部分方法都不需要单独列出来。

#### 动态语言，动态方法

其实，lua-resty-redis 并没有显式定义这一类跟 Redis 命令同名的方法。

熟悉 Redis 的人对 `redis.call` 应该不会感到陌生，这是 Redis Lua 脚本中调用 Redis 命令的唯一方法。
无论是什么 Redis 命令，你都可以通过它调用。
lua-resty-redis 内部就有一个类似于这样的方法，它负责把请求参数发给 Redis，然后处理来自 Redis 的响应。

出于易用性，lua-resty-redis 用 `$command(arg1, arg2)` 的形式封装了 `call($command, arg1, arg2)`。每次调用时可以少打四个字符呢。
由于动态语言支持动态生成方法，lua-resty-redis 并不用给每个命令补上一个对应的方法，它只需要：

```
-- 仅为示例，不是真正的实现
local cmds = {
    'get', 'set', ...
}

for i = 1, #cmds do
    local cmd = cmds[i]
    _M[cmd] = function(...)
        call(cmd, ...)
    end
end
```

现在，要想支持新的 Redis 命令，往 cmds 里加多一个字符串就好了。这就叫良好的拓展性。
当然，有些命令，比如 `subscribe`，需要额外的特殊处理。

#### 动态方法，惰性生成

从 OpenResty 1.11.2 版本开始，lua-resty-redis 模块使用了一个巧妙的技巧，推迟到实际需要时才动态生成模块方法。
依靠惰性生成方法，要想支持新的 Redis 命令，大多数情况下 lua-resty-redis 连一个字符串都不用加。无需拓展，才是真正的“良好的拓展性”。

前面说到，动态语言支持动态生成方法，这不仅意味着可以动态地生成方法，也意味着可以在运行时 **按需** 生成方法。
跟其他动态语言一样，Lua 提供了一个方法，允许程序员在找不到对应方法时调用特定的处理逻辑，那就是 `__index`。

`__index` 在前面的[元表](../lua/metatable.md)一章中已经介绍过了。跟“给表中的键附上默认值”类似，我们也可以给模块中的方法名附上默认实现。
所需的只是如下的代码：

```
setmetatable(_M, {__index = function(self, cmd)
    local method =
        function (self, ...)
            return call(self, cmd, ...)
        end

    -- cache the lazily generated method in our
    -- module table
    _M[cmd] = method
    return method
end})
```

现在我们可以不用准备一份超长的命令列表，也无需为用不到的命令付生成方法的开销，同时给未来的命令也留好了位置。
一切魔法均隐藏于代码之中，may the source be with you!
