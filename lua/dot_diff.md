# 点号与冒号操作符的区别

> 看下面示例代码：

```lua
local str = "abcde"
print("case 1:", str:sub(1, 2))
print("case 2:", str.sub(str, 1, 2))
```

> output:

```
case 1: ab
case 2: ab
```

冒号操作会带入一个`self`参数，用来代表`自己`。而逗号操作，只是`内容`的展开。

冒号的操作，只有当变量是类对象时才需要。有关如何使用Lua构造类，大家可参考相关章节。
