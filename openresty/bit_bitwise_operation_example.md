# 四，位运算算法实例

- [一，复习二进制补码](./bit_two's_complement.md)
- [二，复习位运算](./bit_operations_review.md)
- [三，LuaJIT 和 Lua BitOp Api](./bit_LuaJIT_BitOp_Api.md)
- [四，位运算算法实例](./bit_bitwise_operation_example.md)
- [五，Lua BitOp 的安装](./bit_bitop_installation.md)

## 示例 1： LeetCode 的 Missing Number：
**(1) 题目描述：**

> 给定一个从 0 到 n 没有重复数字组成的数组，其中有一个数字漏掉了，请找出该数字。
要求：算法具有线性的时间复杂度，并且只占用常数的额外空间复杂度。

**(2) 题目分析**：

- 思路一：对数据进行排序，然后依次扫描，便能找出漏掉的数字。
    - 缺点：基于比较的排序算法的时间复杂度至少是 O(nlogn)，不满足题目要求。

- 思路二：先对 0 到 n 求和，记为 sum1，再对给定的数组求和，记为 sum2，二者之差即为漏掉的数字。

- 思路三：比加法更高效的运算是「按位异或 (XOR) 运算」。我们这里采用位运算来求解。

> Tips: **按位异或** 运算的一个重要性质：
> 做运算的两个数相同时，结果为 0，不相同时结果为1。这个性质可以扩展到多个数做按位异或运算。

**(3) 复杂度：**
- 时间复杂度：O(n)，空间复杂度：O(1)。

**(4) 实例代码：**
> missingNumber.lua 文件：
```lua
local bit = require("bit")

local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

function missingNumber(nums)
    -- 方法一：
    -- 1，先拿 x 与 0~n 的数字做 按位异或 运算
    local x = 0
    for i = 0, #nums do
        x = bit.bxor(x, i)
    end

    -- 2，再拿上一步的 x 与给定数组的元素一一做 按位异或 运算
    for k,v in ipairs(nums) do
        x = bit.bxor(x, v)
    end

    -- 方法二：
    -- 由于 bxor() 支持多个参数，可以将以上两步合并成下面的一个循环
    -- for k, v in ipairs(nums) do
    --     x = bit.bxor(x, k, v)
    -- end

    print("The missing number is: " .. x)
end

-- 实际调用
local nums = {0, 1, 2, 3, 5}
missingNumber(nums)
```

## 示例 2：LeetCode 的 Power of Two：
**(1) 题目描述：**

> 给定一个整数，判断它是否为 2 的幂。

**(2) 题目分析**：
2 的整数幂的有一个**重要特点：** 2 的整数幂对应的二进制形式中只有一个位是 1。
所以我们要做的就是判断输入的这个数的二进制形式是否符合这一条件。

> 注意：当输入的数为负数时，一定不是 2 的幂。

**(3) 复杂度：**
- 时间复杂度：O(n)，空间复杂度：O(1)。

> isPowerOfTwo.lua 文件：
```lua
function isPowerOfTwo(num)
    -- 首先判断 num 是否为负数
    if num < 0 then
        print('这个数是负数，不是 2 的幂。')
        return false
    end

    local hasOne = false
    while num > 0 do
        -- 判断这个数和 1 做 与运算的结果是否不为 0
        if band(num, 1) ~= 0 then  -- 注意这里的条件写法
            if hasOne then         -- 判断 hasOne 是否为 ture
                return false       -- 如果是 ture，则说明该数字的二进制形式里 1 的数目多于 1 个
            else
                hasOne = true
            end
        end
        print('移位前： ' .. num)
        num = rshift(num, 1)        -- 将这个数字右移一位
        print('移位后： ' .. num)
        print(hasOne)
    end
    return hasOne;
end

local num = 8
local result = isPowerOfTwo(num)

-- 输出结果：
if result == true then
    print('这个数 '.. num ..'，是 2 的幂。')
else
    print('这个数'.. num ..'，不是 2 的幂。')
end
```

## 示例 3：LeetCode 的 Number of 1 Bits：
**(1) 题目描述：**

> 给定一个整数，求出它的二进制形式所包含 1 的个数。
>
> 例如，32 位整数 11 的二进制形式为 00000000000000000000000000001011，那么函数返回 3。

**(2) 题目分析**：
设输入的数为 num，把 num 与 1 做二进制的 **按位与** (AND) 运算，即可判断它的最低位是否为 1。

**(3) 解法一：**
如果最低位为 1 的话，把计算变量加一，然后把 num 向右移动一位，重复上述操作。
当 num 变为 0 时，终止算法，输出结果。

**(4) 复杂度：**
- 时间复杂度：O(log2v)，log2v 为二进制数的位数，空间复杂度：O(1)。

> numberOf1Bits-1.lua 文件：
```lua
function numberOf1Bits-1(num)
    local count = 0
    while num > 0 do
        count = count + band(num, 1)
        num = rshift(num, 1)
    end
    return count
end

-- 测试
local num = 7
local result = numberOf1Bits-1(num)
-- 输出结果
print(result)   --> 3
```

**(5) 解法二：**
n & (n - 1) 可以消除最后一个 1，所以用一个循环不停地消除 1 同时计数，直到 n 变成 0 为止。

**(6) 复杂度：**
- 时间复杂度：O(m)，m 为数字 num 的二进制表示形式中 1 的个数，空间复杂度：O(1)。

> numberOf1Bits-2.lua 文件：
```lua
function numberOf1Bits-2(num)
    local count = 0
    while num ~= 0 do
        num = band(num, num - 1)
        count = count + 1
    end
    return count
end

-- 测试
local num = 7
local result = numberOf1Bits-2(num)
-- 输出结果
print(result)   --> 3
```

## 示例 4：Eratosthenes 筛法（素数筛）的一个实现

该算法可以计算出 [1, N] 区间内素数的个数。

```lua
local bit = require("bit")
local band, bxor = bit.band, bit.bxor
local rshift, rol = bit.rshift, bit.rol

local m = tonumber(arg and arg[1]) or 100000

if m < 2 then
    m = 2
end

local count = 0
local p = {}

for i = 0, (m+31)/32 do
    p[i] = -1
end

for i = 2, m do
  if band(rshift(p[rshift(i, 5)], i), 1) ~= 0 then
    count = count + 1
    for j = i+i, m, i do
      local jx = rshift(j, 5)
      p[jx] = band(p[jx], rol(-2, j))
    end
  end
end

io.write(string.format("从 1 到 %d，共有 %d 个素数，\n", m, count))
```

Lua BitOp 相当快。在安装了标准 Lua 的 3GHz CPU 上，该程序可以在不到 90 毫秒的时间内运行完毕，但是执行了超过 100 万次的位函数调用。如果您想要更高的速度，请查看 [LuaJIT](http://luajit.org/)。

## 参考资料
- 1，《枕边算法书》
- 2，[LeetCode](https://leetcode-cn.com/)
- 3，[LuaBitOp](http://bitop.luajit.org)
- 4，[二进制补码计算原理详解](https://blog.csdn.net/zhuozuozhi/article/details/80896838)
- 5，[原码, 反码, 补码 详解](https://www.cnblogs.com/zhangziqiu/archive/2011/03/30/ComputerCode.html)
- 6，[原码、反码、补码 详解！不懂的请看过来！](https://zhuanlan.zhihu.com/p/91967268)
- 7，[彻解“补码”](https://zhuanlan.zhihu.com/p/80618244)
