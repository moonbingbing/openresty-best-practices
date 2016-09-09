# 热装载代码

在Openresty中，提及热加载代码，估计大家的第一反应是 [lua_code_cache](https://github.com/openresty/lua-nginx-module#lua_code_cache) 这个开关。在开发阶段我们把它配置成lua_code_cache off，是很方便、有必要的，修改完代码，肯定都希望自动加载最新的代码（否则我们就要噩梦般的reload服务，然后再测试脚本）。

禁用 Lua 代码缓存（即配置 lua_code_cache off）只是为了开发便利，一般不应以高于 1 并发来访问，否则可能会有race condition等等问题。同时因为它会有带来严重的性能衰退，所以不应在生产上使用此种模式。生产上应当总是启用Lua代码缓存，即配置lua_code_cache on。

那么我们是否可以在生产环境中完成热加载呢？

* 代码有变动时，自动加载最新Lua代码，但是nginx本身，不做任何reload
* 自动加载后的代码，享用lua_code_cache on带来的高效特性


这里有多种玩法（[引自Openresty讨论组](https://groups.google.com/forum/#!searchin/openresty/package.loaded/openresty/-MZ9AzXaaG8/TeXTyLCuoYUJ)）： 

* 使用 HUP reload 或者 binary upgrade 方式动态加载 nginx 配置或重启 nginx。这不会导致中间有请求被 drop 掉。 
* 当 content_by_lua_file 里使用 nginx 变量时，是可以动态加载新的 Lua 脚本的，不过要记得对 nginx 变量的值进行基本的合法性验证，以免被注入攻击。 

```
    location ~ '^/lua/(\w+(?:\/\w+)*)$' { 
        content_by_lua_file $1; 
    } 
```

* 自己从外部数据源（包括文件系统）加载 Lua 源码或字节码，然后使用 loadstring() “eval”进 Lua VM. 可以通过 package.loaded 自己来做缓存，毕竟频繁地加载源码和调用 loadstring()，以及频繁地 JIT 编译还是很昂贵的（类似 lua_code_cache off 的情形）。 比如CloudFlare公司采用的方法是从 modsecurity 规则编译出来的 Lua 代码就是通过 KyotoTycoon 动态分发到全球网络中的每一个 nginx 服务器的。无需 reload 或者 binary upgrade. 

## 自定义module的动态装载

对于已经装载的module，我们可以通过package.loaded.* = nil的方式卸载（注意：如果对应模块是通过本地文件 require 加载的，该方式失效，ngx_lua_module 里面对以文件加载模块的方式做了特殊处理）。

不过，值得提醒的是，因为 require 这个内建函数在标准 Lua 5.1 解释器和 LuaJIT 2 中都被实现为 C 函数，所以你在自己的 loader 里可能并不能调用 ngx_lua 那些涉及非阻塞 IO 的 Lua 函数。因为这些 Lua 函数需要 yield 当前的 Lua 协程，而 yield 是无法跨越 Lua 调用栈上的 C 函数帧的。细节见 

https://github.com/openresty/lua-nginx-module#lua-coroutine-yieldingresuming 

所以直接操纵 package.loaded 是最简单和最有效的做法。CloudFlare 的 Lua WAF 系统中就是这么做的。 

不过，值得提醒的是，从 package.loaded 解注册的 Lua 模块会被 GC 掉。而那些使用下列某一个或某几个特性的 Lua 
模块是不能被安全的解注册的： 

* 使用 FFI 加载了外部动态库
* 使用 FFI 定义了新的 C 类型
* 使用 FFI 定义了新的 C 函数原型

这个限制对于所有的 Lua 上下文都是适用的。 

这样的 Lua 模块应避免手动从 package.loaded 卸载。当然，如果你永不手工卸载这样的模块，只是动态加载的话，倒也无所谓了。但在我们的 Lua WAF 的场景，已动态加载的一些 Lua 模块还需要被热替换掉（但不重新创建 Lua VM）。 


## 自定义Lua script的动态装载实现 

> [引自Openresty讨论组](https://groups.google.com/forum/#!searchin/openresty/%E5%8A%A8%E6%80%81%E5%8A%A0%E8%BD%BDlua%E8%84%9A%E6%9C%AC/openresty/-MZ9AzXaaG8/TeXTyLCuoYUJ)

一方面使用自定义的环境表 [1]，以白名单的形式提供用户脚本能访问的 API；另一方面，（只）为用户脚本禁用 JIT 编译，同时使用 Lua 的 debug hooks [2] 作脚本 CPU 超时保护（debug hooks 对于 JIT 编译的代码是不会执行的，主要是出于性能方面的考虑）。 

下面这个小例子演示了这种玩法： 

```lua
local user_script = [[ 
    local a = 0 
    local rand = math.random 
    for i = 1, 200 do 
        a = a + rand(i) 
    end 
    ngx.say("hi") 
]] 

local function handle_timeout(typ) 
    return error("user script too hot") 
end 

local function handle_error(err) 
    return string.format("%s: %s", err or "", debug.traceback()) 
end 

-- disable JIT in the user script to ensure debug hooks always work: 
user_script = [[jit.off(true, true) ]] .. user_script 

local f, err = loadstring(user_script, "=user script") 
if not f then 
    ngx.say("ERROR: failed to load user script: ", err) 
    return 
end 

-- only enable math.*, and ngx.say in our sandbox: 
local env = { 
    math = math, 
    ngx = { say = ngx.say }, 
    jit = { off = jit.off }, 
} 
setfenv(f, env) 

local instruction_limit = 1000 
debug.sethook(handle_timeout, "", instruction_limit) 
local ok, err = xpcall(f, handle_error) 
if not ok then 
    ngx.say("failed to run user script: ", err) 
end 
debug.sethook()  -- turn off the hooks 
```

这个例子中我们只允许用户脚本调用 math 模块的所有函数、ngx.say() 以及 jit.off(). 其中 jit.off()是必需引用的，为的是在用户脚本内部禁用 JIT 编译，否则我们注册的 debug hooks 可能不会被调用。 

另外，这个例子中我们设置了脚本最多只能执行 1000 条 VM 指令。你可以根据你自己的场景进行调整。 

这里很重要的是，不能向用户脚本暴露 pcall 和 xpcall 这两个 Lua 指令，否则恶意用户会利用它故意拦截掉我们在 debug hook 里为中断脚本执行而抛出的 Lua 异常。 

另外，require()、loadstring()、loadfile()、dofile()、io.*、os.* 等等 API 是一定不能暴露给不被信任的 Lua 脚本的。 
