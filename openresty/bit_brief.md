# 在 OpenResty 中如何完成 bit 操作

编程世界中的所有东西都会从 **位 (bit)** 开始，以 **位 (bit)** 结束。刚步入编程世界的初学者看到整数就是整数，看到字符串就是字符串。

但在功力深厚的程序员眼中，无论是 “整数” 还是 “字符串”，它们都是 **位 (bit)**。电影《黑客帝国》中，主人公尼奥眼里的史密斯就是由绿色位代码构成的计算机程序。

与系统编程不同，我们可以感觉到在一般的应用程序编程中对位运算的要求并不高。

> 以上内容引用自《枕边算法书》。

本小节分为以下 6 个部分：

- [一，复习二进制补码](./bit_two's_complement.md)
- [二，复习位运算](./bit_operations_review.md)
- [三，LuaJIT 中的 bit 操作和 Lua BitOp ApiPI 简介](./bit_LuaJIT_BitOp_Api.md)
- [四，位运算算法实例](./bit_bitwise_operation_example.md)
- [五，Lua BitOp 的安装](./bit_bitop_installation.md)
- 六，参考资料
