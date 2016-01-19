# String library

Lua字符串库包含很多强大的字符操作函数。字符串库中的所有函数都导出在模块string中。在Lua5.1中，它还将这些函数导出作为string类型的方法。这样假设要返回一个字符串转的大写形式，可以写成ans = string.upper(s),也能写成 ans = s:upper()。为了避免与之前版本不兼容，此处使用前者。

Lua 字符串总是由字节构成的。Lua 核心并不尝试理解具体的字符集编码（比如 GBK 和 UTF-8 这样的多字节字符编码）。

需要特别注意的一点是，Lua 字符串内部用来标识各个组成字节的下标是从 1 开始的，这不同于像 C 和 Perl 这样的编程语言。这样子数字符串位置的时候再也不用调整，对于非专业的开发者来说可能也是一个好事情，string.sub(str, 3, 7)直接表示从第三个字符开始到第七个字符（含）为止的子串。

#### string.byte(s [, i [, j ]])

返回字符s[i ]、s[i + 1]、s[i + 2]、······、s[j ]所对应的ASCII码。i的默认值为 1，即第一个字节；j的默认值为i。

>示例代码

```lua
print(string.byte("abc", 1, 3))
print(string.byte("abc", 3)) --缺少第三个参数，第三个参数默认与第二个相同，此时为 3
print(string.byte("abc")) --缺少第二个和第三个参数，此时这两个参数都默认为 1

-->output
97	98	99
99
97
```

由于 `string.byte` 只返回整数，而并不像 `string.sub` 等函数那样（尝试）创建新的 Lua 字符串，
因此使用 `string.byte` 来进行字符串相关的扫描和分析是最为高效的，尤其是在被 LuaJIT 2 所 JIT 编译之后。

#### string.char (...)

接收0个或更多的整数（整数范围 ：0~255）；返回这些整数所对应的ASCII码字符组成的字符串。当参数为空时，默认是一个 0。

>示例代码

```lua
print(string.char(96, 97, 98))
print(string.char()) --参数为空，默认是一个0，你可以用string.byte(string.char())测试一下
print(string.char(65, 66))

-->output
`ab

AB
```

此函数特别适合从具体的字节构造出二进制字符串。这经常比使用 `table.concat` 函数和 `..` 连接运算符更加高效。

#### string.upper(s)
接收一个字符串s，返回一个把所有小写字母变成大写字母的字符串。

>示例代码

```lua
print(string.upper("Hello Lua"))  -->output  HELLO LUA
```

#### string.lower(s)
接收一个字符串s，返回一个把所有大写字母变成小写字母的字符串。

>示例代码

```lua
print(string.lower("Hello Lua"))  -->output   hello lua
```

#### string.len(s)
接收一个字符串，返回它的长度。

>示例代码

```lua
print(string.len("hello lua")) -->output  9
```

使用此函数是不推荐的。应当总是使用 `#` 运算符来获取 Lua 字符串的长度。

由于 Lua 字符串的长度是专门存放的，并不需要像 C 字符串那样即时计算，因此获取字符串长度的操作总是 `O(1)` 的时间复杂度。

#### string.find(s, p [, init [, plain]])

在s字符串中第一次匹配 p 字符串。若匹配成功，则返回 p 模式字符串在 s 字符串中出现的开始位置和结束位置；若匹配失败，则返回 nil。
第三个参数 init 默认为 1，并且可以为负整数，当 init 为负数时，表示从s字符串的 string.len(s) + init 索引处开始向后匹配字符串 p 。
第四个参数默认为 false，当其为 true 时，只会把p看成一个字符串对待。

>示例代码

```lua
local find = string.find
print(find("abc cba", "ab"))
print(find("abc cba", "ab", 2))
--从索引为2的位置开始匹配字符串：ab
print(find("abc cba", "ba", -1))   --从索引为7的位置开始匹配字符串：ba
print(find("abc cba", "ba", -3))   --从索引为6的位置开始匹配字符串：ba
print(find("abc cba", "(%a+)", 1)) --从索引为1处匹配最长连续且只含字母的字符串
print(find("abc cba", "(%a+)", 1, true)) --从索引为1的位置开始匹配字符串：(%a+)

-->output
1	2
nil
nil
6	7
1	3	abc
nil
```

对于 LuaJIT 这里有个性能优化点，对于 string.find 方法，当只有字符串查找匹配时，是可以被 JIT 编译器优化的，有关 JIT 可以编译优化清单，大家可以参考 [http://wiki.luajit.org/NYI](http://wiki.luajit.org/NYI) 。对于普通的字符串匹配，可以使用 JIT 技术优化，性能提升是非常明显的，通常是 100 倍量级。 这里有个的例子，大家可以参考 [https://groups.google.com/forum/m/#!topic/openresty-en/rwS88FGRsUI](https://groups.google.com/forum/m/#!topic/openresty-en/rwS88FGRsUI)。

#### string.format(formatstring, ...)

按照格式化参数formatstring，返回后面...内容的格式化版本。编写格式化字符串的规则与标准c语言中printf函数的规则基本相同：它由常规文本和指示组成，这些指示控制了每个参数应放到格式化结果的什么位置，及如何放入它们。一个指示由字符'%'加上一个字母组成，这些字母指定了如何格式化参数，例如'd'用于十进制数、'x'用于十六进制数、'o'用于八进制数、'f'用于浮点数、's'用于字符串等。在字符'%'和字母之间可以再指定一些其他选项，用于控制格式的细节。

>示例代码

```lua
print(string.format("%.4f", 3.1415926))   --保留4位小数
print(string.format("%d %x %o", 31, 31, 31))--十进制数31转换成不同进制
d = 29; m = 7; y = 2015                  --一行包含几个语句，用；分开
print(string.format("%s %02d/%02d/%d", "today is:", d, m, y))

-->output
3.1416
31 1f 37
today is: 29/07/2015
```

#### string.match(s, p [, init])

在字符串s中匹配（模式）字符串 p，若匹配成功，则返回目标字符串中与模式匹配的子串；否则返回 nil。第三个参数 init 默认为 1，并且可以为负整数，当 init 为负数时，表示从 s 字符串的 string.len(s) + init 索引处开始向后匹配字符串 p。

>示例代码

```lua
print(string.match("hello lua", "lua"))
print(string.match("lua lua", "lua", 2))  --匹配后面那个lua
print(string.match("lua lua", "hello"))
print(string.match("today is 27/7/2015", "%d+/%d+/%d+"))

-->output
lua
lua
nil
27/7/2015
```

`string.match` 目前并不能被 JIT 编译，应尽量使用 ngx_lua 模块提供的 `ngx.re.match` 等接口。

#### string.gmatch(s, p)
返回一个迭代器函数，通过这个迭代器函数可以遍历到在字符串s中出现模式串p的所有地方。

>示例代码

```lua
s = "hello world from Lua"
for w in string.gmatch(s, "%a+") do  --匹配最长连续且只含字母的字符串
    print(w)
end

-->output
hello
world
from
Lua


t = {}
s = "from=world, to=Lua"
for k, v in string.gmatch(s, "(%a+)=(%a+)") do  --匹配两个最长连续且只含字母的
    t[k] = v                                    --字符串，它们之间用等号连接
end
for k, v in pairs(t) do
print (k,v)
end

-->output
to      Lua
from    world
```

此函数目前并不能被 LuaJIT 所 JIT 编译，而只能被解释执行。

#### string.rep(s, n)
返回字符串s的n次拷贝。

>示例代码

```lua
print(string.rep("abc", 3)) --拷贝3次"abc"  

-->output  abcabcabc
```

#### string.sub(s, i [, j])
返回字符串s中，索引i到索引j之间的子字符串。当j缺省时，默认为-1，也就是字符串s的最后位置。 i可以为负数。当索引i在字符串s的位置在索引j的后面时，将返回一个空字符串。

>示例代码

```lua
print(string.sub("Hello Lua", 4, 7))
print(string.sub("Hello Lua", 2))
print(string.sub("Hello Lua", 2, 1)) --看到返回什么了吗
print(string.sub("Hello Lua", -3, -1))

-->output
lo L
ello Lua

Lua
```

如果你只是想对字符串中的单个字节进行检查，使用 `string.char` 函数通常会更为高效。

#### string.gsub(s, p, r [, n])

将目标字符串s中所有的子串p替换成字符串r。可选参数n，表示限制替换次数。返回值有两个，第一个是被替换后的字符串，第二个是替换了多少次。

>示例代码

```lua
print(string.gsub("Lua Lua Lua", "Lua", "hello"))
print(string.gsub("Lua Lua Lua", "Lua", "hello", 2)) --指明第四个参数

-->output
hello hello hello   3
hello hello Lua     2
```

此函数不能为 LuaJIT 所 JIT 编译，而只能被解释执行。一般我们推荐使用 ngx_lua 模块提供的 `ngx.re.gsub` 函数。

#### string.reverse (s)

接收一个字符串s，返回这个字符串的反转。

>示例代码

```lua
print(string.reverse("Hello Lua"))  -->output  auL olleH
```

