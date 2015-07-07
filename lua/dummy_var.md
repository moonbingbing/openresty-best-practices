虚变量：

先看一段代码：
[[-- string.find (s,p) 从string 变量s的开头向后匹配 string p，若匹配不成功，返回nil，若匹配成功，返回第一次匹配成功
的起止下标。--]]
print ( string.find("hello", "he")  ) -- 输出 1   2

x = string.find("hello", "he");
print ( x )                       --输出 1

local _,x = string.find("hello", "he") 
print ( x )                       --输出 2

代码倒数第二行，定义了一个用local 修饰的 虚变量（即 下划线）。使用这个虚变量接收string.find()返回来的第一个值，
然后丢掉。这样就很容易得到第二个返回值。

