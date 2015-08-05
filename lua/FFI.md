#FFI

####调用C函数

`ffi.C`使用默认的C标准库命名空间，这使得我们可以简单地调用C标准库中的函数。同时，FFI库还会自动检
测到`sdfcall`函数，所以我们也不用去声明那些函数。当Lua中基本数值类型与被调用的C函数参数不一致时，
FFI库会自动完成数值类型的转换。

>我们来看一个调用FFI库的示例

```Lua
local ffi = require("ffi")
ffi.cdef[[
unsigned long compressBound(unsigned long sourceLen);
int compress2(uint8_t *dest, unsigned long *destLen,
	      const uint8_t *source, unsigned long sourceLen, int level);
int uncompress(uint8_t *dest, unsigned long *destLen,
	       const uint8_t *source, unsigned long sourceLen);
]]
local zlib = ffi.load(ffi.os == "Windows" and "zlib1" or "z")

local function compress(txt)
  local n = zlib.compressBound(#txt)
  local buf = ffi.new("uint8_t[?]", n)
  local buflen = ffi.new("unsigned long[1]", n)
  local res = zlib.compress2(buf, buflen, txt, #txt, 9)
  assert(res == 0)
  return ffi.string(buf, buflen[0])
end

local function uncompress(comp, n)
  local buf = ffi.new("uint8_t[?]", n)
  local buflen = ffi.new("unsigned long[1]", n)
  local res = zlib.uncompress(buf, buflen, comp, #comp)
  assert(res == 0)
  return ffi.string(buf, buflen[0])
end

-- Simple test code.
local txt = string.rep("abcd", 1000)
print("Uncompressed size: ", #txt)
local c = compress(txt)
print("Compressed size: ", #c)
local txt2 = uncompress(c, #txt)
assert(txt2 == txt)
```

解释一下这段代码。  
我们首先使用`ffi.cdef`声明了一些被zlib库提供的C函数。
然后加载zlib共享库，在Windows系统上，则需要我们手动从网上下载zlib1.dll文件，而在POSIX系统上
libz库一般都会被预安装。因为`ffi.load`函数会自动填补前缀和后缀，所以我们简单地使用z这个字母就
可以加载了。我们检查`ffi.os`，以确保我们传递给`ffi.load`函数正确的名字。


一开始，压缩缓冲区的最大值被传递给`compressBound`函数，下一行代码分配了一个要压缩字符串长度的
字节缓冲区。``[?]``意味着他是一个变长数组。它的实际长度由`ffi.new`函数的第二个参数指定。

我们仔细审视一下`compress2`函数的声明就会发现，目标长度是用指针传递的！这是因为我们要传递进去缓冲
区的最大值，并且得到缓冲区实际被使用的大小。

在C语言中，我们可以传递变量地址。但因为在Lua中并没有地址相关的操作符，所以我们使用只有一个元素的
数组来代替。我们先用最大缓冲区大小初始化这唯一一个元素，接下来就是很直观地调用`zlib.compress2`函
数了。使用`ffi.string`函数得到一个存储着压缩数据的Lua字符串，这个函数需要一个指向数据起始区
的指针和实际长度。实际长度将会在`buflen`这个数组中返回。因为压缩数据并不包括原始字符串的长度，所
以我们要显式地传递进去。

####使用C数据结构

userdata 类型用来将任意 C 数据保存在 Lua 变量中。这个类型相当于一块原生的内存，除了赋值和相同性
判断，Lua 没有为之预定义任何操作。 然而，通过使用 metatable （元表） ，程序员可以为 userdata
自定义一组操作。 userdata 不能在 Lua 中创建出来，也不能在 Lua 中修改。这样的操作只能通过 C API。
这一点保证了宿主程序完全掌管其中的数据。

我们将C语言类型与 metamethod （元方法）关联起来，这个操作只用做一次。`ffi.metatype`会返回一个该类型的构造函数。
原始C类型也可以被用来创建数组，元方法会被自动地应用到每个元素。

尤其需要指出的是，metatable与C类型的关联是永久的，而且不允许被修改，\_\_index元方法也是。

>下面是一个使用C数据结构的实例

```Lua
local ffi = require("ffi")
ffi.cdef[[
typedef struct { double x, y; } point_t;
]]

local point
local mt = {
  __add = function(a, b) return point(a.x+b.x, a.y+b.y) end,
  __len = function(a) return math.sqrt(a.x*a.x + a.y*a.y) end,
  __index = {
    area = function(a) return a.x*a.x + a.y*a.y end,
  },
}
point = ffi.metatype("point_t", mt)

local a = point(3, 4)
print(a.x, a.y)  --> 3  4
print(#a)        --> 5
print(a:area())  --> 25
local b = a + point(0.5, 8)
print(#b)        --> 12.5
```


>附表：Lua 与 C语言语法对应关系

| Idiom |	C code | Lua code |
| :--: | :--: | :--: |
| Pointer dereference |  x = *p;  |  x = p[0] |
| int *p;	| *p = y; |  p[0] = y |
| Pointer indexing |   x = p[i];  |	x = p[i] |
| int i, *p;	  | p[i+1] = y; | p[i+1] = y |
| Array indexing | x = a[i];  | 	x = a[i] |
| int i, a[]; | a[i+1] = y; | a[i+1] = y |
| struct/union dereference |  x = s.field;  | 	x = s.field |
| struct foo s; | s.field = y; |  s.field = y |
| struct/union pointer deref. | x = sp->field; | x = s.field |
| struct foo *sp; | sp->field = y; | s.field = y |
| int i, *p; | y = p - i;  | y = p - i |
| Pointer difference |    x = p1 - p2; |  x = p1 - p2 |
| Array element pointer | x = &a[i]; |  x = a+i |
