# 什么是 JIT？

自从 OpenResty 1.5.8.1 版本之后，默认捆绑的 Lua 解释器就被替换成了 LuaJIT，而不再是标准 Lua。单从名字上，我们就可以直接看到这个新的解释器多了一个 `JIT`，接下来我们就一起来聊聊 `JIT`。

先看一下 LuaJIT 官方的解释：LuaJIT is a Just-In-Time Compiler for the Lua programming language。

### LuaJIT 工作原理

#### 1、 LuaJIT 的组成
LuaJIT 的运行时环境包括一个用 **手写汇编实现的 Lua 解释器** 和一个可以 **直接生成机器代码的 JIT 编译器** 。

#### 2、 工作原理

- 1、Lua 代码在被执行之前总是会先被 lfn 成 LuaJIT 自己定义的 **字节码（Byte Code）**。
关于 LuaJIT 字节码的文档，可以参见：[http://wiki.luajit.org/Bytecode-2.0](http://wiki.luajit.org/Bytecode-2.0)（这个文档描述的是 LuaJIT 2.0 的字节码，不过 2.1 里面的变化并不算太大）。


- 2、一开始的时候，Lua 字节码总是被 LuaJIT 的解释器 **解释执行**。
    - LuaJIT 的解释器会在执行字节码的同时记录一些运行时的统计信息，比如每个 Lua 函数调用入口的实际运行次数，还有每个 Lua 循环的实际执行次数。
    - 当这些次数超过某个预设的阈值时，便认为对应的 Lua 函数入口或者对应的 Lua 循环 **足够的“热”**，这时便会 **触发 JIT 编译器开始工作**。

- 3、 `JIT` 编译器会从 **热函数** 的入口或者 **热循环** 的某个位置开始尝试编译对应的 Lua 代码路径。 编译的过程是：
    - 首先，把 LuaJIT **字节码** 转换成 LuaJIT 自己定义的 **中间码（IR）**；
    - 然后，再生成针对目标体系结构的 **机器码**（比如 x86_64 指令组成的机器码）。

- 4、 如果当前 Lua 代码路径上的所有的操作都可以被 JIT 编译器顺利编译，则这条编译过的代码路径便被称为一个 **`trace`**，在物理上对应一个 `trace` 类型的 GC 对象（即参与 Lua GC 的对象）。

### 工具和内部对象结构

#### 1、 查看工具和内容解析

- 1、 你可以通过 `ngx-lj-gc-objs` 工具看到指定的 Nginx worker 进程里所有 `trace` 对象的一些基本的统计信息，见 [https://github.com/openresty/stapxx#ngx-lj-gc-objs](https://github.com/openresty/stapxx#ngx-lj-gc-objs)

- 2、 比如下面这一行 `ngx-lj-gc-objs` 工具的输出：
    ```
    102 trace objects: max=928, avg=337, min=160, sum=34468 (in bytes)
    ```
    输出内容表明：当前进程内的 LuaJIT VM 里一共有 102 个 `trace` 类型的 GC 对象，其中最小的 `trace` 占用 160 个字节，最大的占用 928 个字节，平均大小是 337 字节，而所有 `trace` 的总大小是 34468 个字节。

#### 2、 不足之处
LuaJIT 的 `JIT` 编译器的实现目前还不完整，有一些基本原语它还无法编译，比如：
- `pairs()` 函数
- `unpack()` 函数
- `string.match()` 函数
- 基于 `lua_CFunction` 实现的 Lua C 模块
- FNEW 字节码，等等。

所以当 `JIT` 编译器在当前代码路径上遇到了它不支持的操作，便会立即终止当前的 `trace` 编译过程（这被称为 `trace abort`），而重新退回到解释器模式。

JIT 编译器不支持的原语被称为 NYI（Not Yet Implemented）原语。比较完整的 NYI 列表在这篇文档里面：http://wiki.luajit.org/NYI

#### 3、如何避坑

所谓 **让更多的 Lua 代码被 `JIT` 编译**，其实就是帮助更多的 Lua 代码路径能为 `JIT` 编译器所接受。这一般通过两种途径来实现：

- 1、 调整对应的 Lua 代码，避免使用 NYI 原语。
- 2、 增强 `JIT` 编译器，让越来越多的 NYI 原语能够被编译。

对于第 2 种方式，春哥一直在推动公司（CloudFlare）赞助 Mike Pall 的开发工作。 不过有些原语因为本身的代价过高，而永远不会被编译，比如基于经典的 `lua_CFunction` 方式实现的 Lua C 模块（所以需要尽量通过 LuaJIT 的 FFI 来调用 C）。

而对于第 1 种方法，我们如何才能知道具体是哪一行 Lua 代码上的哪一个 NYI 原语终止了 `trace` 编译呢？

答案很简单。就是使用 LuaJIT 安装自带的 `jit.v` 和 `jit.dump` 这两个 Lua 模块。这两个 Lua 模块会打印出 `JIT` 编译器工作的细节过程。

#### 4、实例分析

在 Nginx 的上下文中，我们可以在 `nginx.conf` 文件中的 `http {}` 配置块中添加下面这一段：

```
init_by_lua_block {
    local verbose = false
    if verbose then
        local dump = require("jit.dump")
        dump.on(nil, "/tmp/jit.log")
    else
        local v = require("jit.v")
        v.on("/tmp/jit.log")
    end

    require("resty.core")
}
```

那一行 `require("resty.core")` 倒并不是必需的，放在那里的主要目的是为了尽量避免使用 `ngx_lua` 模块自己的基于 `lua_CFunction` 的 Lua API，减少 NYI 原语。

在上面这段 Lua 代码中，可以下分为如下两种情况：
- 当 `verbose` 变量为 `false` 时（默认就为 `false` 哈），我们使用 `jit.v` 模块打印出比较简略的流水信息到 `/tmp/jit.log` 文件中；
- 而当 `verbose` 变量为 `true` 时，我们则使用 `jit.dump` 模块打印所有的细节信息，包括每个 `trace` 内部的字节码、IR 码和最终生成的机器指令。

这里我们主要以 `jit.v` 模块为例。 在启动 Nginx 之后，应当使用 `ab` 和 `weighttp` 这样的工具对相应的服务接口进行预热，以触发 LuaJIT 的 `JIT` 编译器开始工作（还记得刚才我们说的 **“热函数”** 和 **“热循环”** 吗？）。
预热过程一般不用太久，跑个二三百个请求足矣。当然，压更多的请求也没关系。完事后，我们就可以检查 `/tmp/jit.log` 文件里面的输出了。

`jit.v` 模块的输出里如果有类似下面这种带编号的 TRACE 行，则表示成功编译了的 `trace` 对象，例如：

- 1、单行的

    ```
    [TRACE   6 shdict.lua:126 return]
    ```
    解析：这个 `trace` 对象编号为 6，对应的 Lua 代码路径是从 `shdict.lua` 文件的第 126 行开始的。

- 2、关联的
    下面这样的也是成功编译了的 `trace`:

    ```
    [TRACE  16 (15/1) waf-core.lua:419 -> 15]
    ```
    解析：这个 `trace` 编号为 16，是从 `waf-core.lua` 文件的第 419 行开始的，同时它和编号为 15 的 `trace` 联接了起来。

- 3、被中断的
    而下面这个例子则是被中断的 `trace`:

    ```
    [TRACE --- waf-core.lua:455 -- NYI: FastFunc pairs at waf-core.lua:458]
    ```
    解析：上面这一行是说，这个 `trace` 是从 `waf-core.lua` 文件的第 455 行开始编译的，但当编译到 `waf-core.lua` 文件的第 458 行时，遇到了一个 NYI 原语编译不了，即 `pairs()` 这个内建函数，于是当前的 `trace` 编译过程被迫终止了。

    类似的例子还有下面这些：
    ```
    [TRACE --- exit.lua:27 -- NYI: FastFunc coroutine.yield at waf-core.lua:439]
    [TRACE --- waf.lua:321 -- NYI: bytecode 51 at raven.lua:107]
    ```
    解析：上面第二行是因为操作码 51 的 LuaJIT 字节码也是 NYI 原语，编译不了。

#### 5、 探查字节码的工具
那么我们如何知道 51 字节码究竟是啥呢？我们可以用 `nginx-devel-utils` 项目中的 `ljbc.lua` 脚本来取得 51 号字节码的名字：
```
# /usr/local/openresty/luajit/bin/luajit-2.1.0-alpha ljbc.lua 51
opcode 51:
FNEW
```
我们看到原来是用来（动态）创建 Lua 函数的 FNEW 字节码。

`ljbc.lua` 脚本的位置是：
```
https://github.com/agentzh/nginx-devel-utils/blob/master/ljbc.lua
```
非常简单的一个脚本，就几行 Lua 代码。

这里需要提醒的是，不同版本的 LuaJIT 的字节码可能是不相同的，所以一定要使用和你的 Nginx 链接的同一个 LuaJIT 来运行这个 `ljbc.lua` 工具，否则有可能会得到错误的结果。

#### 6、对比实验
我们实际做个对比实验，看看 `JIT` 带来的好处：

```shell
# cat test.lua
local s = [[aaaaaabbbbbbbcccccccccccddddddddddddeeeeeeeeeeeee
fffffffffffffffffggggggggggggggaaaaaaaaaaabbbbbbbbbbbbbb
ccccccccccclllll]]

for i=1,10000 do
    for j=1,10000 do
        string.find(s, "ll", 1, true)
    end
end

# time luajit test.lua
5.19s user
0.03s system
96% cpu
5.392 total

#  time lua test.lua
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

|  执行参数                           |  执行结果                                     |
|:------------------------------------|:----------------------------------------------|
| <font color="Darkorange">(下面三行是 ipairs 测试结果)</font> ||
|  time <font color="red">lua</font> test.lua 1000 <font color="Darkorange">ipairs</font>      |  <font color="red">3.96s</font>  user 0.02s  system  98%  cpu  <font color="red">4.039</font>  total  |
|  time <font color="blue">luajit</font> test.lua 1000 <font color="Darkorange">ipairs</font>   |  <font color="blue">0.10s</font>  user 0.00s  system  95%  cpu  <font color="blue">0.113</font>  total  |
|  time <font color="blue">luajit</font> test.lua 10000 <font color="Darkorange">ipairs</font>  |  <font color="blue">0.98s</font>  user 0.00s  system  99%  cpu  <font color="blue">0.991</font>  total  |
| <font color="DarkGoldenRod">(下面两行是 pairs 测试结果)</font> ||
|  time <font color="red">lua</font> test.lua 1000 <font color="DarkGoldenRod">pairs</font>       |  <font color="red">3.97s</font>  user 0.01s  system 99%  cpu  <font color="red">3.992</font>  total  |
|  time <font color="blue">luajit</font> test.lua 1000 <font color="DarkGoldenRod">pairs</font>    |  <font color="blue">1.54s</font>  user 0.01s  system 99%  cpu  <font color="blue">1.559</font>  total  |

从这个执行结果中，大致可以总结出下面几点：

* 在标准 Lua 解释器中，使用 `ipairs` 或 `pairs` **没有区别**；
* 对于 `pairs` 方式，LuaJIT 的性能大约是标准 Lua 的 **4 倍**；
* 对于 `ipairs` 方式，LuaJIT 的性能大约是标准 Lua 的 **40 倍**。

### 可以被 JIT 编译的元操作

下面给大家列一下截止到目前已经可以被 JIT 编译的元操作。
其他还有 IO、Bit、FFI、Coroutine、OS、Package、Debug、JIT 等分类，使用频率相对较低，这里就不罗列了，可以参考官网：[http://wiki.luajit.org/NYI](http://wiki.luajit.org/NYI)。

#### 基础库的支持情况

|  函数            |  编译?        |  备注                                                               |
|:-----------------|:--------------|:--------------------------------------------------------------------|
|  assert          |  yes          |                                                                     |
|  <font color="red">collectgarbage</font>   |  <font color="red">no</font> |                            |
|  <font color="Blue">dofile</font>          | <font color="Blue">never</font> |                         |
|  <font color="Blue">error</font>           |  <font color="Blue">never</font> |                        |
|  getfenv         |  2.1 partial  |  只有 getfenv(0) 能编译                                              |
|  getmetatable    |  yes          |                                                                     |
|  ipairs          |  yes          |                                                                     |
|  <font color="Blue">load</font>            |  <font color="Blue">never</font> |                        |
|  <font color="Blue">loadfile</font>        |  <font color="Blue">never</font> |                        |
|  <font color="Blue">loadstring</font>      |  <font color="Blue">never</font> |                        |
|  <font color="red">next</font>   |  <font color="red">no</font>  |                                     |
|  <font color="red">pairs</font>  |  <font color="red">no</font>  |                                     |
|  pcall           |  yes          |                                                                     |
|  <font color="red">print</font>  |  <font color="red">no</font>  |                                     |
|  rawequal        |  yes          |                                                                     |
|  rawget          |  yes          |                                                                     |
|  rawlen (5.2)    |  yes          |                                                                     |
|  rawset          |  yes          |                                                                     |
|  select          |  partial      |  第一个参数是静态变量的时候可以编译                                    |
|  <font color="red">setfenv</font>|  <font color="red">no</font>  |                                     |
|  setmetatable    |  yes          |                                                                     |
|  tonumber        |  partial      |  不能编译非10进制，非预期的异常输入                                 |
|  tostring        |  partial      |  只能编译：字符串、数字、布尔、nil 以及支持 __tostring元方法的类型  |
|  type            |  yes          |                                                                     |
|  <font color="red">unpack</font> |  <font color="red">no</font>   |                                    |
|  xpcall          |  yes          |                                                                     |

#### 字符串库

|  函数            |  编译?        |  备注                            |
|:-----------------|:--------------|:---------------------------------|
|  string.byte     |  yes          |                                  |
|  string.char     |  2.1          |                                  |
|  <font color="Blue">string.dump</font>    |  <font color="Blue">never</font>       |  |
|  string.find     |  2.1 partial  |  只有字符串样式查找（没有样式）  |
|  string.format   |  2.1 partial  |  不支持 %p 或 非字符串参数的 %s    |
|  <font color="red">string.gmatch</font>   |  <font color="red">no</font>           |  |
|  <font color="red">string.gsub</font>     |  <font color="red">no</font>           |  |
|  string.len      |  yes          |                                  |
|  string.lower    |  2.1          |                                  |
|  <font color="red">string.match</font>    |  <font color="red">no</font>           |  |
|  string.rep      |  2.1          |                                  |
|  string.reverse  |  2.1          |                                  |
|  string.sub      |  yes          |                                  |
|  string.upper    |  2.1          |                                  |

#### 表

|  函数                |  编译?     |  备注                        |
|:---------------------|:----------|:------------------------------|
|  table.concat        |  2.1      |                               |
|  <font color="red">table.foreach</font>       |  <font color="red">no</font>       |  2.1: 内部编译，但还没有外放    |
|  table.foreachi      |  2.1      |                               |
|  table.getn          |  yes      |                               |
|  table.insert        |  partial  |  只有 push 操作                |
|  <font color="red">table.maxn</font>          |  <font color="red">no</font>       |                               |
|  <font color="red">table.pack</font> (5.2)    |  <font color="red">no</font>       |                               |
|  table.remove        |  2.1      |  部分，只有 pop 操作           |
|  <font color="red">table.sort</font>          |  <font color="red">no</font>       |                               |
|  <font color="red">table.unpack</font> (5.2)  |  <font color="red">no</font>       |                               |

#### math 库

|  函数             |  编译?  |  备注  |
|:------------------|:--------|:-------|
|  math.abs         |  yes    |        |
|  math.acos        |  yes    |        |
|  math.asin        |  yes    |        |
|  math.atan        |  yes    |        |
|  math.atan2       |  yes    |        |
|  math.ceil        |  yes    |        |
|  math.cos         |  yes    |        |
|  math.cosh        |  yes    |        |
|  math.deg         |  yes    |        |
|  math.exp         |  yes    |        |
|  math.floor       |  yes    |        |
|  <font color="red">math.fmod</font>  |   <font color="red">no</font>     |        |
|  <font color="red">math.frexp</font> |   <font color="red">no</font>     |        |
|  math.ldexp       |  yes    |        |
|  math.log         |  yes    |        |
|  math.log10       |  yes    |        |
|  math.max         |  yes    |        |
|  math.min         |  yes    |        |
|  math.modf        |  yes    |        |
|  math.pow         |  yes    |        |
|  math.rad         |  yes    |        |
|  math.random      |  yes    |        |
|  <font color="red">math.randomseed</font>  |  <font color="red">no</font> |        |
|  math.sin         |  yes    |        |
|  math.sinh        |  yes    |        |
|  math.sqrt        |  yes    |        |
|  math.tan         |  yes    |        |
|  math.tanh        |  yes    |        |
