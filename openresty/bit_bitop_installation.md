# 五，Lua BitOp 的安装

- [一，复习二进制补码](./bit_two's_complement.md)
- [二，复习位运算](./bit_operations_review.md)
- [三，LuaJIT 和 Lua BitOp Api](./bit_LuaJIT_BitOp_Api.md)
- [四，位运算算法实例](./bit_bitwise_operation_example.md)
- [五，Lua BitOp 的安装](./bit_bitop_installation.md)

**本文是官方文档的翻译，仅供参考。请需要查看英文原文的小伙伴直接访问：[Lua BitOp Installation](http://bitop.luajit.org/install.html) 页面。**

本页介绍如何针对现有的 Lua 安装版本，从源代码构建 Lua BitOp。如果您是使用包管理器（例如，作为 Linux 发行版的一部分）安装的 Lua，建议您检查并安装 Lua BitOp 的预构建包作为代替。

## 一，先决条件

要编译 Lua BitOp，您的 Lua 5.1/5.2 安装版本必须包括所有开发文件（例如，include files（包含文件））。如果您是从源代码安装 Lua 的，那么您已经安装了它们（比如，在 POSIX 系统上的 `/usr/local/include` 目录中）。

如果您是使用包管理器安装的 Lua，则可能需要安装额外的 Lua 开发包（例如，Debian/Ubuntu 上的`liblua5.1-dev`）。

可能目前任何可以编译 Lua 的 C 编译器也适用于 Lua BitOp。 C99 `<stdint.h>` include 文件是必需的，但是源代码包含 MSVC 的解决方法。

默认情况下，Lua 被配置为使用 `double` 作为其 `number` 类型。 Lua BitOp 支持 IEEE 754 双精度配置，或使用 `int32_t` 或 `int64_t` 的替代配置（适用于没有浮点硬件的嵌入式系统）。并不支持浮点数类型。

## 二，配置

您可能需要修改构建脚本，并更改指向 Lua 开发文件或某些编译器标志的路径。检查 `Makefile`（POSIX）、`Makefile.mingw`（Windows 上的 MinGW）或 `msvcbuild.bat`（Windows 上的 MSVC）的开头，然后按照注释中的说明进行操作。

例如，如果您已安装 Debian/Ubuntu Lua 开发包，则 Lua 5.1 的 include files（包含文件）位于 `/usr/include/lua5.1` 中。

## 三，编译 & 安装

[下载](http://bitop.luajit.org/download.html) Lua BitOp 之后，解压缩分发文件，打开一个 `终端/命令` 窗口，切换到新创建的目录，然后按照以下说明进行操作。

### 1，Linux，\*BSD，Mac OS X

对于 Linux，\*BSD 和大多数其他 POSIX 系统只需要运行：

```bash
$ make
```

对于 Mac OS X，您需要运行以下命令：

```bash
$ make macosx
```

您可能需要 `root` 用户权限才能将生成的 `bit.so` 安装到当前 Lua 安装的 C 模块目录中。大多数系统提供 `sudo` ，因此您可以运行：

```bash
$ sudo make install
```

### 2，Windows 上的 MinGW
启动命令提示符，并确保 MinGW 工具在您的 PATH 中。然后运行以下命令：

```bash
mingw32-make -f Makefile.mingw
```

如果您已经调整了用于 Lua 的 C 模块的安装路径，则可以运行：

```bash
mingw32-make -f Makefile.mingw install
```

否则，只需将文件 `bit.dll` 复制到适当的目录即可。默认情况下，这个目录与 `lua.exe` 所在的目录相同。

### 3，Windows 上的 MSVC
打开一个 “ Visual Studio .NET 命令提示符”，切换到 `msvcbuild.bat` 所在的目录并运行它：

```
msvcbuild
```

如果文件 `bit.dll` 已成功构建，请将其复制到安装了 Lua 的 C 模块的目录。默认情况下，这是 `lua.exe` 所在的目录。

### 4，嵌入式 Lua BitOp
如果要将 Lua 嵌入到您的应用程序中，那么将 Lua BitOp 作为静态模块添加是非常简单的：

1. 将文件 `bit.c` 从 Lua BitOp 分发版复制到 Lua 源代码目录。

2. 将此文件添加到您的构建脚本中（例如，修改 Makefile）或将其作为构建依赖项导入到您的 IDE 中。

3. 编辑 `lualib.h` 并添加以下两行：
    ```c
    #define LUA_BITLIBNAME "bit"
    LUALIB_API int luaopen_bit(lua_State *L);
    ```
4. 编辑 `linit.c` 并将其添加到紧接 `{NULL, NULL}` 的行之前：
    ```c
    {LUA_BITLIBNAME, luaopen_bit},
    ```
5. 现在重新编译就可以了！

## 四，测试
您可以选择测试 Lua BitOp 的安装是否成功。保持 `终端/命令` 窗口打开并运行以下命令之一：

对于 Linux，\*BSD 和 Mac OS X：

```
$ make test
```

对于 Windows 上的 MinGW：

```
mingw32-make -f Makefile.mingw 测试
```

对于 Windows 上的 MSVC：

```
msvctest
```

如果任何测试失败，请检查您是否已在构建脚本中正确设置了路径，并使用了与编译安装 Lua 相同的 headers  进行编译（特别是如果您更改了 `luaconf.h` 中的 number  类型）并将 C 模块安装到与 Lua 安装匹配的目录中。如果您已安装了多个 Lua 解释器（例如，在 `/usr/bin` 和 `/usr/local/bin` 中），请仔细检查所有内容。

如果您收到关于 `tostring()` 函数或十六进制字符损坏的警告或失败，则说明您安装的 Lua 是存在缺陷的。请与您的发行商联系，替换/升级损坏的编译器或 C 库，或者您自己使用正确的配置设置重新安装 Lua（需特别注意 `luaconf.h` 中的 `LUA_NUMBER_*` 和 `luai_num*`）。

### 五，基准测试
该发行版包含了以下几个基准测试：

- `bitbench.lua` 测试基础位操作的速度。该基准测试是自动缩放的，每个部分的最小运行时间为 1 秒。首先计算循环开销，然后从随后的测量中减去。运行位操作的时间包括设置其参数和调用相应的 C 函数的开销。
- `nsievebits.lua` 是一个简单的基准测试，改编自 [计算机语言基准游戏](http://shootout.alioth.debian.org/)（以前称为计算机语言大战）。比例因子是指数级的，因此请使用介于 2 ~ 10 之间的一个小数字来运行它，并对其计时（例如，`time lua nsievebits.lua 6`）。
- 当给定参数 “bench” 时，`md5test.lua` 运行一个自动缩放基准测试，并打印出计算（中等长度）字符串的 MD5 散列所需的每个字符的时间。请注意，这个实现主要用于回归测试。它不适合与完全优化的 MD5 实现进行跨语言比较
