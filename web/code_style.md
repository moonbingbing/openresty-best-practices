# 代码规范

其实选择 OpenResty 的同学，应该都是对执行性能、开发效率比较在乎的，而对于代码风格、规范等这些 **小事** 不太在意。作为一个从 Linux C/C++ 转过来的研发，采用 OpenResty 后获得了脚本语言的开发速度、 接近 C/C++ 的执行速度，但是在我轻视了代码规范后，一个 BUG 的发生告诉我，没规矩不成方圆。

既然我们玩的是 OpenResty，那么很自然的联想到，OpenResty 自身组件代码风格是怎样的呢？

> lua-resty-string 的 string.lua

```lua
local ffi = require("ffi")
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
local setmetatable = setmetatable
local error = error
local tonumber = tonumber


local _M = { _VERSION = '0.09' }


ffi.cdef[[
typedef unsigned char u_char;

u_char * ngx_hex_dump(u_char *dst, const u_char *src, size_t len);

intptr_t ngx_atoi(const unsigned char *line, size_t n);
]]

local str_type = ffi.typeof("uint8_t[?]")


function _M.to_hex(s)
    local len = #s * 2
    local buf = ffi_new(str_type, len)
    C.ngx_hex_dump(buf, s, #s)
    return ffi_str(buf, len)
end


function _M.atoi(s)
    return tonumber(C.ngx_atoi(s, #s))
end


return _M
```

代码虽短，但我们可以从中获得很多信息：

- 1、没有全局变量，所有的变量均使用 `local` 限制作用域；
- 2、提取公共函数到本地变量，使用本地变量缓存函数指针，加速下次使用；
- 3、函数名称全部小写，使用下划线进行分割；
- 4、两个函数之间距离两个空行。

这里的第 2 条，是有争议的。当你按照这个标准写业务的时候，会有些痛苦。因为我们总是把标准 API 命名成自己的别名，不同开发协作人员，命名结果一定不一样，最后导致同一个标准 API 在不同地方变成不同别名，会给开发造成极大困惑。

因为这个可预期的麻烦，我们没有遵循第 2 条标准，尤其是具体业务上游模块。但对于被调用的次数比较多的基础模块，可以使用这个方式进行调优。其实这里最好最完美的方法，应该是 Lua 编译成 Luac 的时候，直接做 Lua Byte Code 的调优，直接隐藏这个简单的处理逻辑。

有关更多代码细节，其实我觉得主要还是多看写的漂亮的代码，一旦看他们看的顺眼、形成习惯，那么就很自然能写出风格一致的代码。规定的条条框框死记硬背总是很不爽的，所以多去看看春哥开源的 `resty` 系列代码，顺手品一品不同组件的玩法也会别有一番心得。

说说我上面提及的因为风格问题造出来的坑吧。

```lua
local
function test()
    -- do something
end

function test2()
    -- do something
end
```

这是我当时不记得从哪里看到的一个 Lua 风格，在被引入项目初期，自我感觉良好。可突然从某个时间点开始，新合并进来的代码无法正常工作。查看最后的代码发现原来是 `test()` 函数作废，被删掉，手抖没有把上面的 `local` 也删掉。这个隐形的 `local` 就作用到了下一个函数，最终导致异常。
