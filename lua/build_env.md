#搭建Lua环境

####在Windows上搭建环境

######下载安装包

前往官网下载LuaJIT源码压缩包，网址：[http://luajit.org/download.html]([http://luajit.org/download.html)。本书以LuaJIT-2.0.4为例。

######安装Lua

使用visual studio编译刚才下载好的源码包：开始 –> 程序 –> Microsoft Visual Studio xx –> Visual Studio Tools –> Visual Studio 命令提示。

然后切换至LuaJIT的src目录，运行msvcbuild.bat

将生成的luajit.exe、lua51.dll、jit 复制到打包工具的相对目录下，这样在工具中就可以直接调用luajit –b source_file out_file (一般都是lua后缀，代码不用改动)

如果你windows系统中没有安装visual studio或者不想手工编译，可以直接在网上搜索下载已经被别人编译好的LuaJIT。

####在Linux上搭建环境

本书以Ubuntu为例来说明。首先，使用apt-cache命令查看有哪些版本的luajit可以安装。

######安装Luajit

在ubuntun系统上，使用apt-get insall命令安装luajit：

```
sudo apt-get install luajit
```

######验证Luajit是否安装成功

输入**luajit -v**查看luajit版本，如果返回以下类似内容，则说明安装成功：

```
LuaJIT 2.0.3 -- Copyright (C) 2005-2014 Mike Pall. http://luajit.org/
```

如果想了解其他系统安装LuaJIT的步骤，或者安装过程中遇到问题，可以到LuaJIT官网查看：[http://luajit.org/install.html](http://luajit.org/install.html)

####选择一个好用的代码编辑器：Sublime Text

一个好的代码编辑器可以让我们编写代码时更加顺手，虽然Lua有相应的IDE编辑环境，但是我们建议您使用Sublime作为您
的代码编辑器。Sublime文本编辑器有很多可选的插件包，可以帮助我们的代码编写。本书的代码都是在Sublime上进行编辑的。


#Hello World程序

安装好LuaJIT后，我们来运行我们的第一个程序：HelloWorld.lua。

>代码

```
function main()
  print("Hello World")
end

main()
```

到HelloWorld.lua所在目录下，运行```luajit ./HelloWorld.lua```运行这个HelloWorld.lua程序，输出如下结果：
```
Hello World
```
