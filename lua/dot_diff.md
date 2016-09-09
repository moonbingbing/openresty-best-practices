# 点号与冒号操作符的区别

> 看下面示例代码：

```lua
local str = "abcde"
print("case 1:", str:sub(1, 2))
print("case 2:", str.sub(str, 1, 2))
```

> 执行结果:

```
case 1: ab
case 2: ab
```

冒号操作会带入一个`self`参数，用来代表`自己`。而点号操作，只是`内容`的展开。

在函数定义时，使用冒号将默认接收一个`self`参数，而使用点号则需要显式传入`self`参数。

示例代码：

```lua
obj = { x = 20 }

function obj:fun1()
	print(self.x)
end
```

等价于

```lua
obj = { x = 20 }

function obj.fun1(self)
	print(self.x)
end
```

参见 [官方文档](http://www.lua.org/manual/5.1/manual.html#2.5.9) 中的以下片段:

```

The colon syntax is used for defining methods, that is, functions that
have an implicit extra parameter self. Thus, the statement

     function t.a.b.c:f (params) body end

is syntactic sugar for

     t.a.b.c.f = function (self, params) body end
```

冒号的操作，只有当变量是类对象时才需要。有关如何使用 Lua 构造类，大家可参考相关章节。
