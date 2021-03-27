# 三，LuaJIT 中的 bit 操作和 Lua BitOp API 简介

- [一，复习二进制补码](./bit_two's_complement.md)
- [二，复习位运算](./bit_operations_review.md)
- [三，LuaJIT 和 Lua BitOp Api](./bit_LuaJIT_BitOp_Api.md)
- [四，位运算算法实例](./bit_bitwise_operation_example.md)
- [五，Lua BitOp 的安装](./bit_bitop_installation.md)

## 1，LuaJIT 中的 bit 操作
因为从 OpenResty 1.5.8.1 就默认使用 LuaJIT 作为内置组件，我们可以在
LuaJIT 网站介绍 [扩展模块](https://luajit.org/extensions.html) 的页面上看到下面的描述：

> LuaJIT 提供了几个内置扩展模块：
>
> Bit.* —— 位运算模块。
> LuaJIT 支持 [Lua BitOp](https://bitop.luajit.org/) 定义的所有位操作：
>
> ```lua
> bit.tobit,  bit.tohex,  bit.bnot,    bit.band, bit.bor,  bit.bxor,
> bit.lshift, bit.rshift, bit.arshift, bit.rol,  bit.ror,  bit.bswap。
> ```
> 这个模块是 LuaJIT 内置的——您不需要下载或安装 Lua BitOp。Lua BitOp 站点提供了所有 [Lua BitOp API 函数](https://bitop.luajit.org/api.html) 的完整文档。
>
> 在使用模块的任何功能之前，请确保用 `require` 加载该模块：
>
> ```lua
> local bit = require("bit")
> ```
>
> LuaJIT 会忽略已经安装的 Lua BitOp 模块。这样，您就可以在共享安装上同时使用 Lua 和 LuaJIT 的位操作。

## 2，Lua BitOp API 简介

### 2.1 定义快捷方式

将常用的模块函数缓存在本地变量中是一种常见的（但不是必须的）做法。这作为一种快捷方式，可以节省一些输入，还可以加快解析它们的速度（只有在调用数十万次时才有意义）。

```lua
-- 请将下面的三行代码放在使用位运算开始的位置（这是个好习惯）
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol
-- 等等

-- 使用快捷方式的示例:
local function tr_i(a, b, c, d, x, s)
  return rol(bxor(c, bor(b, bnot(d))) + a + x, s) + b
end
```

请谨记，`and`、`or` 和 `not` 是 Lua 中的保留关键字。它们不能用于变量名或字面量字段名。这就是为什么将相应的位操作函数命名为 `band`、`bor` 和 `bnot`（以及为保持一致性的 `bxor`）的原因。

> 注意：一个常见的陷阱是使用 `bit` 作为局部临时变量的名称 —— 好吧，不要这样做！


### 2.2 位操作函数的返回值

**请注意**，所有位操作都返回 **有符号** 的 32 位数字（ [原理](https://bitop.luajit.org/semantics.html#range) ）。默认情况下，这些数字打印为有符号的十进制数字。


### 2.3 位操作函数简介

- #### (1) y = bit.tobit(x)

    将一个数字归一化为位运算的数值范围并返回。通常不需要这个函数，因为所有的位运算都已经对其所有的输入参数进行了归一化处理。详情请查看 [操作语义](http://bitop.luajit.org/semantics.html)。

    ```lua
    print(0xffffffff)                --> 4294967295 (*)
    print(bit.tobit(0xffffffff))     --> -1
    print(bit.tobit(0xffffffff + 1)) --> 0
    print(bit.tobit(2^40 + 1234))    --> 1234
    ```

- #### (2) y = bit.tohex(x [,n])

    将函数的第一个参数转换为十六进制字符串。

    - 十六进制数字显示的数目由可选的第二个参数的绝对值给出。
    - 介于 1 到 8 之间的正数会生成小写的十六进制数字。
    - 负数生成大写的十六进制数字。
    - 仅使用最低有效的 4 * |n| 位。
    - 默认值：生成 8 个小写的十六进制数字。

    ```lua
    print(bit.tohex(1))              --> 00000001
    print(bit.tohex(-1))             --> ffffffff
    print(bit.tohex(0xffffffff))     --> ffffffff
    print(bit.tohex(-1, -8))         --> FFFFFFFF
    print(bit.tohex(0x21, 4))        --> 0021
    print(bit.tohex(0x87654321, 4))  --> 4321
    ```

- #### (3) y = bit.bnot(x)   **按位 NOT**

    返回其参数的 **按位 NOT** 的结果。

    ```lua
    print(bit.bnot(0))            --> -1
    printx(bit.bnot(0))           --> 0xffffffff
    print(bit.bnot(-1))           --> 0
    print(bit.bnot(0xffffffff))   --> 0
    printx(bit.bnot(0x12345678))  --> 0xedcba987
    ```

- #### (4) y = bit.bor(x1 [,x2...])  **按位或**
    返回其所有参数的 **按位或** 运算结果。允许使用两个以上的参数。

    ```lua
    print(bit.bor(1, 2, 4, 8))                --> 15
    ```

- #### (5) y = bit.band(x1 [,x2...])   **按位与**
    返回其所有参数的 **按位与** 运算结果。允许使用两个以上的参数。

    ```lua
    printx(bit.band(0x12345678, 0xff))        --> 0x00000078
    ```

- #### (6) y = bit.bxor(x1 [,x2...])    **按位异或**
    返回其所有参数的 **按位异或** 运算结果。允许使用两个以上的参数。

    ```lua
    printx(bit.bxor(0xa5a5f0f0, 0xaa55ff00))  --> 0x0ff00ff0
    ```

- #### (7) y = bit.lshift(x, n)          **按位逻辑左移**
    返回其第一个参数 **按位逻辑左移** 的运算结果，移动的位数由第二个参数给出。

    ```lua
    -- 按位逻辑左移
    print(bit.lshift(1, 0))              --> 1
    print(bit.lshift(1, 8))              --> 256
    print(bit.lshift(1, 40))             --> 256
    ```

- #### (8) y = bit.rshift(x, n)           **按位逻辑右移**
    返回其第一个参数 **按位逻辑右移** 的运算结果，移动的位数由第二个参数给出。
    ```lua
    -- 按位逻辑右移
    print(bit.rshift(256, 8))            --> 1
    print(bit.rshift(-256, 8))           --> 16777215    -- 符号位没有被保留
    ```

    > 以上两种 **逻辑移位** (Logical shifts) 操作会将第一个参数视为 **无符号** 数，最小移位可以是 0 位。

- #### (9) y = bit.arshift(x, n)           **按位算术右移**

    返回其第一个参数 **按位算术右移** 的运算结果，移动的位数由第二个参数给出。

    ```lua
    -- 按位算术右移（符号位会被保留）
    print(bit.arshift(256, 8))           --> 1
    print(bit.arshift(-256, 8))          --> -1

    -- 三种移位运算的十六进制表示形式
    printx(bit.lshift(0x87654321, 12))   --> 0x54321000
    printx(bit.rshift(0x87654321, 12))   --> 0x00087654
    printx(bit.arshift(0x87654321, 12))  --> 0xfff87654
    ```

    > **算术右移** (Arithmetic right-shift) 操作会将最高有效位视为符号位，并且会在移动过程中被复制保留下来。
    仅使用移位计数的低 5 位（减小到 [0...31] 范围）。

- #### (10) y = bit.rol(x, n)          **按位向左旋转**

    返回其第一个参数 **按位向左旋转** 的运算结果，旋转位数由第二个参数给出。
    从一边移出的位元会从另一边移回来。

    ```lua
    printx(bit.rol(0x12345678, 12))   --> 0x45678123
    ```

- #### (11) y = bit.ror(x, n)          **按位向右旋转**

    返回其第一个参数 **按位向右旋转** 的运算结果，旋转的位数由第二个参数给出。
    从一边移出的位元会从另一边移回来。

    ```lua
    printx(bit.rol(0x12345678, 12))   --> 0x45678123
    printx(bit.ror(0x12345678, 12))   --> 0x67812345
    ```
    > 以上两种旋转操作都是只使用较低的 5 位旋转计数 (减少到范围 [0..31])。

- #### (12) y = bit.bswap(x)         **交换字节**
    交换其参数的字节并返回它。这可用于将小端 32 位数字转换为大端 32 位数字，反之亦然。

    ```lua
    printx(bit.bswap(0x12345678)) --> 0x78563412
    printx(bit.bswap(0x78563412)) --> 0x12345678
    ```
