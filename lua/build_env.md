#搭建Lua环境

FIXME: 或许我们可以建议大家直接使用 OpenResty 自带的 LuaJIT 甚至 resty 命令行工具来作为这里试验用的 Lua 环境？

####在 Mac OS X 上搭建环境

TODO 补充细节

####在Linux上搭建环境

本书以Ubuntu为例来说明。首先，使用apt-cache命令查看有哪些版本的LuaJIT可以安装。

######安装LuaJIT

在ubuntun系统上，使用apt-get insall命令安装LuaJIT：

```
sudo apt-get install luajit
```

######验证LuaJIT是否安装成功

输入**luajit -v**查看LuaJIT版本，如果返回以下类似内容，则说明安装成功：

```
LuaJIT 2.0.3 -- Copyright (C) 2005-2014 Mike Pall. http://luajit.org/
```

如果想了解其他系统安装LuaJIT的步骤，或者安装过程中遇到问题，可以到LuaJIT官网查看：[http://luajit.org/install.html](http://luajit.org/install.html)

####选择一个好用的代码编辑器：Sublime Text

FIXME 貌似没有必要特别推荐某一种代码编辑器。比如我就喜欢用 Vim，相信也有不少 Emacs 的用户，甚至 Eclipse 和 TextMate 的用户。只需要强调纯文本编辑器就好了。

一个好的代码编辑器可以让我们编写代码时更加顺手，虽然Lua有相应的IDE编辑环境，但是我们建议您使用Sublime作为您
的代码编辑器。Sublime文本编辑器有很多可选的插件包，可以帮助我们的代码编写。本书的代码都是在Sublime上进行编辑的。

#Hello World程序

安装好LuaJIT后，我们来运行我们的第一个程序：HelloWorld.lua。

>代码

```lua
print("Hello World")
```

到HelloWorld.lua所在目录下，运行```luajit ./HelloWorld.lua```运行这个HelloWorld.lua程序，输出如下结果：

```
Hello World
```
