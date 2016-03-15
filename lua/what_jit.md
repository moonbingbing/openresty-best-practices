# 什么是 JIT ？

自从 OpenResty 1.5.8.1 版本之后，默认捆绑的 Lua 解释器就被替换成了 LuaJIT ，而不在是标准 Lua。单从名字上，我们就可以直接看到这个新的解释器多了一个 `JIT`，接下来我们就一起来聊聊这个 `JIT` 是个什么东东。

我们先来看一下 LuaJIT 官方站点的解释： LuaJIT is a Just-In-Time Compilerfor the Lua programming language。

肯定有读者可能要问了，什么 Just-In-Time ？他的中文名称是即时编译器，是一个把程序字节码（包括需要被解释的指令的程序）转换成可以直接发送给处理器的指令的程序。

还没听懂？说的再直白一些，就是把 Lua 代码直接解释成 CPU 可以执行的指令，要知道原本 Lua 代码是只能在 Lua 虚拟机中运行，现在突然有办法让 Lua 代码一次编译后直接运行在 CPU 上，效率自然更胜一筹。

给这个 JIT 吹了半天，实用效果怎样？大家看下面例子：

```shell
➜ cat test.lua
local s = [[aaaaaabbbbbbbcccccccccccddddddddddddeeeeeeeeeeeee
fffffffffffffffffggggggggggggggaaaaaaaaaaabbbbbbbbbbbbbb
ccccccccccclllll]]

for i=1,10000 do
    for j=1,10000 do
        string.find(s, "ll", 1, true)
    end
end

➜ time luajit test.lua
5.19s user
0.03s system
96% cpu
5.392 total

➜  time lua test.lua
9.20s user
0.02s system
99% cpu
9.270 total
```

本例子可以看到效率相差大约 9.2/5.19 ≈ 1.77 倍，换句话说标准 Lua 需要 177% 的时间才能完成同样的工作。估计大家觉得这个还不过瘾，再看下面示例代码：

> 文件 test.lua：

```lua

local loop_count = tonumber(arg[1])
local fun_pair = "ipairs" == arg[2] and ipairs or pairs

local t = {}
for i=1,100 do
    t[i] = i
end

for i=1,loop_count do
    for j=1,1000 do
        for k,v in fun_pair(t) do
            --
        end
    end
end
```

|执行参数|执行结果|
|------|------|
|time lua test.lua 1000 ipairs|3.96s user 0.02s system 98% cpu 4.039 total|
|time lua test.lua 1000 pairs|3.97s user 0.01s system 99% cpu 3.992 total|
|time luajit test.lua 1000 ipairs|0.10s user 0.00s system 95% cpu 0.113 total|
|time luajit test.lua 10000 ipairs|0.98s user 0.00s system 99% cpu 0.991 total|
|time luajit test.lua 1000 pairs|1.54s user 0.01s system 99% cpu 1.559 total|

从这个执行结果中，大致可以总结出下面几个观点：

* 在标准 Lua 解释器中，使用 ipairs 或 pairs 没有区别。
* 对于 pairs 方式，LuaJIT 的性能大约是标准 Lua 的 4 倍。
* 对于 ipairs 方式，LuaJIT 的性能大约是标准 Lua 的 40 倍。

本书中曾多次提及，尽量使用支持可以被 JIT 编译的 API。到底有哪些 API 是可以被 JIT 编译呢？我们的参考来来源是哪里呢？LuaJIT 的官方地址：[http://wiki.luajit.org/NYI](http://wiki.luajit.org/NYI)，需要最新动态的同学，不妨多看看这个地址的内容。下面我们把重要的几个库是否支持 JIT 的点罗列一下。

### 基础库的支持情况

|   函数    |   编译?   |   备注 |
|---------|--------|-----------------|
|   assert  |   yes |       |
|   collectgarbage  |   no  |       |
|   dofile  |   never   |       |
|   error   |   never   |       |
|   getfenv |   2.1 partial |   只有 getfenv(0) 能编译    |
|   getmetatable    |   yes |       |
|   ipairs  |   yes |       |
|   load    |   never   |       |
|   loadfile    |   never   |       |
|   loadstring  |   never   |       |
|   next    |   no  |       |
|   pairs   |   no  |       |
|   pcall   |   yes |       |
|   print   |   no  |       |
|   rawequal    |   yes |       |
|   rawget  |   yes |       |
|   rawlen (5.2)    |   yes |       |
|   rawset  |   yes |       |
|   select  |   partial |  第一个参数是静态变量的时候可以编译|
|   setfenv |   no  |       |
|   setmetatable    |   yes |       |
|   tonumber    |   partial | 不能编译非10进制，非预期的异常输入 |
|   tostring    |   partial | 只能编译：字符串、数字、布尔、nil 以及支持 __tostring元方法的类型 |
|   type    |   yes |       |
|   unpack  |   no  |       |
|   xpcall  |   yes |       |

### 字符串库

|   函数    |   编译?   |   备注 |
|---------|----------|-------------|
|   string.byte |   yes |       |
|   string.char |   2.1 |       |
|   string.dump |   never   |       |
|   string.find |   2.1 partial | 只有字符串样式查找（没有样式）|
|   string.format   |   2.1 partial |  不支持 %p 或 非字符串参数的 %s |
|   string.gmatch   |   no  |       |
|   string.gsub |   no  |       |
|   string.len  |   yes |       |
|   string.lower    |   2.1 |       |
|   string.match    |   no  |       |
|   string.rep  |   2.1 |       |
|   string.reverse  |   2.1 |       |
|   string.sub  |   yes |       |
|   string.upper    |   2.1 |       |

### 表

|   函数    |   编译?   |   备注 |
|---------|----------|-------------|
|   table.concat    |   2.1 |       |
|   table.foreach   |   no  |   2.1: 内部编译，但还没有外放 |
|   table.foreachi  |   2.1 |       |
|   table.getn  |   yes |       |
|   table.insert    |   partial |  只有 push 操作  |
|   table.maxn  |   no  |       |
|   table.pack (5.2)    |   no  |       |
|   table.remove    |   2.1 |  部分，只有 pop 操作 |
|   table.sort  |   no  |       |
|   table.unpack (5.2)  |   no  |       |

### math 库

|   函数    |   编译?   |   备注 |
|---------|----------|-------------|
|   math.abs    |   yes |       |
|   math.acos   |   yes |       |
|   math.asin   |   yes |       |
|   math.atan   |   yes |       |
|   math.atan2  |   yes |       |
|   math.ceil   |   yes |       |
|   math.cos    |   yes |       |
|   math.cosh   |   yes |       |
|   math.deg    |   yes |       |
|   math.exp    |   yes |       |
|   math.floor  |   yes |       |
|   math.fmod   |   no  |       |
|   math.frexp  |   no  |       |
|   math.ldexp  |   yes |       |
|   math.log    |   yes |       |
|   math.log10  |   yes |       |
|   math.max    |   yes |       |
|   math.min    |   yes |       |
|   math.modf   |   yes |       |
|   math.pow    |   yes |       |
|   math.rad    |   yes |       |
|   math.random |   yes |       |
|   math.randomseed |   no  |       |
|   math.sin    |   yes |       |
|   math.sinh   |   yes |       |
|   math.sqrt   |   yes |       |
|   math.tan    |   yes |       |
|   math.tanh   |   yes |       |

### 其他

其他还有 IO、Bit、FFI、Coroutine、OS、Package、Debug、JIT 等目录分类，使用频率相对较低，在这里就不逐一罗列，需要的同学可以到 [http://wiki.luajit.org/NYI](http://wiki.luajit.org/NYI) 查看。


