# module 是邪恶的

Lua 是所有脚本语言中最快、最简洁的，我们爱她的快、她的简洁，但是我们也不得不忍受因为这些快、简洁最后带来的一些弊端，我们来挨个数数 module 有多少“邪恶”的吧。

由于 `lua_code_cache off` 情况下，缓存的代码会伴随请求完结而释放。module 的最大好处缓存这时候是无法发挥的，所以本章的内容都是基于 `lua_code_cache on` 的情况下。

先看看下面代码：

```lua
local ngx_socket_tcp = ngx.socket.tcp           -- ①

local _M = { _VERSION = '0.06' }                -- ②
local mt = { __index = _M }                     -- ③

function _M.new(self)
    local sock, err = ngx_socket_tcp()          -- ④
    if not sock then
        return nil, err
    end
    return setmetatable({ sock = sock }, mt)    -- ⑤
end

function _M.set_timeout(self, timeout)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:settimeout(timeout)
end

-- ... 其他功能代码，这里简略

return _M
```

① 对于比较底层的模块，内部使用到的非本地函数，都需要 local 本地化，这样做的好处：

* 避免命名冲突：防止外部是 `require(...)` 的方法调用造成全局变量污染
* 访问局部变量的速度比全局变量更快、更快、更快（重要事情说三遍）

② 每个基础模块最好有自己 `_VERSION` 标识，方便后期利用 `_VERSION` 完成热代码部署等高级特性，也便于使用者对版本有整体意识。

③ 其实 `_M` 和 `mt` 对于不同的请求实例（require 方法得到的对象）是相同的，因为 module 会被缓存到全局环境中。所以在这个位置千万不要放单请求内个性信息，例如 ngx.ctx 等变量。

④ 这里需要实现的是给每个实例绑定不同的 tcp 对象，后面 setmetatable 确保了每个实例拥有自己的 socket 对象，所以必须放在 new 函数中。如果放在 ③ 的下面，那么这时候所有的不同实例内部将绑定了同一个 socket 对象。

```lua
?local mt = { __index = _M }                     -- ③
?local sock = ngx_socket_tcp()                   -- ④ 错误的
?
?function _M.new(self)
?    return setmetatable({ sock = sock }, mt)    -- ⑤
?end
```

⑤ Lua 的 module 有两种类型：支持面向对象痕迹可以保留私有属性；静态方法提供者，没有任何私有属性。真正起到区别作用的就是 setmetatable 函数，是否有自己的个性元表，最终导致两种不同的形态。


笔者写这章的时候，想起一个场景，我觉得两者之间重叠度很大。`不幸的婚姻有千万种，可幸福的婚姻只有一种`。糟糕的 module 有千万个错误，可好的 module 都一个样。我们真没必要尝试了解所有错误格式的不好，但是正确的格式就摆在那里，不懂就照搬，搬多了就有感觉了。起点的不同，可以让我们从一开始有正确的认知形态，少走弯路，多一些时间学习有价值的东西。


也许你要问，哪里有正确的 module 所有格式？先从 OpenResty 默认绑定的各种 lua-resty-* 代码开始熟悉吧，她就是我说的正确格式（注意：这里我用了一个女字旁的 她，看的出来我有多爱她了）。
