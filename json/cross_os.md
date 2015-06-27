# 跨平台的库选择

大家看过上面三个json的例子就发现，都是围绕cjson库的。原因也比较简单，就是cjson是默认绑定到openresty上的。所以在linux环境下我们也默认的使用了他。在360天擎项目中，linux用户只是很少量的一部分。大部分用户更多的是windows操作系统，但cjson目前还没有windows版本。所以对于windows用户，我们只能选择dkjson（编解码效率没有cjson快，优势是纯lua，完美跨任何平台）。

并且我们的代码肯定不会因为win、linux的并存而写两套程序。那么我们就必须要把json处理部分封装一下，隐藏系统差异造成的差异化处理。

```lua
local _M = { _VERSION = '1.0' }
-- require("ffi").os 获取系统类型
local json = require(require("ffi").os == "Windows" and "dkjson" or "cjson")

function _M.json_decode( str )
    return json.decode(str)
end
function _M.json_encode( data )
    return json.encode(data)
end

return _M

```

在我们的应用中，对于操作系统版本差异、操作系统位数差异、同时支持不通数据库使用等，几乎都是使用这个方法完成的，十分值得推荐。
