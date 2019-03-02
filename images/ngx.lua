--[=[
openresty函数提示专用库,不实现功能,仅仅用来做方法提示使用
by:xuzz 20181112
]=]

---@class err @错误信息定义,可为string或者nil
local err = ""

---在5.2中，setfenv遭到了废弃，因为引入了_ENV。 通过在函数定义前覆盖_ENV变量即可为函数定义设置一个全新的环境，比如：
---a = 3
---function echo()
--- local _ENV={print=print, a = 2}
--- function _echo() _ENV.print(a) end
--- return _echo;
---end
---print(a) -> 3
---local newEcho = echo()
---print(newEcho) -> function: 0x7fd1b94065c0
---newEcho() -> 2
_ENV = {}

---设置一个函数的环境
---（1）当第一个参数为一个函数时，表示设置该函数的环境
---（2）当第一个参数为一个数字时，为1代表当前函数，2代表调用自己的函数，3代表调用自己的函数的函数，以此类推
function setfenv(f,table)
end


---功能：与load类似，但装载的内容是一个字串
--如：assert(loadstring(s))()
---@param string string @可选参数
---@return fun() @返回string编译后的方法
function loadstring (string,chunkname)
end

---功能：返回指定表的索引的值,i为起始索引，j为结束索引
---注：本函数只能用于以数字索引访问的表,否则只会返回nil 如：t={"1","cash"}
---@param list table[]
function unpack (list,i,j)
end

---循环table,table不必是数字索引
---table.foreach(table, function(i, v) end)
---
---@param tb1 table @需循环的数据
---@param func fun(k:any,v:any):void @处理每个键值的函数
function table.foreach(tb1,func)
end

---循环table,table必须是数字索引
---table.foreach(table, function(i, v) end)
---
---@param tb1 table @需循环的数据
---@param func fun(k:any,v:any):void @处理每个键值的函数
function table.foreachi(tb1,func)
end

---给 lua table 预分配空间。否则 table
---会在插入新元素时自增长，而自增长是高代价操作（ 因为需要重新分配空间、重新 hash，以及拷贝数据）
---narr,nrec两个参数分别代表table里是array还是hash的
---table.new(10, 0) 或者 table.new(0, 10) 这样的，后者是 hash 性质的 table
---@param narr number @预分配多少数组型空间
---@param nrec number @预分配多少hash型空间
function table.new(narr,nrec)
end

---清理一个lua table
---@param tb table @需要清理的table
function table.clear(tb)
end

---@class ngx.pipe.proc @pipe产生的子进程定义
local proc = {}

---获得子进程id
---pid = proc:pid()
function proc:pid()
end
---设置超时时间
---默认10000毫秒
function proc:set_timeouts(write_timeout,stdout_read_timeout,stderr_read_timeout,wait_timeout)
end

---@class reason @pipe退出原因定义,一个字符串,可选值 exit/signal
local reason = "exit" or "signal"
---等待直到当前子进程退出。
---ok, reason, status = proc:wait()
---ok,如果进程退出码为0,则为true
---reason可能值有:
--- exit进程主动退出而结束,status为退出码
--- signal接收了信号而退出 ,status为信号码
---@return boolean,reason,number
function proc:wait()
end

---结束子进程
---ok, err = proc:shutdown(direction)
---'direction'参数应该是以下三个值之一：'stdin`、'stdout`和'stderr`。
function proc:shutdown(direction)
end

---写入内容到输入流
---nbytes, err = proc:write(data)
---@param data string|table @写入的内容,可以是字符串也可以是数组
---@return number,string @写入成功的字节数,第二个为错误信息
function proc:write(data)
end

---从当前子进程的stderr流中读取所有数据，直到其关闭。
---data, err, partial = proc:stderr_read_all()
---这个方法是一个同步的、非阻塞的操作，就像[写]（写）方法一样。
---此读取操作的超时阈值可以由[set_timeouts]控制。默认超时为10秒。
---如果成功，它将返回接收到的数据。否则，它返回三个值：“nil”，一个描述错误的字符串，以及迄今为止接收到的部分数据（可选）。
---当在[spawn]（spawn）中指定了“merge_stderr”时，调用“stderr_read_all”将返回“nil”，错误字符串“merged to stdout”`。
---一次只允许从子进程的stderr或stdout流读取一个轻线程。如果另一个线程试图从同一个流中读取，此方法将返回“nil”和错误字符串“pipe busy reading”。
---stdout和stderr的流是分开的，因此一次最多可以从子进程读取两个轻线程（每个流一个）。
---同样，当另一个轻线程正在写入子进程stdin流时，轻线程可以从流中读取
---Reading from an exited process's stream will return `nil` and the error string
--`"closed"`.
function proc:stderr_read_all()
end
---读取全部子进程输出流
---data, err, partial = proc:stdout_read_all()
function proc:stdout_read_all()
end

---读取一行错误输出流
---data, err, partial = proc:stderr_read_line()
---该行应以“换行符”（lf）字符（ascii 10）结尾，可选前面加上“回车符”（cr）字符（ascii 13）。CR和LF字符不包括在返回的行数据中。
function proc:stderr_read_line()
end

---读取一行输出流
---data, err, partial = proc:stdout_read_line()
function proc:stdout_read_line()
end

---读取指定数量的错误输出流
---data, err, partial = proc:stderr_read_bytes(len)
---如果数据流被截断（可用数据的字节数少于请求的字节数），则此方法返回3个值：“nil”、错误字符串“closed”和迄今为止接收到的部分数据字符串。
function proc:stderr_read_bytes(len)
end

---读取指定数量的输出流
---data, err, partial = proc:stdout_read_bytes(len)
function proc:stdout_read_bytes(len)
end

---读取错误输出流,读取到指定数量就返回
---data, err = proc:stderr_read_any(max)
---最多接收'max'个字节。
---如果接收到的数据超过了'max'字节，则此方法将返回完全为'max'字节的数据。底层接收缓冲区中的剩余数据可以通过后续的读取操作获取。
function proc:stderr_read_any(max)
end
---读取输出流,读取到指定数量就返回
--data, err = proc:stdout_read_any(max)
function proc:stdout_read_any(max)
end

---@class ngx
ngx = {}

ngx.thread = {}
---语法: co = ngx.thread.spawn(func, arg1, arg2, ...)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---使用 Lua 函数 func 以及其他可选参数 arg1、arg2 等， 产生一个新的用户 "轻线程" 。 返回一个 Lua 线程（或者说是 Lua 协程）对象，这里称之为“轻线程”。
---ngx.thread.spawn 返回后，新创建的“轻线程”将开始异步方式在各个 I/O 事件上执行。
---
---在 rewrite_by_lua、access_by_lua 中的 Lua 代码块是在 ngx_lua 自动创建的“轻线程”样板执行的。这类样板的“轻线程”也被称为“入口线程”。
function ngx.thread.spawn(func,arg1,arg2,...)
end

---语法: ok, res1, res2, ... = ngx.thread.wait(thread1, thread2, ...)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---等待一个或多个子“轻线程”，并等待第一个终止（无论成功或有错误）“轻线程”的返回结果。
---
---参数 thread1、thread2 等都是之前调用 ngx.thread.spawn 返回的 Lua 线程对象。
---
---返回值与 coroutine.resume 是完全一样的，也就是说，第一个返回值是一个布尔值，说明“轻线程”的终止是成功还是异常，随后的返回值是 Lua 函数的返回结果，该 Lua 函数是被用来产生“轻线程”（成功情况下）或错误对象（失败情况下）。
---
---只有直属“父协程”才能等待它的子“轻线程”，否则将会有 Lua 异常抛出。
function ngx.thread.wait(thread1,thread2,...)
end

---语法: ok, err = ngx.thread.kill(thread)
---
---环境: rewrite_by_lua, access_by_lua*, content_by_lua*, ngx.timer.**
---
---杀死一个正在运行的轻线程（通过 ngx.thread.spawn 创建）。成功时返回一个 true ，其他情况则返回一个错误字符描述信息。
---
---根据目前的实现，只有父协程（或“轻线程”）可以终止一个“线程”。同样，正在挂起运行 Nginx 子请求（例如调用 ngx.location.capture）的“轻线程”，是不能被杀死的，这要归咎于 Nginx 内核限制。
function ngx.thread.kill(thread)
end

---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*,
---header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*
---这个 Lua 表可以用来存储基于请求的 Lua 环境数据，其生存周期与当前请求相同 (类似 Nginx 变量)。
---参考下面例子，
--- location /test {
---     rewrite_by_lua_block {
---         ngx.ctx.foo = 76
---     }
---     access_by_lua_block {
---         ngx.ctx.foo = ngx.ctx.foo + 3
---     }
---     content_by_lua_block {
---         ngx.say(ngx.ctx.foo)
---     }
--- }
---访问 GET /test 输出
--- 79
---内部重定向将摧毁原始请求中的 ngx.ctx 数据 (如果有)，新请求将会有一个空白的 ngx.ctx 表。例如，
---
--- location /new {
---     content_by_lua_block {
---         ngx.say(ngx.ctx.foo)
---     }
--- }
---
--- location /orig {
---     content_by_lua_block {
---         ngx.ctx.foo = "hello"
---         ngx.exec("/new")
---     }
--- }
---访问 GET /orig 将输出
---
--- nil
---任意数据值，包括 Lua 闭包与嵌套表，都可以被插入这个“魔法”表，也允许注册自定义元方法。
---也可以将 ngx.ctx 覆盖为一个新 Lua 表，例如，
ngx.ctx = {}

ngx.HTTP_OK = 200
ngx.HTTP_CREATED = 201
ngx.HTTP_SPECIAL_RESPONSE = 300
ngx.HTTP_MOVED_PERMANENTLY = 301
ngx.HTTP_MOVED_TEMPORARILY = 302
ngx.HTTP_SEE_OTHER = 303
ngx.HTTP_NOT_MODIFIED = 304
ngx.HTTP_BAD_REQUEST = 400
ngx.HTTP_UNAUTHORIZED = 401
ngx.HTTP_FORBIDDEN = 403
ngx.HTTP_NOT_FOUND = 404
ngx.HTTP_NOT_ALLOWED = 405
ngx.HTTP_GONE = 410
ngx.HTTP_INTERNAL_SERVER_ERROR = 500
ngx.HTTP_METHOD_NOT_IMPLEMENTED = 501
ngx.HTTP_SERVICE_UNAVAILABLE = 503
ngx.HTTP_GATEWAY_TIMEOUT = 504

---ngx.status
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---读写当前请求的响应状态码。这个方法需要在发送响应头前调用。
--- ngx.status = ngx.HTTP_CREATED
--- status = ngx.status
---在发送响应头之后设置 ngx.status 不会生效，且 nginx 的错误日志中会有下面一条记录：
---attempt to set ngx.status after sending out response headers
--[[
自定义错误内容页面的返回
syntax: ngx.status = ngx.HTTP_GONE
	      ngx.say("This is our own content")
	      ngx.exit(ngx.HTTP_OK)
]]
---@type number @读写当前请求的响应状态码。这个方法需要在发送响应头前调用。
ngx.status = 200

---语法: ngx.header.HEADER = VALUE
---语法: value = ngx.header.HEADER
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---修改、添加、或清除当前请求待发送的 HEADER 响应头信息。
---头名称中的下划线 (_) 将被默认替换为连字符 (-)。可以通过 lua_transform_underscores_in_response_headers 指令关闭这个替换。
---多值头信息可以按以下方法设置：
---
--- ngx.header['Set-Cookie'] = {'a=32; path=/', 'b=4; path=/'}
---在响应头中将输出：
---
--- Set-Cookie: a=32; path=/
--- Set-Cookie: b=4; path=/
---将一个头信息的值设为 nil 将从响应头中移除该输出
---ngx.header["X-My-Header"] = nil;
ngx.header = {}
---设置响应文件类型
ngx.header["Content-Type"] = 'text/html'
ngx.header.content_type = 'text/plain'
---设置一个客户端cookie
ngx.header['Set-Cookie'] = { 'a=32; path=/','b=4; path=/' }

ngx.resp = {}
---语法: headers = ngx.resp.get_headers(max_headers?, raw?)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, balancer_by_lua*
---
---返回一个 Lua 表，包含当前请求的所有响应头信息。
---
--- local h = ngx.resp.get_headers()
--- for k, v in pairs(h) do
---     ...
--- end
---此函数与 ngx.req.get_headers 有相似之处，唯一区别是获取的是响应头信息而不是请求头信息。
---@return table<string,string>
function ngx.resp.get_headers(max_headers,raw)
end

ngx.req = {}
---语法: is_internal = ngx.req.is_internal()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---
---返回一个布尔值，说明当前请求是否是一个“内部请求”，既：一个请求的初始化是在当前 nginx 服务端完成初始化，不是在客户端。
---
---子请求都是内部请求，并且都是内部重定向后的请求。
function ngx.req.is_internal()
end

---语法: secs = ngx.req.start_time()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---
---返回当前请求创建时的时间戳，格式为浮点数，其中小数部分代表毫秒值。
---
---以下用 Lua 代码模拟计算了 $request_time 变量值 (由 ngx_http_log_module 模块生成)
---
--- local request_time = ngx.now() - ngx.req.start_time()
function ngx.req.start_time()
end

---语法: num = ngx.req.http_version()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*
---
---返回一个 Lua 数字代表当前请求的 HTTP 版本号。
---
---当前的可能结果值为 2.0, 1.0, 1.1 和 0.9。无法识别时值时返回 nil。
function ngx.req.http_version()
end

---语法: str = ngx.req.raw_header(no_request_line?)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*
---
---返回 Nginx 服务器接收到的原始 HTTP 协议头。
---
---默认时，请求行和末尾的 CR LF 结束符也被包括在内。例如，
---
--- ngx.print(ngx.req.raw_header())
---输出结果类似：
---
---GET /t HTTP/1.1
---Host: localhost
---Connection: close
---Foo: bar
---可以通过指定可选的 no_request_line 参数为 true 来去除结果中的请求行。例如，
---
--- ngx.print(ngx.req.raw_header(true))
---输出结果类似：
---
---Host: localhost
---Connection: close
---Foo: bar
---@param no_request_line boolean
---@return string
function ngx.req.raw_header(no_request_line)
end

---语法: method_name = ngx.req.get_method()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, balancer_by_lua*
---
---获取当前请求的 HTTP 请求方法名称。结果为类似 "GET" 和 "POST" 的字符串，而不是 HTTP 方法常量 中定义的数值。
---
---如果当前请求为 Nginx 子请求，将返回子请求的 HTTP 请求方法名称。
---
---这个方法在 v0.5.6 版本中首次引入。
---
---更多用法请参考 ngx.req.set_method。
function ngx.req.get_method()
end

ngx.HTTP_GET = 1
ngx.HTTP_HEAD = 2
ngx.HTTP_PUT = 2
ngx.HTTP_POST = 2
ngx.HTTP_DELETE = 2
ngx.HTTP_OPTIONS = 2
ngx.HTTP_MKCOL = 2
ngx.HTTP_COPY = 2
ngx.HTTP_MOVE = 2
ngx.HTTP_PROPFIND = 2
ngx.HTTP_PROPPATCH = 2
ngx.HTTP_LOCK = 2
ngx.HTTP_UNLOCK = 2
ngx.HTTP_PATCH = 2
ngx.HTTP_TRACE = 2
---语法: ngx.req.set_method(method_id)
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*
---用 method_id 参数的值改写当前请求的 HTTP 请求方法。当前仅支持 HTTP 请求方法 中定义的数值常量，例如 ngx.HTTP_POST 和 ngx.HTTP_GET。
---如果当前请求是 Nginx 子请求，子请求的 HTTP 请求方法将被改写。
---这个方法在 v0.5.6 版本中首次引入。
---更多用法请参考 ngx.req.get_method。
function ngx.req.set_method(method_id)
end

---语法: ngx.req.set_uri(uri, jump?)
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*
---用 uri 参数重写当前请求 (已解析过的) URI。该 uri 参数必须是 Lua 字符串，并且长度不能是 0，否则将抛出 Lua 异常。
---可选的布尔值参数 jump 会触发类似 ngx_http_rewrite_module 中 rewrite 指令的 location 重匹配 (或 location 跳转)。
---换句话说，当 jump 参数是 true (默认值 false) 时，此函数将不会返回，它会让 Nginx 在之后的 post-rewrite 执行阶段，
---根据新的 URI 重新搜索 location，并跳转到新 location。
---默认值时，location 跳转不会被触发，只有当前请求的 URI 被改写。当 jump 参数值为 false 或不存在时，此函数将正常返回，但没有返回值。
function ngx.req.set_uri(uri,jump)
end

---语法: ngx.req.set_uri_args(args)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*
---
---用 args 参数重写当前请求的 URI 请求参数。args 参数可以是一个 Lua 字符串，比如
---
--- ngx.req.set_uri_args("a=3&b=hello%20world")
---或一个包含请求参数 key-value 对的 Lua table，例如
---
--- ngx.req.set_uri_args({ a = 3, b = "hello world" })
---在第二种情况下，本方法将根据 URI 转义规则转义参数的 key 和 value。
---
---本方法也支持多值参数：
---
--- ngx.req.set_uri_args({ a = 3, b = {5, 6} })
---此时请求参数字符串为 a=3&b=5&b=6。
function ngx.req.set_uri_args(args)
end

---语法: args = ngx.req.get_uri_args(max_args?)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---
---返回一个 Lua table，包含当前请求的所有 URL 查询参数。
---
--- location = /test {
---     content_by_lua_block {
---         local args = ngx.req.get_uri_args()
---         for key, val in pairs(args) do
---             if type(val) == "table" then
---                 ngx.say(key, ": ", table.concat(val, ", "))
---             else
---                 ngx.say(key, ": ", val)
---             end
---         end
---     }
--- }
---访问 GET /test?foo=bar&bar=baz&bar=blah 将输出：
---
--- foo: bar
--- bar: baz, blah
---@return table<string,string>
function ngx.req.get_uri_args(max_args)
end

---语法: args, err = ngx.req.get_post_args(max_args?)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---
---返回一个 Lua table，包含当前请求的所有 POST 查询参数 (MIME type 是 application/x-www-form-urlencoded)。
---使用前需要调 用 ngx.req.read_body 读取完整请求体，或通过设置 lua_need_request_body 指令为 on 以避免报错。
---请求
--- $ curl ---data 'foo=bar&bar=baz&bar=blah' localhost/test
---将输出：
--- foo: bar
--- bar: baz, blah
---@param max_args number|void
---@return table<string,string>
function ngx.req.get_post_args(max_args)
end

---语法: headers = ngx.req.get_headers(max_headers?, raw?)
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---返回一个 Lua table，包含当前请求的所有请求头信息。
---请注意，ngx.var.HEADER API 使用 nginx 内核 $http_HEADER 变量，在读取单个请求头信息时更加适用。
---@return table<string,string>
function ngx.req.get_headers(max_headers,raw)
end

---语法: ngx.req.set_header(header_name, header_value)
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*
---将当前请求的名为 header_name 的头信息值设置为 header_value，如果此头信息名称已经存在，修改其值。
---默认时，之后通过 ngx.location.capture 和 ngx.location.capture_multi 发起的所有子请求都将继承新的头信息。
---下面的例子中将设置 Content-Type 头信息：
--- ngx.req.set_header("Content-Type", "text/css")
---header_value 可以是一个值数组，例如：
--- ngx.req.set_header("Foo", {"a", "abc"})
---将生成两个新的请求头信息：
--- Foo: a
--- Foo: abc
function ngx.req.set_header(header_name,header_value)
end

---语法: ngx.req.read_body()
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---同步读取客户端请求体，不阻塞 Nginx 事件循环。
---
--- ngx.req.read_body()
--- local args = ngx.req.get_post_args()
---如果已经通过打开 lua_need_request_body 选项或其他模块读取请求体，此函数将不会执行，立即返回。
---
---如果已经通过 ngx.req.discard_body 函数或其他模块明确丢弃请求体，此函数将不会执行，立即返回。
---
---当出错时，例如读取数据时连接出错，此方法将立即抛出 Lua 异常 或 以 500 状态码中断当前请求。
---
---通过此函数读取的请求体，之后可以通过 ngx.req.get_body_data 获得，或者，通过 ngx.req.get_body_file
---得到请求体数据缓存在磁盘上的临时文件名。这取决于：
---
---是否当前读求体已经大于 client_body_buffer_size，
---是否 client_body_in_file_only 选项被打开。
---在当前请求中包含请求体，但不需要时，必须使用 ngx.req.discard_body 明确丢弃请求体，以避免影响 HTTP 1.1 长连接或 HTTP 1.1 流水线 (pipelining)。
function ngx.req.read_body()
end

---语法: data = ngx.req.get_body_data()
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, log_by_lua*
---
---取回内存中的请求体数据。本函数返回 Lua 字符串而不是包含解析过参数的 Lua table。如果想要返回 Lua table，请使用 ngx.req.get_post_args 函数。
---
---当以下情况时，此函数返回 nil，
---
---请求体尚未被读取，
---请求体已经被存入磁盘上的临时文件，
---或请求体大小是 0。
---如果请求体尚未被读取，请先调用 ngx.req.read_body (或打开 lua_need_request_body 选项强制本模块读取请求体，此方法不推荐）。
---
---如果请求体已经被存入临时文件，请使用 ngx.req.get_body_file 函数代替。
---
---如需要强制在内存中保存请求体，请设置 client_body_buffer_size 和 client_max_body_size 为同样大小。
---
---请注意，调用此函数比使用 ngx.var.request_body 或 ngx.var.echo_request_body 更有效率，因为本函数能够节省一次内存分配与数据复制。
---
---这个函数在 v0.3.1rc17 版本中首次引入。
---
---更多用法请参考 ngx.req.get_body_file。
---@return string @请求的body字符串
function ngx.req.get_body_data()
end

---语法: file_name = ngx.req.get_body_file()
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---获取存储请求体数据的临时文件名。如果请求体尚未被读取或已被读取到内存中，此函数将返回 nil。
---
---本函数返回的文件是只读的，通常情况下会被 Nginx 的内存池清理机制清理。不应该手工修改、更名或删除这个文件。
---
---如果请求体尚未被读取，请先调用 ngx.req.read_body (或打开 lua_need_request_body 选项强制本模块读取请求体。此方法不推荐）。
---
---如果请求体已经被读入内存，请使用 ngx.req.get_body_data 函数代替。
---
---如需要强制在临时文件中保存请求体，请打开 client_body_in_file_only 选项。
---
---这个函数在 v0.3.1rc17 版本中首次引入。
---
---更多用法请参考 ngx.req.get_body_data。
function ngx.req.get_body_file()
end

---语法: ngx.req.set_body_data(data)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---使用 data 参数指定的内存数据设置当前请求的请求体。
---
---如果当前请求的请求体尚未被读取，它将被安全地丢弃。当请求体已经被读进内存或缓存在磁盘文件中时，相应的内存或磁盘文件将被立即清理回收。
---
---这个函数在 v0.3.1rc18 版本中首次引入。
---
---更多用法请参考 ngx.req.set_body_file。
function ngx.req.set_body_data(data)
end

---语法: ngx.req.set_body_file(file_name, auto_clean?)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---使用 file_name 参数指定的数据文件设置当前请求的请求体。
---
---当可选参数 auto_clean 设置为 true 时，在本次请求完成，或本次请求内再次调用本函数或 ngx.req.set_body_data 时，
---file_name 文件将被删除。auto_clean 默认值是 false。
---
---请确保 file_name 参数指定的文件存在，并设置合适的操作权限对 Nginx worker 可读，以避免抛出 Lua 异常。
---
---如果当前请求的请求体尚未被读取，它将被安全地丢弃。当请求体已经被读进内存或缓存在磁盘文件中时，相应的内存或磁盘文件将被立即清理回收。
---
---这个函数在 v0.3.1rc18 版本中首次引入。
---
---更多用法请参考 ngx.req.set_body_data。
function ngx.req.set_body_file(file_name,auto_clean)
end

---语法: ngx.exec(uri, args?)
---
---环境: rewrite_by_lua, access_by_lua*, content_by_lua**
---
---使用 uri、args 参数执行一个内部跳转，与 echo-nginx-module 的 echo_exec 指令有些相似。
---
--- ngx.exec('/some-location');
--- ngx.exec('/some-location', 'a=3&b=5&c=6');
--- ngx.exec('/some-location?a=3&b=5', 'c=6');
---可选第二个参数 args 可被用来指名额外的 URI 查询参数，例如：
---
--- ngx.exec("/foo", "a=3&b=hello%20world")
---另外，对于 args 参数可使用一个 Lua 表，内部通过 ngx_lua 完成 URI 转义和字符串的连接。
---
--- ngx.exec("/foo", { a = 3, b = "hello world" })
---该结果和上一个示例是一样的。
function ngx.exec(uri,args)
end

---语法: ngx.redirect(uri, status?)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---发出一个 HTTP 301 或 302 重定向到 uri。
---
---可选项 status 参数指定使用什么 HTTP 状态码。目前支持下面几个状态码：
---
---301
---302 （默认）
---303
---307
---默认使用 302 （ngx.HTTP_MOVED_TEMPORARILY）。
---
---假设当前服务名是 localhost 并且监听端口是 1984，这里有个例子：
function ngx.redirect(uri,status)
end

---语法: ok, err = ngx.print(...)
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---将输入参数合并发送给 HTTP 客户端 (作为 HTTP 响应体)。如果此时还没有发送响应头信息，本函数将先发送 HTTP 响应头，再输出响应体。
---自版本 v0.8.3 起，本函数当成功时返回 1，失败时返回 nil 以及一个描述错误的字符串。
---Lua 的 nil 值输出 "nil" 字符串，Lua 的布尔值输出 "true" 或 "false" 字符串。
---
---输入允许字符串嵌套数组，数组中所有元素相按顺序输出。
---
--- local table = {
---     "hello, ",
---     {"world: ", true, " or ", false,
---         {": ", nil}}
--- }
--- ngx.print(table)
---将输出
---
--- hello, world: true or false: nil
---非数组表(哈希表)参数将导致抛出 Lua 异常。
---
---ngx.null 常量输出为 "null" 字符串。
---
---本函数为异步调用，将立即返回，不会等待所有数据被写入系统发送缓冲区。要以同步模式运行，请在调用 ngx.print
---之后调用 ngx.flush(true)。这种方式在流式输出时非常有用。更多细节请参考 ngx.flush。
---
---请注意，ngx.print 和 ngx.say 都会调用 Nginx body 输出过滤器，这种操作非常“昂贵”。所以，在“热”循环中使用这两个函数要非常小心；
---可以通过 Lua 进行缓存以节约调用。
---@return boolean,string @ok,err
function ngx.print(...)
end

---语法: ok, err = ngx.say(...)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---与 ngx.print 相同,同时末尾添加一个回车符。
function ngx.say(...)
end

---日志类型
ngx.STDERR = 1
ngx.EMERG = 2
ngx.ALERT = 3
ngx.CRIT = 4
ngx.ERR = 5
ngx.WARN = 6
ngx.NOTICE = 7
ngx.INFO = 8
ngx.DEBUG = 9
---语法: ngx.log(log_level, ...)
---环境: init_by_lua*, init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---将参数拼接起来，按照设定的日志级别记入 error.log。
---Lua nil 参数将输出 "nil" 字符串；Lua 布尔参数将输出 "true" 或 "false" 字符串；ngx.null 常量将输出 "null" 字符串。
---log_level 参数可以使用类似 ngx.ERR 和 ngx.WARN 的常量。更多信息请参考 Nginx log level constants。
---在 Nginx 内核中硬编码限制了单条错误信息最长为 2048 字节。这个长度包含了最后的换行符和开始的时间戳。
---如果信息长度超过这个限制，Nginx 将把信息文本截断。这个限制可以通过修改 Nginx 源码中 src/core/ngx_log.h 文件中的 NGX_MAX_ERROR_STR 宏定义调整。
function ngx.log(log_level,...)
end

---语法: ok, err = ngx.flush(wait?)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---向客户端刷新响应输出。
---
---自 v0.3.1rc34 版本开始，ngx.flush 接受一个布尔型可选参数 wait (默认值 false)。当通过默认参数调用时，本函数发起一个异步调用
---(将直接返回，不等待输出数据被写入系统发送缓冲区)。当把 wait 参数设置为 true 时，本函数将以同步模式执行。
---
---在同步模式下，本函数不会立即返回，一直到所有输出数据被写入系统输出缓冲区，或者到达发送超时 send_timeout 时间。请注意，
---因为使用了 Lua 协程机制，本函数即使在同步模式下也不会阻塞 Nginx 事件循环。
---
---当 ngx.flush(true) 在 ngx.print 或 ngx.say 之后被立刻调用时，它将使这两个函数以同步模式执行。这在流式输出时非常有用。
---
---请注意，ngx.flush 在 HTTP 1.0 缓冲输出模式下不起作用。详情请参考 HTTP 1.0 support。
function ngx.flush(wait)
end

---语法: ngx.exit(status)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---当 status >= 200 (即 ngx.HTTP_OK 及以上) 时，本函数中断当前请求执行并返回状态值给 nginx。
---
---当 status == 0 (即 ngx.OK) 时，本函数退出当前的“处理阶段句柄” (或当使用 content_by_lua* 指令时的“内容句柄”) ，
---继续执行当前请求的下一个阶段 (如果有)。
---
---status 参数可以是 status argument can be ngx.OK, ngx.ERROR, ngx.HTTP_NOT_FOUND, ngx.HTTP_MOVED_TEMPORARILY 或其它 HTTP status constants。
---
---要返回一个自定义内容的错误页，使用类似下面的代码：
---
--- ngx.status = ngx.HTTP_GONE
--- ngx.say("This is our own content")
--- --- 退出整个请求而不是当前处理阶段
--- ngx.exit(ngx.HTTP_OK)
---实际效果:
---
--- $ curl -i http://localhost/test
--- HTTP/1.1 410 Gone
--- Server: nginx/1.0.6
--- Date: Thu, 15 Sep 2011 00:51:48 GMT
--- Content-Type: text/plain
--- Transfer-Encoding: chunked
--- Connection: keep-alive
---
--- This is our own content
function ngx.exit(status)
end

---语法: ok, err = ngx.eof()
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*
---
---明确指定响应输出流的末尾。在 HTTP 1.1 分块编码输出模式下，它会触发 Nginx 内核发送“最后一块”。
---当禁用下游连接的 HTTP 1.1 保持连接功能后，用户程序可以通过调用此方法，使下游 HTTP 客户端主动关闭连接。
---这招可以用来执行后台任务，而无需 HTTP 客户端等待连接关闭，例如：
---
--- location = /async {
---     keepalive_timeout 0;
---     content_by_lua_block {
---         ngx.say("got the task!")
---         ngx.eof()  --- 下游 HTTP 客户端将在这里断开连接
---         --- 在这里访问 MySQL, PostgreSQL, Redis, Memcached 等 ...
---     }
--- }
---但是，如果用户程序创建子请求通过 Nginx 上游模块访问其他 location 时，需要配置上游模块忽略客户端连接中断
---(如果不是默认)。例如，默认时，基本模块 ngx_http_proxy_module 在客户端关闭连接后，立刻中断主请求和子请求，
---所以在 ngx_http_proxy_module 配置的 location 块中打开 proxy_ignore_client_abort 开关非常重要：
--- proxy_ignore_client_abort on;
---一个执行后台任务的方法是使用 ngx.timer.at API。
function ngx.eof()
end

---语法: ngx.sleep(seconds)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---无阻塞地休眠特定秒。时间可以精确到 0.001 秒 (毫秒)。
---
---在后台，此方法使用 Nginx 的定时器。
---
---自版本 0.7.20 开始，0 也可以作为时间参数被指定。
function ngx.sleep(seconds)
end

---语法: newstr = ngx.escape_uri(str)
---
---环境: init_by_lua*, init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---对 str 进行 URI 编码。
function ngx.escape_uri(str)
end

---语法: newstr = ngx.unescape_uri(str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---将转义过的 URI 内容 str 解码。
---
---例如,
---
--- ngx.say(ngx.unescape_uri("b%20r56+7"))
---输出
---
---b r56 7
function ngx.unescape_uri(str)
end

---语法: str = ngx.encode_args(table)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*
---
---根据 URI 编码规则，将 Lua 表编码成一个查询参数字符串。
---
---例如，
--- ngx.encode_args({foo = 3, ["b r"] = "hello world"})
---生成
---
---foo=3&b%20r=hello%20world
---Lua 表的 key 必须是 Lua 字符串。
---
---支持多值参数。可以使用 Lua 表存储参数值，例如：
---
--- ngx.encode_args({baz = {32, "hello"}})
---输出
---
---baz=32&baz=hello
---@return string
function ngx.encode_args(table)
end

---语法: table = ngx.decode_args(str, max_args?)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*
---
---将 URI 编码的查询字符串解码为 Lua 表。本函数是 ngx.encode_args 的逆函数。
---
---可选的参数 max_args 可以用来指定从 str 中最多解析的参数个数。默认时，最多解析 100 个请求参数 (包括同名的)。为避免潜在的拒绝服务式攻击 (denial of services, DOS)，超过 max_args 数量上限的 URI 参数被丢弃，
---
---这个参数可以被设成 0 以去掉解析参数数量上限：
---
--- local args = ngx.decode_args(str, 0)
---强烈不推荐移除 max_args 限制。
---@return table
function ngx.decode_args(str,max_args)
end

---语法: newstr = ngx.encode_base64(str, no_padding?)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过 base64 对 str 字符串编码。
---
---自 0.9.16 版本后，引入了一个布尔值参数 no_padding 用来控制是否需要编码数据填充 等号 字符串（默认为 false，代表需要填充）。
---@return string
function ngx.encode_base64(str,no_padding)
end

---语法: newstr = ngx.decode_base64(str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过 base64 解码 str 字符串得到未编码过的字符串。如果 str 字符串没有被正常解码将会返回 nil。
function ngx.decode_base64(str)
end

---语法: intval = ngx.crc32_short(str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过一个字符串计算循环冗余校验码。
---
---这个方法最好在字符串较少时调用（比如少于30-60字节），他的结果和 ngx.crc32_long 是一样的。
---
---本质上，它只是 Nginx 内核函数 ngx_crc32_short 的简单封装。
function ngx.crc32_short(str)
end

---语法: intval = ngx.crc32_long(str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过一个字符串计算循环冗余校验码。
---
---这个方法最好在字符串较多时调用（比如大于30-60字节），他的结果和 ngx.crc32_short 是一样的。
---
---本质上，它只是 Nginx 内核函数 ngx_crc32_long 的简单封装。
function ngx.crc32_long(str)
end

---语法: digest = ngx.hmac_sha1(secret_key, str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过 str 待运算数据和 secret_key 密钥串生成结果。关于 HMAC-SHA1。
---
---通过 HMAC-SHA1 的运算会得到二进制数据，如果你想要把结果转为文本形式，你可以使用 ngx.encode_base64 函数。
---
---举一个例子,
---
--- local key = "thisisverysecretstuff"
--- local src = "some string we want to sign"
--- local digest = ngx.hmac_sha1(key, src)
--- ngx.say(ngx.encode_base64(digest))
---将会输出
---
---R/pvxzHC4NLtj7S+kXFg/NePTmk=
function ngx.hmac_sha1(secret_key,str)
end

---语法: digest = ngx.md5(str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过 MD5 计算 str 字符串返回十六进制的数据。
---
---举一个例子,
---
--- location = /md5 {
---     content_by_lua_block { ngx.say(ngx.md5("hello")) }
--- }
---将会输出
---
---5d41402abc4b2a76b9719d911017c592
---如果需要返回二进制数据请看 ngx.md5_bin 方法。
function ngx.md5(str)
end

---语法: digest = ngx.md5_bin(str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过 MD5 计算 str 字符串返回二进制的数据。
---
---如果需要返回纯文本数据请看 ngx.md5 方法。
function ngx.md5_bin(str)
end

---语法: digest = ngx.sha1_bin(str)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---通过 SHA-1 计算 str 字符串返回二进制的数据。
---
---在安装 Nginx 时 这个函数需要 SHA-1 的支持。（这通常说明应该在安装 Nginx 时一起安装 OpenSSL 库）。
function ngx.sha1_bin(str)
end

---语法: quoted_value = ngx.quote_sql_str(raw_value)
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---根据 MySQL 转义规则返回一个转义后字符串。
function ngx.quote_sql_str(raw_value)
end

---语法: str = ngx.today()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---从 nginx 的时间缓存(不像 Lua 的日期库，该时间不涉及系统调用)返回当前的日期(格式：yyyy-mm-dd)。
---
---这是个本地时间。
function ngx.today()
end

---语法: secs = ngx.time()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回从新纪元到从 nginx 时间缓存(不像 Lua 的日期库，该时间不涉及系统调用))获取的当前时间戳所经过的秒数。
---
---通过先调用 ngx.update_time 会强制更新 nginx 的时间缓存。
function ngx.time()
end

---返回当前时间戳,带毫秒1290079655.001 但是一次请求内该值不会改变
---语法: secs = ngx.now()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回一个浮点型的数字，该数字是从新纪元到从 nginx 时间缓存(不像 Lua 的日期库，该时间不涉及系统调用)获取的当前时间戳所经过的时间(以秒为单位，小数部分是毫秒)。
---
---通过先调用 ngx.update_time ，你可以强制更新 nginx 时间缓存。
function ngx.now()
end

---强制更新缓存的时间
---语法: ngx.update_time()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---强行更新 Nginx 当前时间缓存。此调用会涉及到一个系统调用，因此会有一些系统开销，所以不要滥用。
---
---这个API最早出现在 v0.3.1rc32 版本中。
function ngx.update_time()
end

---语法: str = ngx.localtime()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回 nginx 时间缓存(不像 Lua 的 os.date 函数，该时间不涉及系统调用)的当前时间戳(格式：yyyy-mm-dd hh:mm:ss)。
---
---这是个本地时间。
function ngx.localtime()
end

---语法: str = ngx.utctime()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回 nginx 时间缓存(不像 Lua 的 os.date 函数，该时间不涉及系统调用)的当前时间戳(格式：yyyy-mm-dd hh:mm:ss)。
---
---这是个UTC时间。
function ngx.utctime()
end

---语法: str = ngx.cookie_time(sec)
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回一个可以用做 cookie 过期时间的格式化字符串。参数 sec 是以秒为单位的时间戳（比如 ngx.time 的返回）。
---
--- ngx.say(ngx.cookie_time(1290079655))
---     --- yields "Thu, 18-Nov-10 11:27:35 GMT"
function ngx.cookie_time(sec)
end

---语法: str = ngx.http_time(sec)
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回一个可以用在 http 头部时间的格式化字符串（例如，在 Last-Modified 头的使用）。参数 sec 是以秒为单位的时间戳（比如 ngx.time 的返回）。
---
--- ngx.say(ngx.http_time(1290079655))
---     --- yields "Thu, 18 Nov 2010 11:27:35 GMT"
function ngx.http_time(sec)
end

---语法: sec = ngx.parse_http_time(str)
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---解析 http 时间字符串（比如从 ngx.http_time 返回内容）。成功情况下返回秒数，错误的输入字符格式返回 nil 。
---
--- local time = ngx.parse_http_time("Thu, 18 Nov 2010 11:27:35 GMT")
--- if time == nil then
---     ...
--- end
function ngx.parse_http_time(str)
end

---语法: value = ngx.is_subrequest
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---
---如果当前请求是 nginx 子请求返回 true ，否则返回 false 。
ngx.is_subrequest = false

---当前运行的nginx阶段
---syntax: str = ngx.get_phase()
---context: init_by_lua,init_worker_by_lua,set_by_lua,rewrite_by_lua,access_by_lua,content_by_lua,header_filter_by_lua,body_filter_by_lua,log_by_lua
---init init_by_lua* 运行环境。
---init_worker init_worker_by_lua* 运行环境。
---ssl_cert ssl_certificate_by_lua_block* 运行环境。
---ssl_session_fetch ssl_session_fetch_by_lua* 运行环境.
---ssl_session_store ssl_session_store_by_lua* 运行环境.
---set set_by_lua* 运行环境。
---rewrite rewrite_by_lua* 运行环境。
---balancer balancer_by_lua_* 运行环境。
---access access_by_lua* 运行环境。
---content content_by_lua* 运行环境。
---header_filter header_filter_by_lua* 运行环境。
---body_filter body_filter_by_lua* 运行环境。
---log log_by_lua* 运行环境。
---timer ngx.timer.* 类的用户回调函数运行环境。
function ngx.get_phase()
end

ngx.re = {}
---语法: captures, err = ngx.re.match(subject, regex, options?, ctx?, res_table?)
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---使用 Perl 兼容正则表达式 regex 匹配字符串 subject，并使用可选的参数 options 作为正则表达式选项。
---
---仅返回第一个匹配结果，无结果时返回 nil。当出错时，例如正则表达式出错或者超出 PCRE 堆栈限制，将返回 nil 以及一个描述错误的字符串。
---
---当匹配成功时，返回一个 Lua 表 captures，其中 captures[0] 存储(整个模板)匹配出的完整子字符串，captures[1] 存储第一个括号内的子模板匹配结果，captures[2] 存储第二个，以此类推。
---
--- local m, err = ngx.re.match("hello, 1234", "[0-9]+")
--- if m then
---     --- m[0] == "1234"
---
--- else
---     if err then
---         ngx.log(ngx.ERR, "error: ", err)
---         return
---     end
---
---     ngx.say("match not found")
--- end
--- local m, err = ngx.re.match("hello, 1234", "([0-9])[0-9]+")
--- --- m[0] == "1234"
--- --- m[1] == "1"
---自 v0.7.14 版本后，本模块支持正则表达式命名捕获(Named capture)，结果以键值对的方式与数字编号的结果在同一个 Lua 表中返回。
---
--- local m, err = ngx.re.match("hello, 1234", "([0-9])(?<remaining>[0-9]+)")
--- --- m[0] == "1234"
--- --- m[1] == "1"
--- --- m[2] == "234"
--- --- m["remaining"] == "234"
---在 captures 表中，不匹配的子模板将返回 false 值。
---
--- local m, err = ngx.re.match("hello, world", "(world)|(hello)|(?<named>howdy)")
--- --- m[0] == "hello"
--- --- m[1] == false
--- --- m[2] == "hello"
--- --- m[3] == false
--- --- m["named"] == false
---通过指定 options (选项)来控制匹配操作的执行方式。支持以下选项字符。
---
---a             锚定模式 (仅从目标字符串开始位置匹配)
---
---d             启用 DFA 模式(又名最长令牌匹配语义)。
---              此选项需要 PCRE 6.0 以上版本，否则将抛出 Lua 异常。
---              此选项最早出现在 ngx_lua v0.3.1rc30 版本中。
---
---D             启用重复命名模板支持。子模板命名可以重复，在结果中以数组方式返回。例如：
---                local m = ngx.re.match("hello, world",
---                                       "(?<named>\w+), (?<named>\w+)",
---                                       "D")
---                --- m["named"] == {"hello", "world"}
---              此选项最早出现在 v0.7.14 版本中，需要 PCRE 8.12 以上版本支持.
---
---i             大小写不敏感模式 (类似 Perl 的 /i 修饰符)
---
---j             启用 PCRE JIT 编译，此功能需要 PCRE 8.21 以上版本以 ---enable-jit 选项编译。
---              为达到最佳性能，此选项应与 'o' 选项同时使用。
---              此选项最早出现在 ngx_lua v0.3.1rc30 版本中。
---
---J             启用 PCRE Javascript 兼容模式。
---              此选项最早出现在 v0.7.14 版本中，需要 PCRE 8.12 以上版本支持.
---
---m             多行模式 (类似 Perl 的 /m 修饰符)
---
---o             仅编译一次模式 (类似 Perl 的 /o 修饰符)
---              启用 worker 进程级正则表达式编译缓存。
---
---s             单行模式 (类似 Perl 的 /s 修饰符)
---
---u             UTF-8 模式。此选项需要 PCRE 以 ---enable-utf8 选项编译，否则将抛出 Lua 异常。
---
---U             类似 "u" 模式，但禁用了 PCRE 对目标字符串的 UTF-8 合法性检查。
---              此选项最早出现在 ngx_lua v0.8.1 版本中。
---
---x             扩展模式 (类似 Perl 的 /x 修饰符)
---这些选项可以组合使用：
---
--- local m, err = ngx.re.match("hello, world", "HEL LO", "ix")
--- --- m[0] == "hello"
--- local m, err = ngx.re.match("hello, 美好生活", "HELLO, (.{2})", "iu")
--- --- m[0] == "hello, 美好"
--- --- m[1] == "美好"
---在优化性能时，o 选项非常有用，因为正则表达式模板将仅仅被编译一次，之后缓存在 worker 级的缓存中，并被此 nginx worker 处理的所有请求共享。缓存数量上限可以通过 lua_regex_cache_max_entries 指令调整。
---
---可选的第四个参数 ctx 是一个 Lua 表，包含可选的 pos 域。当 ctx 表的 pos 域有值时，ngx.re.match 将从该位置起执行匹配(位置下标从 1 开始)。不论 ctx 表中是否已经有 pos 域，ngx.re.match 将在正则表达式被成功匹配后，设置 pos 域值为完整匹配子字符串 之后 的位置。当匹配失败时，ctx 表将保持不变。
---
--- local ctx = {}
--- local m, err = ngx.re.match("1234, hello", "[0-9]+", "", ctx)
---      --- m[0] = "1234"
---      --- ctx.pos == 5
--- local ctx = { pos = 2 }
--- local m, err = ngx.re.match("1234, hello", "[0-9]+", "", ctx)
---      --- m[0] = "34"
---      --- ctx.pos == 5
---参数 ctx 表与正则表达式修饰符 a 组合使用，可以用来建立一个基于 ngx.re.match 的词法分析器。
---
---注意，当指定参数 ctx 时，参数 options 不能空缺，当不需要使用 options 来指定正则表达式选项时，必须使用 Lua 空字符串 ("") 作为占位符。
---
---这个方法需要在 Nginx 中启用 PCRE 库。 (Known Issue With Special Escaping Sequences).
---
---要想确认 PCRE JIT 是否已经启用，需要在 Nginx 或 OpenResty 的 ./configure 配置脚本中，添加 ---with-debug 选项激活 Nginx 的调试日志。然后，在 error_log 指令中启用 error 错误日志级别。当 PCRE JIT 启用时，将出现下述信息：
---
---pcre JIT compiling result: 1
---自 0.9.4 版本开始，此函数接受第五个参数，res_table，让调用者可以自己指定存储所有匹配结果的 Lua 表。自 0.9.6 版本开始，调用者需要自己确保这个表是空的。这个功能对表预分配、重用以及节省 Lua 回收机制 (GC) 非常有用。
---
---这个功能最早出现在 v0.2.1rc11 版本中。
function ngx.re.match(subject,regex,options,ctx,res_table)
end

---语法: from, to, err = ngx.re.find(subject, regex, options?, ctx?, nth?)
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---与 ngx.re.match 类似但只返回匹配结果子字符串的开始索引 (from) 和结束索引 (to)。返回的索引值是基于 1 的，可以直接被用于 Lua 的 string.sub API 函数来获取匹配结果子串。
---当出现任何错误时 (例如错误的正则表达式或任何 PCRE 运行时错误)，这个 API 函数返回两个 nil 以及一个描述错误的的字符串。
---如果匹配不成功，此函数返回一个 nil 值。
---下面是一个示例：
--- local s = "hello, 1234"
--- local from, to, err = ngx.re.find(s, "([0-9]+)", "jo")
--- if from then
---     ngx.say("from: ", from)
---     ngx.say("to: ", to)
---     ngx.say("matched: ", string.sub(s, from, to))
--- else
---     if err then
---         ngx.say("error: ", err)
---         return
---     end
---     ngx.say("not matched!")
--- end
---此示例将输出
---from: 8
---to: 11
---matched: 1234
---因为此 API 函数并不创建任何新 Lua 字符串或 Lua 表，运行速度大大快于 ngx.re.match。所以如果可能请尽量使用本函数。
---自 0.9.3 版本开始，添加第 5 个可选参数 nth，用来指定第几个子匹配结果索引被返回。当 nth 为 0 (默认值) 时，返回完整匹配子串索引；当 nth 为 1 时，第一个(括号内的)子匹配结果索引被返回； 当 nth 为 2 时，第二个子匹配结果索引被返回，以此类推。当被指定的子匹配没有结果时，返回 nil。下面是一个例子：
--- local str = "hello, 1234"
--- local from, to = ngx.re.find(str, "([0-9])([0-9]+)", "jo", nil, 2)
--- if from then
---     ngx.say("matched 2nd submatch: ", string.sub(str, from, to))  --- yields "234"
--- end
---此 API 函数自 v0.9.2 版开始提供。
---@return number,number,string @from,to,err
function ngx.re.find(subject,regex,options,ctx,nth)
end

---正则匹配替换,不同的是会整个字符串替换
---语法: iterator, err = ngx.re.gmatch(subject, regex, options?)
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---与 ngx.re.match 行为类似，不同的是本函数返回一个 Lua 迭代器，使用户程序可以自行迭代 PCRE 正则表达式 regex 匹配字符串参数 <subject> 产生的所有结果。
---
---当出现错误时，例如发现错误的正则表达式时，返回 nil 和一个描述错误的字符串。
---
---下面用一个小例子演示基本用法：
---
--- local iterator, err = ngx.re.gmatch("hello, world!", "([a-z]+)", "i")
--- if not iterator then
---     ngx.log(ngx.ERR, "error: ", err)
---     return
--- end
---
--- local m
--- m, err = iterator()    --- m[0] == m[1] == "hello"
--- if err then
---     ngx.log(ngx.ERR, "error: ", err)
---     return
--- end
---
--- m, err = iterator()    --- m[0] == m[1] == "world"
--- if err then
---     ngx.log(ngx.ERR, "error: ", err)
---     return
--- end
---
--- m, err = iterator()    --- m == nil
--- if err then
---     ngx.log(ngx.ERR, "error: ", err)
---     return
--- end
---更常见的是使用 Lua 循环：
---
--- local it, err = ngx.re.gmatch("hello, world!", "([a-z]+)", "i")
--- if not it then
---     ngx.log(ngx.ERR, "error: ", err)
---     return
--- end
---
--- while true do
---     local m, err = it()
---     if err then
---         ngx.log(ngx.ERR, "error: ", err)
---         return
---     end
---
---     if not m then
---         --- no match found (any more)
---         break
---     end
---
---     --- found a match
---     ngx.say(m[0])
---     ngx.say(m[1])
--- end
---可选参数 options 含义与使用方法与 ngx.re.match 相同。
---
---在当前实现中，本函数返回的迭代器仅可被用于单一请求。也就是说，此迭代器 不能 被赋值给属于持久命名空间的变量，例如 Lua 包(模块)。
---
---这个方法需要在 Nginx 中启用 PCRE 库。 (Known Issue With Special Escaping Sequences)。
---
---这个功能最早出现在 v0.2.1rc12 版本中。
function ngx.re.gmatch(subject,regex,options)
end

---语法: newstr, n, err = ngx.re.sub(subject, regex, replace, options?)
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---使用 Perl 兼容正则表达式 regex 匹配字符串 subject，将第一个结果替换为字符串或函数类型参数 replace。可选参数 options 含义与 ngx.re.match 相同。
---
---这个方法返回结果字符串以及成功替换的数量。当发生失败时，例如正则表达式或 <replace> 字符串参数语法错，将返回 nil 以及一个描述错误的字符串。
---
---当 replace 是一个字符串时，它们被视为一个特殊字符串替换模板。例如：
---
--- local newstr, n, err = ngx.re.sub("hello, 1234", "([0-9])[0-9]", "[$0][$1]")
--- if newstr then
---     --- newstr == "hello, [12][1]34"
---     --- n == 1
--- else
---     ngx.log(ngx.ERR, "error: ", err)
---     return
--- end
---其中 $0 指模板匹配的完整子字符串，$1 指第一个括号内匹配的子串。
---
---花括号可以被用来从背景字符串中消除变量名歧义。
---
--- local newstr, n, err = ngx.re.sub("hello, 1234", "[0-9]", "${0}00")
---     --- newstr == "hello, 100234"
---     --- n == 1
---要在 replace 中使用美元字符($)，可以使用另外一个该符号作为转义，例如，
---
--- local newstr, n, err = ngx.re.sub("hello, 1234", "[0-9]", "$$")
---     --- newstr == "hello, $234"
---     --- n == 1
---不要使用反斜线转义美元字符；它不会象你想象的那样工作。
---
---当 replace 参数是一个 "函数" 时，它将被通过参数 "匹配表" 调用，用来生成替换字符串。被送入 replace 函数的 "匹配表" 与 ngx.re.match 的返回值相同。例如：
---
--- local func = function (m)
---     return "[" .. m[0] .. "][" .. m[1] .. "]"
--- end
--- local newstr, n, err = ngx.re.sub("hello, 1234", "( [0-9] ) [0-9]", func, "x")
---     --- newstr == "hello, [12][1]34"
---     --- n == 1
---在 replace 函数返回值中的美元字符没有任何特殊含义。
---
---这个方法需要在 Nginx 中启用 PCRE 库。 (Known Issue With Special Escaping Sequences).
---
---这个功能最早出现在 v0.2.1rc13 版本中。
function ngx.re.sub(subject,regex,replace,options)
end

---语法: newstr, n, err = ngx.re.gsub(subject, regex, replace, options?)
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---就象 ngx.re.sub, 但执行全局替换。
---
---下面是例子:
---
--- local newstr, n, err = ngx.re.gsub("hello, world", "([a-z])[a-z]+", "[$0,$1]", "i")
--- if newstr then
---     --- newstr == "[hello,h], [world,w]"
---     --- n == 2
--- else
---     ngx.log(ngx.ERR, "error: ", err)
---     return
--- end
--- local func = function (m)
---     return "[" .. m[0] .. "," .. m[1] .. "]"
--- end
--- local newstr, n, err = ngx.re.gsub("hello, world", "([a-z])[a-z]+", func, "i")
---     --- newstr == "[hello,h], [world,w]"
---     --- n == 2
---这个方法需要在 Nginx 中启用 PCRE 库。 (Known Issue With Special Escaping Sequences).
---
---这个功能最早出现在 v0.2.1rc15 版本中。
function ngx.re.gsub(subject,regex,replace,options)
end

---@class ngx.shared @共享字典对象
local shared = {}
---获取基于共享内存名为 DICT 的 Lua 字典对象，它是一个共享内存区块，通过 lua_shared_dict 指令定义。
---注解,使的共享字典可以点出类
---@type table<string, ngx.shared>
ngx.shared = { key = shared }

---语法: value, flags = ngx.shared.DICT:get(key)
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---从 ngx.shared.DICT 字典中获取名为 key 的键 (key) 值。如果此 key 不存在或已过期，返回 nil。
---当发生错误时，将返回 nil 和一个描述错误的字符串。
---返回值将保持写入字典时的原始数据类型，例如，Lua 布尔型、数字型、或字符串型。
---此方法的第一个参数必须是该字典对象本身，例如，
--- local cats = ngx.shared.cats
--- local value, flags = cats.get(cats, "Marry")
---或使用 Lua 的“语法糖”形式来调用方法：
--- local cats = ngx.shared.cats
--- local value, flags = cats:get("Marry")
---这两种形式完全等价。
---如果用户标志 (flags) 是 0 (默认值)，将不会返回 flags 值。
---@param key string
---@return string,number @value,flags
function shared:get(key)
end

---全局内存取值,即时过期依然返回
---语法: value, flags, stale = ngx.shared.DICT:get_stale(key)
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---与 get 方法类似，但即使 key 已经过期依然返回值。
---返回第三个值，stale，来标识该 key 是否已经过期。
---需要注意的是，已过期的 key 无法保证存在，所以永远不应该依赖已过期项的可用性。
---syntax: value,flags,stale = ngx.shared.DICT:get_stale(key)
---stale 代表是否已经过期
---@param key string
---@return string,number,boolean @value,flags,stale
function shared:get_stale(key)
end

---赋值到共享内存,存在则覆盖
---语法: success, err, forcible = ngx.shared.DICT:set(key, value, exptime?, flags?)
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---无条件在基于共享内存的字典 ngx.shared.DICT 中设置一个 key-value (键-值)对。返回三个值：
---success: 布尔值，用以标识 key-value 对是否存储成功；
---err: 文字描述的错误信息，例如 "no memory" (内存不足)；
---forcible: 布尔值，用以标识是否有其他可用项被强制删除，因为共享内存区块中的存储空间不足。
---value 参数可以是 Lua 布尔值、数字、字符串，或 nil。其类型也将被存储在字典中，之后通过 get 方法可以原样取出。
---通过可选的 exptime 参数给写入的 key-value 对设定过期时间 (单位秒)。时间的精度是 0.001 秒。如果 exptime 送入 0 (默认值)，此项将永不过期。
---通过可选的 flags 参数给写入项设定一个用户标志，之后可以与值一起被取出。用户标志在内部被存储为一个 32 位无符号整数。默认值是 0。此参数最早出现在 v0.5.0rc2 版本中。
---当无法给当前的 key-value 项分配内存时，set 方法将根据最近最少使用 (Least-Recently Used, LRU) 算法，删除存储中已有的项。需要注意的是，LRU 算法在这里优先考虑过期时间。如果在删除了最多数十项以后剩余存储空间依旧不足 (由于 lua_shared_dict 定义的总存储空间限制或内存碎片化)，success 将返回 false，同时 err 将返回 no memory。
---
---如果此方法执行成功的同时，根据 LRU 算法强制移除了字典中其他尚未过期的项，forcible 返回值将是 true。如果存储时没有移除其他有效项，forcible 返回值将是 false。
---此方法第一个参数必须是该字典对象本身，例如，
---
--- local cats = ngx.shared.cats
--- local succ, err, forcible = cats.set(cats, "Marry", "it is a nice cat!")
---或使用 Lua 的“语法糖”形式来调用方法：
---
--- local cats = ngx.shared.cats
--- local succ, err, forcible = cats:set("Marry", "it is a nice cat!")
---这两种形式完全等价。
---syntax: success,err,forcible = ngx.shared.DICT:set(key,value,exptime?,flags?)
--- success 是否通过
---  forcible 是否覆盖
---  err 错误描述 no memory exists
---  exptime 赋值后多久过期,默认0永久,单位秒
---  flags 自定义的用户标识默认为0
---@param key string
---@param value string
---@param exptime number|nil
---@param flags number|nil
---@return boolean,string,boolean @success,err,forcible
function shared:set(key,value,exptime,flags)
end

---设置全局内存值,存在则返回no memory错误
---语法: ok, err = ngx.shared.DICT:safe_set(key, value, exptime?, flags?)
---
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---类似 set 方法，但当共享内存区块存储空间不足时，不覆盖 (最近最少使用的) 有效的项 (非过期项)。此时，它将返回 nil 和字符串 "no memory" (内存不足)。
---syntax: ok,err = ngx.shared.DICT:safe_set(key,value,exptime?,flags?)
---success 是否通过
---forcible 是否覆盖
---err 错误描述 no memory exists
---exptime 赋值后多久过期,默认0永久,单位秒
---flags 自定义的用户标识默认为0
function shared:safe_set(key,value,exptime,flags)
end

---语法: success, err, forcible = ngx.shared.DICT:add(key, value, exptime?, flags?)
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---类似 set 方法，但仅当存储字典 ngx.shared.DICT 中 不存在 该 key 时执行存储 key-value 对。
---增加一个全局内存值,存在则返回exists错误,如果内存用满则采用红黑树逻辑覆盖旧数据
---如果参数 key 在字典中已经存在 (且没有过期)，success 返回值为 false，同时 err 返回 "exist" (已存在)。
---这个功能最早出现在 v0.3.1rc22 版本中。
---@param key string
---@param value string
---@param exptime number
---@return boolean,string @ok,err
function shared:add(key,value,exptime,flags)
end

---语法: ok, err = ngx.shared.DICT:safe_add(key, value, exptime?, flags?)
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---类似 add 方法，但当共享内存区块存储空间不足时，不覆盖 (最近最少使用的) 有效的项 (非过期项)。此时，它将返回 nil 和字符串 "no memory" (内存不足)。
function shared:safe_add(key,value,exptime,flags)
end

---语法: success, err, forcible = ngx.shared.DICT:replace(key, value, exptime?, flags?)
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---与 set 方法类似，但仅当存储字典 ngx.shared.DICT 中 存在 该 key 时执行存储 key-value 对。
---如果参数 key 在字典中 不 存在 (或已经过期)，success 返回值为 false，同时 err 返回 "not found" (没找到)。
function shared:replace(key,value,exptime,flags)
end

---ngx.shared.DICT.delete
---语法: ngx.shared.DICT:delete(key)
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---从基于同享内存的字典 ngx.shared.DICT 中无条件移除 key-value 对。
---同 ngx.shared.DICT:set(key, nil) 等价。
function shared:delete(key)
end

---增量一个全局内存值,key必须存在且值是数字
---语法: newval, err, forcible? = ngx.shared.DICT:incr(key, value, init?)
---
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---在基于共享内存的字典 ngx.shared.DICT 中递增 key 的 (数字) 值，步长为 value。当操作成功时返回结果数字，否则返回 nil 和错误信息字符串。
---
---当 key 在共享内存字典中不存在或已经过期： When the key does not exist or has already expired in the shared dictionary,
---
---如果 init 参数没有指定或使用 nil，该方法将返回 nil 并返回错误信息 "not found"。
---如果 init 参数被指定是一个 number 类型，该方法将创建一个以 init + value 为值的新 key。
---如同 add 方法，当共享内存区出现空间不足时，他也会覆盖存储中未过期的数据项（最近最少使用规则）。
---
---当 init 参数没有指定时，forcible 参数将永远返回 nil。
---
---如果该方法调用成功，但它是通过数据字典的 LRU 方式强制删除其他未完结过期的数据项，forcible 的返回值将是 true。如果本次数据项存储没有强制删除任何其他有效数据，forcible 的返回值将是 false。
---
---如果 key 的原始值不是一个有效的 Lua 数字，返回 nil 和 "not a number" (不是数字)。
---
---value 和 init 参数可以是任意有效的 Lua 数字，包括负数和浮点数。
---@param key string
---@param value number
---@param init number|nil
---@return number,string,boolean @newval,err,forcible
function shared:incr(key,value,init)
end

---syntax: length, err = ngx.shared.DICT:lpush(key, value)
---
---context: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---在基于共享字典 ngx.shared.DICT 命名是 key 的链表头部插入指定的（数字或字符串）value ，返回值是插入后链表包含的对象数量。
---
---如果 key 不存在，会在执行插入操作之前创建一个空的链表。当 key 已经有值但不是链表，会返回 nil 和 "value not a list"。
---
---当共享内存区间中的存储空间不足时，它永远不会覆盖这里未过期数据（最近最少使用）。这种情况，它将直接返回 nil 和字符串 "no memory"。
function shared:lpush(key,value)
end

---syntax: length, err = ngx.shared.DICT:rpush(key, value)
---
---context: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---与 lpush 方法相似，但该方法将指定 value （数字或字符串） 插入到命名为 key 的链表末尾。
function shared:rpush(key,value)
end

---syntax: val, err = ngx.shared.DICT:lpop(key)
---
---context: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---删除并返回基于共享字典 ngx.shared.DICT 命名为 key 链表的第一个对象。
---
---如果 key 不存在，它将返回 nil。当 key 已经存在却不是链表时，将返回 nil 和 "value not a list"。
---@return string,string @str,err
function shared:lpop(key)
end

---syntax: val, err = ngx.shared.DICT:rpop(key)
---
---context: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---删除并返回基于共享字典 ngx.shared.DICT 命名为 key 链表的最后一个对象。
---
---如果 key 不存在，它将返回 nil。当 key 已经存在却不是链表时，将返回 nil 和 "value not a list"。
function shared:rpop(key)
end

---syntax: len, err = ngx.shared.DICT:llen(key)
---
---context: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回基于共享字典 ngx.shared.DICT 命名为 key 的链表长度。
---
---如果 key 不存在，将被解释为一个空链表，所以返回 0。 当 key 已经存在却不是链表时，将返回 nil 和 "value not a list"。
---@return number,string @err
function shared:llen(key)
end

---语法: ngx.shared.DICT:flush_all()
---
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---清空字典中的所有内容。这个方法并不实际释放字典占用的内存块，而是标记所有存在的内容为已过期。
function shared:flush_all()
end

---语法: flushed = ngx.shared.DICT:flush_expired(max_count?)
---
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---清除字典中已过期的的内容，最多清除可选参数 max_count (最大数量) 个。当参数 max_count 值为 0 或者未指定时，意为无数量限制。返回值为实际清除的数量。
---
---与 flush_all 方法不同，此方法释放删除掉的已过期内容占用的内存。
---@param max_count number|nil
---@return number
function shared:flush_expired(max_count)
end

---语法: keys = ngx.shared.DICT:get_keys(max_count?)
---
---环境: init_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---获取字典中存储的 key 列表，最多 <max_count> 个。
---
---默认时，前 1024 个 key (如果有) 被返回。当参数 <max_count> 值为 0 时，字典中所有的 key 被返回，即使超过 1024 个。
---
---警告 在包含非常多 key 的字典中调用此方法要非常小心。此方法会锁定字典一段时间，会阻塞所有访问字典的 nginx worker 进程。
---@param max_count number|nil
---@return table[]
function shared:get_keys(max_count)
end

---语法: str = ngx.get_phase()
---
---环境: init_by_lua*, init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---检索当前正在执行的阶段名称。返回值可能有：
---
---init init_by_lua* 运行环境。
---init_worker init_worker_by_lua* 运行环境。
---ssl_cert ssl_certificate_by_lua_block* 运行环境。
---ssl_session_fetch ssl_session_fetch_by_lua* 运行环境.
---ssl_session_store ssl_session_store_by_lua* 运行环境.
---set set_by_lua* 运行环境。
---rewrite rewrite_by_lua* 运行环境。
---balancer balancer_by_lua_* 运行环境。
---access access_by_lua* 运行环境。
---content content_by_lua* 运行环境。
---header_filter header_filter_by_lua* 运行环境。
---body_filter body_filter_by_lua* 运行环境。
---log log_by_lua* 运行环境。
---timer ngx.timer.* 类的用户回调函数运行环境。
function ngx.get_phase()
end

---语法: ok, err = ngx.on_abort(callback)
---
---环境: rewrite_by_lua, access_by_lua*, content_by_lua**
---
---注册一个用户回调函数，当客户端过早关闭当前连接（下游）时自动调用。
---
---如果回掉函数注册成功返回 1 ，或反之将返回 nil 和一个错误描述字符信息。
---
---所有的 Nginx Lua 的 API 都可以在这个回调中使用，因为这个函数是以一个特定的 “轻线程” 方式运行，就像其他使用 ngx.thread.spawn 创建的 “轻线程”。
---
---该回调函数能自己决定对客户端终止事件做什么处理。例如，它可以简单的不做任何事情从而忽略这个事件 ，使得当前 Lua 请求处理可以没有任何打扰的继续执行。当然该回调函数也可以调用 ngx.exit 从而终止所有处理，例如：
---
--- local function my_cleanup()
---     --- custom cleanup work goes here, like cancelling a pending DB transaction
---
---     --- now abort all the "light threads" running in the current request handler
---     ngx.exit(499)
--- end
---
--- local ok, err = ngx.on_abort(my_cleanup)
--- if not ok then
---     ngx.log(ngx.ERR, "failed to register the on_abort callback: ", err)
---     ngx.exit(500)
--- end
---当 lua_check_client_abort 被设置为 off （这是默认值），这时这个函数调用将永远返回错误信息 “lua_check_client_abort is off” 。
---
---根据当前实现，这个函数在单个请求中能且只能调用一次；随后的调用将收到错误消息 “duplicate call” 。
---@param callback fun()
function ngx.on_abort(callback)
end

ngx.timer = {}
---语法: ok, err = ngx.timer.at(delay, callback, user_arg1, user_arg2, ...)
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---使用一个可选参数的用户回调函数，创建一个 Nginx 定时器。
---
---第一个参数 delay，指定这个定时器的延迟时间，秒为单位。我们可以指定带有小数部分的时间像0.001，这里代表 1 毫秒。当需要立即执行当前挂起的处理，指定延迟为0即可。
---
---第二个参数callback，可以是任何 Lua 函数，在指定的延迟时间之后，将会在一个后台的“轻线程”中被调用。这个调用是 Nginx 内核使用参数 premature，user_arg1， user_arg2等参数自动完成的，premature参数代表这个定时器是否过期的布尔值，user_arg1， user_arg2等其他参数是调用ngx.timer.at的其余参数。
---
---当 Nginx 工作进程正在尝试关闭时，定时器会过早失效，例如 HUP 信号触发的 Nginx 配置文件重载或 Nginx 服务关闭。当 Nginx 工作进程正在关闭，是不能调用 ngx.timer.at 来创建新的非零时间延迟定时器，这种情况下ngx.timer.at将返回nil和一个描述这个错误的字符串信息："process exiting"。
---
---从v0.9.3版本开始，当 Nginx 工作进程开始关闭时，是允许创建零延迟定时器的。
---
---当定时器到期，定时器中的 Lua 代码是在一个“请线程”中运行的，它与创造它的原始请求是完全分离的。因此，和创造它的请求有相同生命周期的对象，比如 cosockets，是不能在原始请求和定时器中的回调函数共享使用的。
---
---这是个简单的例子：
---
--- location / {
---     ...
---     log_by_lua '
---         local function push_data(premature, uri, args, status)
---             --- push the data uri, args, and status to the remote
---             --- via ngx.socket.tcp or ngx.socket.udp
---             --- (one may want to buffer the data in Lua a bit to
---             --- save I/O operations)
---         end
---         local ok, err = ngx.timer.at(0, push_data,
---                                      ngx.var.uri, ngx.var.args, ngx.header.status)
---         if not ok then
---             ngx.log(ngx.ERR, "failed to create timer: ", err)
---             return
---         end
---     ';
--- }
---我们可以创建反复循环使用的定时器，例如，得到一个每5秒触发一次的定时器，可以在定时器中递归调用ngx.timer.at。这里有个这样的例子：
---
--- local delay = 5
--- local handler
--- handler = function (premature)
---     --- do some routine job in Lua just like a cron job
---     if premature then
---         return
---     end
---     local ok, err = ngx.timer.at(delay, handler)
---     if not ok then
---         ngx.log(ngx.ERR, "failed to create the timer: ", err)
---         return
---     end
--- end
---
--- local ok, err = ngx.timer.at(delay, handler)
--- if not ok then
---     ngx.log(ngx.ERR, "failed to create the timer: ", err)
---     return
--- end
---因为定时调用是在后台运行，并且他们的执行不会增加任何客户端的响应时长，所以它们很容易让服务端累积错误并耗尽系统资源，
---有可能是 Lua 编程错误也可能仅仅是太多客户端请求。为了防止这种极端的恶果（例如： Nginx 服务崩溃），在 Nginx 工作进程里内建了 "pending timers" 和 "running timers" 两个数量限制。这里的 "pending timers" 代表还没有过期的定时器，"running timers" 代表用户回调函数当前正在运行的定时器。
---
---在 Nginx 进程内 "pending timers" 的最大数控制是 lua_max_pending_timers 指令完成的。 "running timers" 的最大数控制是 lua_max_running_timers 指令完成的。
---
---根据当前实现，每一个 "running timer" ，都将从全局连接列表中占用一个（假）连接，全局列表通过 nginx.conf 的标准指令 worker_connections 配置。所以要确保 worker_connections 指令设置了足够大的值，用来存放真正的连接和定时器需要假连接（受限于 lua_max_running_timers 指令）。
---
---在定时器的回调函数中，很多 Nginx 的 Lua API 是可用的，像数据流/数据报 cosocket 的 (ngx.socket.tcp 和 ngx.socket.udp)， 共享内存字典 (ngx.shared.DICT)， 用户协同程序 (coroutine.*)，用户 "轻线程" (ngx.thread.*)， ngx.exit， ngx.now/ngx.time，ngx.md5/ngx.sha1_bin， 都是允许的。但是子请求 API （如 ngx.location.capture)， ngx.req.* , 下游输出 API（如 ngx.say， ngx.print 和 ngx.flush）， 在这个环境是明确被禁用的。
---
---定时器的回调函数可传入大多数标准 Lua 值（空、布尔值、数字、字符串、表、闭包、文件句柄等），无论是明确的用户参数或回调闭包的隐式值。这里有几个例外，通过 coroutine.create 和 ngx.thread.spawn 的线程对象，或通过 ngx.socket.tcp、 ngx.socket.udp 和 ngx.req.socket 得到的 cosocket 对象，他们都是 不能 作为传入对象的，因为这些对象的生命周期都是绑定到创建定时器的请求环境的，但定时器回调与创建环境是完全隔离的（设计上），并且是在自己的（假）请求环境中运行。如果你尝试在创建请求边界共享线程或 cosocket 对象，你将得到错误信息 "no co ctx found"（对于线程），"bad request"（对于 cosockets）。它是好的，所以，在你的定时器回调中创建所有这些对象。
---@param delay number
---@param callback function
---@param user_arg1 any
function ngx.timer.at(delay,callback,user_arg1,user_arg2,...)
end

---语法: count = ngx.timer.running_count()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回当前 running timers 总数。
function ngx.timer.running_count()
end

---语法: count = ngx.timer.pending_count()
---
---环境: init_worker_by_lua*, set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, balancer_by_lua*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*, ssl_session_store_by_lua*
---
---返回待定 pending timers 数量。
function ngx.timer.pending_count()
end

ngx.config = {}
---语法: subsystem = ngx.config.subsystem
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*, init_worker_by_lua*
---
---该字段的值用来表明当前 Nginx 子系统的基础运行环境。例如该模块环境下，该字段的返回值永远为 "http" 字符串。对于 ngx_stream_lua_module ，无论如何，该字段返回值为 "stream" 。
ngx.config.subsystem = "http|stream"

---语法: debug = ngx.config.debug
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*, init_worker_by_lua*
---
---这个布尔值代表当前 Nginx 是否为调试版本，既，在编译时使用./configure的可选项---with-debug。
ngx.config.debug = false

---语法: prefix = ngx.config.prefix()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*, init_worker_by_lua*
---
---返回 Nginx 服务的 "prefix" 路径，它可能是由 Nginx 启动时通过可选 -p 命令行确定的，也可能是由编译 Nginx 的 ./configure 脚本中可选的 ---prefix 命令行参数确定的。
ngx.config.prefix = "/nginx/"

---语法: ver = ngx.config.nginx_version
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*, init_worker_by_lua*
---
---这个字段是当前正在使用的 Nginx 内核版本数字标识。例如，版本 1.4.3 用 Lua 数字表示就是 1004003 。
ngx.config.nginx_version = 1004003

---语法: str = ngx.config.nginx_configure()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*
---
---该 API 返回编译 Nginx 时的 ./configure 命令参数字符串。
function ngx.config.nginx_configure()
end

---语法: ver = ngx.config.ngx_lua_version
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*
---
---这个字段是当前正在使用的 ngx_lua 模块版本数字标识。例如，版本 0.9.3 用 Lua 数字表示就是 9003 。
ngx.config.ngx_lua_version = 9003

ngx.worker = {}
---语法: exiting = ngx.worker.exiting()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*, init_worker_by_lua*
---
---该函数返回一个布尔值，表示目前 Nginx 的工作进程是否已经开始退出。Nginx的工作进程退出，发生在 Nginx 服务退出或配置重载（又名HUP重载）。
---@return boolean
function ngx.worker.exiting()
end

---语法: pid = ngx.worker.pid()
---
---语法: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*, init_worker_by_lua*
---
---这个函数返回一个Lua数字，它是当前 Nginx 工作进程的进程 ID （PID）。这个 API 比 ngx.var.pid 更有效，ngx.var.VARIABLE API 不能使用的地方（例如 init_worker_by_lua），该 API 是可以的。
---@return number
function ngx.worker.pid()
end

---语法: count = ngx.worker.count()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*, init_worker_by_lua*
---
---返回当前 Nginx 工作进程数的数量（既：在 nginx.conf 配置中，使用 worker_processes 指令配置的值）。
---@return number
function ngx.worker.count()
end

---语法: count = ngx.worker.id()
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*, ngx.timer.*, init_by_lua*
---
---返回当前 Nginx 工作进程的一个顺序数字（从 0 开始）。
---
---所以，如果工作进程总数是 N，那么该方法将返回 0 和 N - 1 （包含）的一个数字。
---
---该方法只对 Nginx 1.9.1+ 版本返回有意义的值。更早版本的 nginx，将总是返回 nil 。
---
---同样可以看看 ngx.worker.count。
---@return number
function ngx.worker.id()
end

---语法: ngx.var.VAR_NAME
---
---环境: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*
---
---读写 Nginx 变量值。
---
--- value = ngx.var.some_nginx_variable_name
--- ngx.var.some_nginx_variable_name = value
---请注意，只有已经定义的 nginx 变量可以被写入。例如，
---
--- location /foo {
---     set $my_var ''; # 需要在设置时创建 $my_var 变量
---     content_by_lua_block {
---         ngx.var.my_var = 123;
---         ...
---     }
--- }
---也就是说，nginx 变量无法“随用随创建”。
---
---一些特殊的 nginx 变量，比如 $args 和 $limit_rate，可以被赋值，但许多其他的变量不能，包括 $query_string，$arg_PARAMETER，和 $http_NAME 等。
---
---Nginx 正则表达式捕获组变量 $1、$2、$3 等，也可以通过这个界面读取，方式为通过 ngx.var[1]、ngx.var[2]、ngx.var[3] 等。
---
---设置 ngx.var.Foo 为 nil 值将删除 Nginx 变量 $Foo。
---
--- ngx.var.args = nil
---注意 当从 Nginx 变量中读取值时，Nginx 将从基于请求的内存池中分配内存，只有在请求中止时才释放。所以如果用户的 Lua 代码中需要反复读取 Nginx 变量，请在用户程序的 Lua 变量中缓存，例如，
---
--- local val = ngx.var.some_var
--- --- 在后面反复使用变量 val
---以避免在当前请求周期内的 (临时) 内存泄露。另外一个缓存结果的方法是使用 ngx.ctx 表。
---
---未定义的 Nginx 变量会被认定为 nil ，而未初始化（但已定义）的 Nginx 变量会被认定为空 Lua 字符串。
---
---这个 API 需要进行相对“昂贵”的元方法调用，所以请避免高频使用。
ngx.var = {}

---处理query_string,什么是query_string:
---http://i.cnblogs.com/EditPosts.aspx?opt=1
---上面链接中的?后面的opt=1就是query_string,即url中？后面的都是
ngx.var.query_string = ""
---这个变量可以限制连接速率
ngx.var.limit_rate = 0
---如果$args设置，值为"?"，否则为""。
ngx.var.is_args = "?"
---请求头中的Content-length字段。
ngx.var.content_length = 0
---请求头中的Content-Type字段。
ngx.var.content_type = ""
---当前web应用数据使用的跟路径
ngx.var.document_root = ""
ngx.var.document_uri = ""
---域名
ngx.var.host = ""
---全域名,包含端口,也是请求头中的host字段
ngx.var.http_host = ""
---当前返回的状态码
ngx.var.status = 200
---HTTP请求方法 get/post
ngx.var.request_method = "GET"
---客户端ip
ngx.var.remote_addr = ""
---客户端端口
ngx.var.remote_port = 80
---二进制的客户端地址
ngx.var.binary_remote_addr = ""
---请求body
ngx.var.request_body = ""---指的就是从接受用户请求的第一个字节到发送完响应数据的时间，即包括接收请求数据时间、程序响应时间、输出响应数据时间
ngx.var.request_time = ""
---请求连接,不包含域名信息
ngx.var.uri = ""
---请求url包含参数 例如：”/cnphp/test.php?arg=freemouse”
ngx.var.request_uri = ""
---客户端的请求主体 此变量可在location中使用，将请求主体通过proxy_pass, fastcgi_pass, uwsgi_pass, 和 scgi_pass传递给下一级的代理服务器。
ngx.var.request_body = ""
---请求来源页面
ngx.var.http_referer = ""
---发出请求设备
ngx.var.http_user_agent = ""
---整个cookie内容
ngx.var.http_cookie = ""
---cookie NAME的值。
---使用 nginx 内核 $http_HEADER 变量，在读取单个请求头信息时更加适用
ngx.var.cookie_NAME = ""
---其他内容
ngx.var.body_bytes_sent = 0
---请求时间
ngx.var.time_local = 0
---url参数
ngx.var.args = {}
---具体的url参数
ngx.var.arg_KEY = ""
---请求协议http/https
ngx.var.scheme = "http"
---服务器名 www.cnphp.info
ngx.var.server_name = ""
---服务器地址
ngx.var.server_addr = ""
---服务器端口
ngx.var.server_port = 8080
---请求的长度 (包括请求的地址, http请求头和请求主体)
ngx.var.request_length = 0
---当前连接请求的文件路径，由root或alias指令与URI请求生成。
ngx.var.request_filename = ""
ngx.var.sent_http_name = 0
---负载均衡的地址
ngx.var.upstream_addr = ""
---负载均衡返回的状态
ngx.var.upstream_status = 20
---是指从Nginx向后端（php-cgi)建立连接开始到接受完数据然后关闭连接为止的时间。
ngx.var.upstream_response_time = 0

---ngx.null 常量是一个 NULL 的 轻量用户数据 ，一般被用来表达 Lua table 等里面的 nil (空) 值
---类似于 lua-cjson 库中的 cjson.null 常量。在v0.5.0rc5 版本中首次引入这个常量。
---ngx.null 常量输出为 "null" 字符串
ngx.null = "null"

ngx.socket = {}
---语法: tcpsock = ngx.socket.tcp()
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---创建并得到一个 TCP 或 unix 域流式 socket 对象（也被称为 "cosocket" 对象的一种类型）。
---
---不仅完整兼容 LuaSocket 库的 TCP API，而且还是 100% 非阻塞的。此外，我们引入了一些新的API，提供更多功能。
---
---通过该 API 函数创建的 cosocket 对象，与创造它的 Lua 环境拥有相同的生命周期。所以永远不要把
---cosocket 对象传递给其他 Lua 环境（包括 ngx.timer 回调函数），并且永远不要在两个不同的 Nginx 请求之间共享 cosocket 对象。
---
---对于任何一个 cosocket 对象的底层连接，如果你没有显式关闭（通过 close）或把它放到连接池中（通过 setkeepalive），
---一旦下面的的两个事件中任何一个发生，它将被自动关闭：
---
---当前请求处理执行完毕
---Lua cosocket 对象被 Lua GC（垃圾回收机制）回收
---进行 cosocket 操作时发生致命错误总是会自动关闭当前连接（注意，读超时是这里唯一的非致命错误），
---并且如果你对一个已经关闭的连接调用 close ，你将得到 "closed" 的错误信息。
---从 0.9.9 版本开始，cosocket 对象是全双工的，也就是说，一个专门读取的 "light thread"，
---一个专门写入的 "light thread"，它们可以同时对同一个 cosocket 对象进行操作（两个 "light threads" 必须运行在同一个 Lua 环境中，原因见上）。
---但是你不能让两个 "light threads" 对同一个 cosocket 对象都进行读（或者写入、或者连接）操作，否则当调用 cosocket 对象时，
---你将得到一个类似 "socket busy reading" 的错误。
---@return ngx.tcpsock
function ngx.socket.tcp()
end

---语法: tcpsock, err = ngx.socket.connect(host, port)
---
---语法: tcpsock, err = ngx.socket.connect("unix:/path/to/unix-domain.socket")
---
---环境: rewrite_by_lua, access_by_lua*, content_by_lua*, ngx.timer.**
---
---该函数是融合 ngx.socket.tcp() 和 connect() 方法到一个单独操作的快捷方式。 它实际上可以这样实现：
---
--- local sock = ngx.socket.tcp()
--- local ok, err = sock:connect(...)
--- if not ok then
---     return nil, err
--- end
--- return sock
---这里没办法使用 settimeout 方法来指定连接时间，只能通过指令 lua_socket_connect_timeout 预先配置作为替代方案。
---@return ngx.tcpsock,string @创建的连接,错误消息
function ngx.socket.connect(ip_host,port)
end

---@class ngx.tcpsock
local tcpsock = {}

---语法: ok, err = tcpsock:connect(host, port, options_table?)
---语法: ok, err = tcpsock:connect("unix:/path/to/unix-domain.socket", options_table?)
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---尝试以非阻塞的方式，对远端服务或 unix domain socket 文件建立 TCP socket 对象。
---在真正解析主机名并连接到后端服务之前，该方法将永远优先在连接池内（都是调用该方法或 ngx.socket.connect 函数的连接）查找符合条件的空闲连接。
---
---对 host 参数 IP 地址和域名在这里都是可以使用的。当使用域名时，
---该方法将使用 Nginx 内部的动态域名解析器（非阻塞并且需要在 nginx.conf 文件中配置 resolver 指令），例如：
---
--- resolver 8.8.8.8;  # 使用 Google 的公用域名解析服务器
---如果域名服务器对这个主机名返回多个 IP 地址，该方法将从中随机挑选一个。
---
---错误情况下，该方法返回 nil 及错误描述信息。成功情况下，该方法返回 1 。
---
---这里是个连接到 TCP 服务的示例：
---
--- location /test {
---     resolver 8.8.8.8;
---
---     content_by_lua_block {
---         local sock = ngx.socket.tcp()
---         local ok, err = sock:connect("www.google.com", 80)
---         if not ok then
---             ngx.say("failed to connect to google: ", err)
---             return
---         end
---         ngx.say("successfully connected to google!")
---         sock:close()
---     }
--- }
---连接到 Unix Domain Socket 文件也是可能的：
---
--- local sock = ngx.socket.tcp()
--- local ok, err = sock:connect("unix:/tmp/memcached.sock")
--- if not ok then
---     ngx.say("failed to connect to the memcached unix domain socket: ", err)
---     return
--- end
---假设 memcached （或其他服务）正在 Unix Domain Socket 文件 /tmp/memcached.sock 监听。
---
---连接操作超时控制，是由 lua_socket_connect_timeout 配置指令和 settimeout 方法设置的。而后者有更高的优先级，例如：
---
--- local sock = ngx.socket.tcp()
--- sock:settimeout(1000)  --- one second timeout
--- local ok, err = sock:connect(host, port)
---调用这个方法 之前 调用 settimeout 方法设置超时时间，是非常重要的。
---
---对已经连接状态的 socket 对象再次调用该方法，将导致原本的连接首先被关闭。
---
---对于该方法的最后一个参数是个可选的 Lua 表，用来指定各种连接选项：
---
---pool 对即将被使用的连接池指定一个名字。如果没有指定该参数，连接池的名字将自动生成，使用 "<host>:<port>" 或 "<unix-socket-path>" 的命名方式。
---@param options_table table|void @可选选项配置
---@return boolean,string @ok,err @连接结果,错误消息
function tcpsock:connect(ip_host,port,options_table)
end

---语法: session, err = tcpsock:sslhandshake(reused_session?, server_name?, ssl_verify?)
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---对当前建立的连接上完成 SSL/TLS 握手。
---
---可选参数 reused_session 可以是一个前任 SSL session 用户数据，是由访问同一个目的地的前一个 sslhandshake 调用返回的。对于短链接，
---重复使用 SSL session 通常可以加速握手速度，但对于开启连接池情况情况下不是很有用。该参数默认使用 nil 。如果该参数使用布尔值 false，
---将不返回 SSL 会话用户数据，只返回一个 Lua 布尔值；其他情况下，成功时第一个参数将返回当前的 SSL session。
---
---可选参数 server_name 被用来指名新的 TLS 扩展 Server Name Indication (SNI) 的服务名。使用 SNI 可以使得在服务端不同的服务可以共享同一个 IP 地址。
---同样，当 SSL 验证启用，参数 server_name 也被用来验证从远端服务端发送出来的证书中的服务名。
---
---可选参数 ssl_verify ，通过一个 Lua 布尔值来控制是否启用 SSL 验证。当设置为 true 时，
---服务证书将根据 lua_ssl_trusted_certificate 指令指定的 CA 证书进行验证。你可能需要调整 lua_ssl_verify_depth
---指令来控制我们对证书链的验证深度。同样，当 ssl_verify 参数为 true 并且也指名了 server_name ，在后面服务端证书中将被用来验证服务名。
---@param reused_session string|nil @session|void @前任ssl session
---@param server_name string|void @SNI服务名
---@param ssl_verify boolean|void @是否验证证书
---@return boolean|string,string @session, err @连接结果,错误消息
function tcpsock:sslhandshake(reused_session,server_name,ssl_verify)
end

---语法: bytes, err = tcpsock:send(data)
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---在当前 TCP 或 Unix Domain Socket 连接上非阻塞的发送数据。
---该方法是个同步操作，直到 所有 的数据全部被刷写到系统 socket 发送缓冲区或有错误发生，否则不会返回。
---成功情况下，返回已经发送数据字节数的总数。其他情况，返回 nil 和错误描述信息。
---输入参数 data 可以是 Lua 字符串，也可以是包含字符串的（嵌套）Lua 表。对于输入参数是表的情况，
---该方法将逐一拷贝所有的字符串对象到底层的 Nginx socket 发送缓冲区，这是比 Lua 层面完成字符串拼接更好的优化方案。
---
---发送超时控制，是由 lua_socket_send_timeout 配置指令和 settimeout 方法设置的。而后者有更高的优先级，例如：
---
--- sock:settimeout(1000)  --- one second timeout
--- local bytes, err = sock:send(request)
---调用这个方法 之前 调用 settimeout 方法设置超时时间，是非常重要的。
---
---一旦有任何错误发生，该方法将自动关闭当前连接。
---@param data string|table[] @发送的数据,可以是一个数组类型的table
---@return number,string @bytes, err @发送数据字节总数,失败nil,错误消息
function tcpsock:send(data)
end

---语法: data, err, partial = tcpsock:receive(size)
---语法: data, err, partial = tcpsock:receive(pattern?)
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---根据读取规则或大小，从当前连接 socket 中接收数据。
---与 send 方法一样是同步操作，并且 100% 非阻塞。
---成功情况下，返回接收到的数据；失败情况，返回 nil 、一个错误描述信息以及目前接收到的部分数据。
---如果指定一个像数字的参数（里面是数字的字符串），它将解析为大小。该方法将不回返回直到读取明确大小的数据或有错误发生。
---如果一个不像数字的字符串参数被指定，它将解析为“规则”。支持下面的规则：
---
---'*a'：从 socket 中读取内容直到连接被关闭。这里是不执行 end-of-line 翻译。
---'*l'：从 socket 中读取一行文本信息。行结束符是 Line Feed （LF） 字符（ASCII 10），
---前面是一个可选 Carriage Return （CR）字符（ASCII 13）。返回行信息中不包含 CR 和 LF 字符。实际上，所有的 CR 字符在此规则中都是被忽略的。
---如果没有参数指定，它将被假定为规则 '*l' ，也就是说，使用按行读取的规则。
---
---读操作超时控制，是由 lua_socket_read_timeout 配置指令和 settimeout 方法设置的。而后者有更高的优先级，例如：
---
--- sock:settimeout(1000)  --- one second timeout
--- local line, err, partial = sock:receive()
--- if not line then
---     ngx.say("failed to read a line: ", err)
---     return
--- end
--- ngx.say("successfully read a line: ", line)
---调用这个方法 之前 调用 settimeout 方法设置超时时间，是非常重要的。
---
---自从 v0.8.8 版本，当出现读取超时错误时，该方法不再自动关闭当前连接。对于其他连接错误，该方法总是会自动关闭连接。
---@param size number|string @数字参数将字节读取数字大小字符,也可以是*a全部 *l一行,默认是*l
---@return string,string @data, err, partial @接受到的数据,失败为nil,错误消息,已经接受到的部分数据
function tcpsock:receive(size)
end

---语法: iterator = tcpsock:receiveuntil(pattern, options?)
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---该方法返回一个迭代的 Lua 函数，该函数可以被调用读取数据流直到指定的规则或有错误发生。
---这里有个例子，使用这个方法读取边界序列为 ---abcedhb 数据流：
---
--- local reader = sock:receiveuntil("\r\n---abcedhb")
--- local data, err, partial = reader()
--- if not data then
---     ngx.say("failed to read the data stream: ", err)
--- end
--- ngx.say("read the data stream: ", data)
---当不使用任何参数调用时，迭代函数返回的接收数据是指定规则 之前 的输入数据流。所以对于上面的例子，如果输入数据流是 'hello, world! -agentzh\r\n---abcedhb blah blah'
---，然后将返回字符串 'hello, world! -agentzh' 。
---
---错误的情况下，迭代函数将返回 nil 、错误描述信息以及已经读取到的部分数据内容。
---
---迭代函数可以被多次调用，并且可以安全的与其他 cosocket 方法或其他迭代函数混合调用。
---
---当这个迭代函数使用 size 参数时的行为有点不同（比如，真正的迭代）。就是说，每次调用它将读取 size 大小的数据，最后一次调用
---（无论找到边界规则或遇到错误）将返回 nil 。该迭代函数的最后一次成功调用， err 的返回值也将是 nil 。在最后一次成功调用
---（返回数据 nil，错误信息 nil）之后，该迭代函数将会被重置。细看下面的例子：
---
--- local reader = sock:receiveuntil("\r\n---abcedhb")
---
--- while true do
---     local data, err, partial = reader(4)
---     if not data then
---         if err then
---             ngx.say("failed to read the data stream: ", err)
---             break
---         end
---
---         ngx.say("read done")
---         break
---     end
---     ngx.say("read chunk: [", data, "]")
--- end
---对于输入数据是 'hello, world! -agentzh\r\n---abcedhb blah blah' ，使用上面的示例代码我们将得到下面输出：
---
---read chunk: [hell]
---read chunk: [o, w]
---read chunk: [orld]
---read chunk: [! -a]
---read chunk: [gent]
---read chunk: [zh]
---read done
---注意，当边界规则对数据流解析有歧义时，实际返回数据长度 可能 会略大于 size 参数指定的大小限制。在数据流的边界，返回的字符数据长度同样也可能小于 size 参数限制。
---
---迭代函数的读操作超时控制，是由 lua_socket_read_timeout 指令配置和 settimeout 方法设置的。而后者有更高的优先级，例如：
---
--- local readline = sock:receiveuntil("\r\n")
---
--- sock:settimeout(1000)  --- one second timeout
--- line, err, partial = readline()
--- if not line then
---     ngx.say("failed to read a line: ", err)
---     return
--- end
--- ngx.say("successfully read a line: ", line)
---在调用迭代函数（注意 receiveuntil 调用在这里是不相干的） 之前 调用 settimeout 方法是非常重要的。
---
---从 v0.5.1 版本开始，该方法接收一个可选的 options 表参数来控制一些行为。支持下面这些选项：
---
---inclusive
---inclusive 用一个布尔值来控制返回数据串是否包含规则字符串，默认是 false。例如：
---
--- local reader = tcpsock:receiveuntil("_END_", { inclusive = true })
--- local data = reader()
--- ngx.say(data)
---然后对于数据数据流 "hello world _END_ blah blah blah" ，根据上面的示例代码将得到 hello world _END_ 的输出，包含规则字符串 _END_ 自身。
---@return fun(number) @迭代的 Lua 函数，该函数可以被调用读取数据流直到指定的规则或有错误发生 local data, err, partial = reader()
function tcpsock:receiveuntil(pattern,options)
end

---语法: ok, err = tcpsock:close()
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---关闭当前 TCP 或 unix domain socket 。成功情况下返回 1 ，否则将返回 nil 和 错误描述信息。
---
---注意，调用了 setkeepalive 方法的 socket 对象，不再需要调用这个方法，因为这个 socket 对象已经关闭（当前连接已经保存到内建的连接池内）。
---
---当 socket 对象已经被 Lua GC（垃圾回收）或当前客户 HTTP 请求完成处理时，没有调用这个方法的 socket 对象（和其他关联连接）将会被关闭。
---@return boolean,string @ok, err @成功与否,错误消息
function tcpsock:close()
end

---语法: tcpsock:settimeout(time)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---对 connect、receive、 基于 receiveuntil 迭代返回，设置随后的 socket 操作的超时时间（毫秒为单位）。
---
---通过该方法设置内容相比这些配置指令有更高的优先级，例如：lua_socket_connect_timeout、 lua_socket_send_timeout、 lua_socket_read_timeout。
---
---注意，该方法 不 会对 lua_socket_keepalive_timeout 有任何影响，这个目的应换用 setkeepalive 的 timeout 参数。
---@param time number @设置连接和读取数据车超时时间,单位毫秒
---@return void
function tcpsock:settimeout(time)
end

---syntax: tcpsock:settimeouts(connect_timeout, send_timeout, read_timeout)
---
---context: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---设置连接超时阈值、发送超时阈值和读取超时阈值，以毫秒为单位控制随后的 socket 操作（connect， send， receive 和 receiveuntil 方法返回的迭代操作 ）。
---
---通过该方法设置定的值，相比这些配置指令有更高的优先级，比如：lua_socket_connect_timeout、lua_socket_send_timeout 和 lua_socket_read_timeout。
---
---推荐使用 settimeouts 方法替代 settimeout 。
---
---注意：该方法 不 影响 lua_socket_keepalive_timeout 设定，这种情况应调用 setkeepalive 方法完成目的。
function tcpsock:settimeouts(connect_timeout,send_timeout,read_timeout)
end

---语法: tcpsock:setoption(option, value?)
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---该函数是为兼容 LuaSocket API，目前没做任何事情。它的功能将在将来实现。
---
---该特性是在 v0.5.0rc1 版本首次引入的。
function tcpsock:setoption(option,value)
end

---语法: ok, err = tcpsock:setkeepalive(timeout?, size?)
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---把当前 socket 连接立即放到内建的 cosocket 连接池中，维持活动状态直到被其他 connect 方法调用请求，或者达到自身绑定的最大空闲时间后连接过期。
---
---第一个可选参数参数 timeout ，可以用来指定当前连接的最大空闲时间（单位毫秒）。如果没指定该参数，
---将使用配置在 lua_socket_keepalive_timeout 指令的值作为默认值使用。如果给定的值是 0 ，那么超时时间是没有限制的。
---
---第二个参数 size，可以用来指定当前服务（例如，当前主机+端口配对或 unix socket 文件路径作为标识）在连接池中允许存放的最大连接数。
---注意，连接池大小一旦创建后，是不能被修改的。如果没指定该参数，将使用配置在 lua_socket_pool_size 指令的值作为默认值使用。
---
---当连接池中连接数超过限制大小，在连接池中最近最少使用的（空闲）连接将被关闭，给当前连接腾挪空间。
---
---注意，cosocket 连接池是每个 Nginx 工作进程使用的，而不是每个 Nginx 服务实例，所以这里指定的限制也只能在每个独立的 nginx 工作进程上生效。
---
---连接池中空闲连接的任何异常事件都将会被监控，例如连接终止、在线收到非预期数据，在这种情况下有问题的连接，将被关闭并从池子中移除。
---
---成功情况，该方法返回 1；否则，将返回 nil 和错误描述字符信息。
---
---对于当前连接，当系统接收缓冲区有未读取完的数据，这时该方法将返回 "connection in dubious state" 的错误信息（作为第二个返回值），
---因为前一个请求留下了一些未读取数据给下一个请求，这种连接被重用是不安全的。
---
---该方法也可以让当前 cosocket 对象进入 closed 状态，所以这里不再需要事后手工调用 close 方法。
---@param timeout number @毫秒单位的空闲时间设定,0为无限
---@param size number|void @连接池大小
---@return boolean,string @ok, err @设置结果,错误消息
function tcpsock:setkeepalive(timeout,size)
end

---语法: count, err = tcpsock:getreusedtimes()
---
---环境: rewrite_by_lua*, access_by_lua*, content_by_lua*, ngx.timer.*, ssl_certificate_by_lua*, ssl_session_fetch_by_lua*
---
---该方法返回当前连接的使用次数（调用成功）。失败时，返回nil和错误描述字符信息。
---
---如果当前连接不是从内建连接池中获取的，该方法总是返回 0 ，也就是说，该连接还没有被使用过。如果连接来自连接池，
---那么返回值永远都是非零。所以这个方法可以用来确认当前连接是否来自池子。
---@return number,string @count, err @连接使用次数,错误消息
function tcpsock:getreusedtimes()
end

---@language JSON
local json_text = [[{
    "name":"Emmy"
}]]

---@class cjson
cjson = {}

---解码为table,cjson.decode will deserialise any UTF-8 JSON string into a Lua value or table.
---
---UTF-16 and UTF-32 JSON strings are not supported.
---
---cjson.decode requires that any NULL (ASCII 0) and double quote (ASCII 34) characters are escaped within strings.
---All escape codes will be decoded and other bytes will be passed transparently.
---UTF-8 characters are not validated during decoding and should be checked elsewhere if required.
---
---JSON null will be converted to a NULL lightuserdata value. This can be compared with cjson.null for convenience.
---
---By default, numbers incompatible with the JSON specification (infinity, NaN, hexadecimal) can be decoded.
---This default can be changed with cjson.decode_invalid_numbers.
---json字符串解码为luatable
---@return table
function cjson.decode(json_text)
end

---配置,解码无效数字decode_invalid_numbers
---setting = cjson.decode_invalid_numbers([setting])
---- "setting" must be a boolean. Default: true.
---Lua CJSON may generate an error when trying to decode numbers not supported by the JSON specification. Invalid numbers are defined as:
---无穷的infinity
---非数字not-a-number (NaN)
---16进制hexadecimal
---
---可选设置Available settings:
---true
---接受和解码,默认.Accept and decode invalid numbers. This is the default setting.
---false
---遇到就抛错,Throw an error when invalid numbers are encountered.
---返回,当前设置,The current setting is always returned, and is only updated when an argument is provided.
---@param setting boolean
function cjson.decode_invalid_numbers(setting)
end

---decode_max_depth
---depth = cjson.decode_max_depth([depth])
---- "depth" must be a positive integer. Default: 1000.
---配置,最大嵌套深度,Lua CJSON will generate an error when parsing deeply nested JSON once the maximum array/object depth has been exceeded. This check prevents unnecessarily complicated JSON from slowing down the application, or crashing the application due to lack of process stack space.
---
---An error may be generated before the depth limit is hit if Lua is unable to allocate more objects on the Lua stack.
---
---By default, Lua CJSON will reject JSON with arrays and/or objects nested more than 1000 levels deep.
---
---The current setting is always returned, and is only updated when an argument is provided.
---@param depth number
function cjson.decode_max_depth(depth)
end

---json_text = cjson.encode(value)
---编码table为json字符串,cjson.encode will serialise a Lua value into a string containing the JSON representation.
---支持类型,cjson.encode supports the following types:
---boolean
---lightuserdata (NULL value only)
---nil
---number
---string
---table
---其余的会报错,The remaining Lua types will generate an error:
---function
---lightuserdata (non-NULL values)
---thread
---userdata
---By default, numbers are encoded with 14 significant digits. Refer to cjson.encode_number_precision for details.
---
---Lua CJSON will escape the following characters within each UTF-8 string:
---
---Control characters (ASCII 0 - 31)
---
---Double quote (ASCII 34)
---
---Forward slash (ASCII 47)
---
---Blackslash (ASCII 92)
---
---Delete (ASCII 127)
---
---All other bytes are passed transparently.
---
---Caution
---Lua CJSON will successfully encode/decode binary strings, but this is technically not supported by JSON and may not be compatible with other JSON libraries. To ensure the output is valid JSON, applications should ensure all Lua strings passed to cjson.encode are UTF-8.
---
---Base64 is commonly used to encode binary data as the most efficient encoding under UTF-8 can only reduce the encoded size by a further ~8%. Lua Base64 routines can be found in the LuaSocket and lbase64 packages.
---
---Lua CJSON uses a heuristic to determine whether to encode a Lua table as a JSON array or an object. A Lua table with only positive integer keys of type number will be encoded as a JSON array. All other tables will be encoded as a JSON object.
---
---Lua CJSON does not use metamethods when serialising tables.
---
---rawget is used to iterate over Lua arrays
---
---next is used to iterate over Lua objects
---
---Lua arrays with missing entries (sparse arrays) may optionally be encoded in several different ways. Refer to cjson.encode_sparse_array for details.
---
---JSON object keys are always strings. Hence cjson.encode only supports table keys which are type number or string. All other types will generate an error.
---
---Note
---Standards compliant JSON must be encapsulated in either an object ({}) or an array ([]). If strictly standards compliant JSON is desired, a table must be passed to cjson.encode.
---By default, encoding the following Lua values will generate errors:
---
---Numbers incompatible with the JSON specification (infinity, NaN)
---
---Tables nested more than 1000 levels deep
---
---Excessively sparse Lua arrays
---
---These defaults can be changed with:
---
---cjson.encode_invalid_numbers
---
---cjson.encode_max_depth
---
---cjson.encode_sparse_array
---
---Example: Encoding
---value = { true, { foo = "bar" } }
---json_text = cjson.encode(value)
---- Returns: '[true,{"foo":"bar"}]'
---table编码为json字符串
---@param value table
---@return string @json_text
function cjson.encode(value)
end

---setting = cjson.encode_invalid_numbers([setting])
---- "setting" must a boolean or "null". Default: false.
---Lua CJSON may generate an error when encoding floating point numbers not supported by the JSON specification (invalid numbers):
---
---infinity
---
---not-a-number (NaN)
---
---Available settings:
---
---true
---Allow invalid numbers to be encoded. This will generate non-standard JSON, but this output is supported by some libraries.
---
---"null"
---Encode invalid numbers as a JSON null value. This allows infinity and NaN to be encoded into valid JSON.
---
---false
---Throw an error when attempting to encode invalid numbers. This is the default setting.
---
---The current setting is always returned, and is only updated when an argument is provided.
---配置,编码无效数字
function cjson.encode_invalid_numbers(setting)
end

---keep = cjson.encode_keep_buffer([keep])
---- "keep" must be a boolean. Default: true.
---Lua CJSON can reuse the JSON encoding buffer to improve performance.
---
---Available settings:
---
---true
---The buffer will grow to the largest size required and is not freed until the Lua CJSON module is garbage collected. This is the default setting.
---
---false
---Free the encode buffer after each call to cjson.encode.
---
---The current setting is always returned, and is only updated when an argument is provided.
---配置,编码重用缓冲区
function cjson.encode_keep_buffer(keep)
end

---depth = cjson.encode_max_depth([depth])
---- "depth" must be a positive integer. Default: 1000.
---Once the maximum table depth has been exceeded Lua CJSON will generate an error. This prevents a deeply nested or recursive data structure from crashing the application.
---
---By default, Lua CJSON will generate an error when trying to encode data structures with more than 1000 nested tables.
---
---The current setting is always returned, and is only updated when an argument is provided.
---配置,编码最大深度
function cjson.encode_max_depth(depth)
end

---precision = cjson.encode_number_precision([precision])
---- "precision" must be an integer between 1 and 14. Default: 14.
---The amount of significant digits returned by Lua CJSON when encoding numbers can be changed to balance accuracy versus performance.
---For data structures containing many numbers, setting cjson.encode_number_precision to a smaller integer,
---for example 3, can improve encoding performance by up to 50%.
---
---By default, Lua CJSON will output 14 significant digits when converting a number to text.
---
---The current setting is always returned, and is only updated when an argument is provided.
---配置,编码最大位数,默认14
function cjson.encode_number_precision(precision)
end

---convert, ratio, safe = cjson.encode_sparse_array([convert[, ratio[, safe]]])
---- "convert" must be a boolean. Default: false.
---- "ratio" must be a positive integer. Default: 2.
---- "safe" must be a positive integer. Default: 10.
---Lua CJSON classifies a Lua table into one of three kinds when encoding a JSON array.
---This is determined by the number of values missing from the Lua array as follows:
---Normal
---All values are available.
---Sparse
---At least 1 value is missing.
---Excessively sparse
---The number of values missing exceeds the configured ratio.
---Lua CJSON encodes sparse Lua arrays as JSON arrays using JSON null for the missing entries.
---An array is excessively sparse when all the following conditions are met:
---ratio > 0
---maximum_index > safe
---maximum_index > item_count * ratio
---Lua CJSON will never consider an array to be excessively sparse when ratio = 0.
---The safe limit ensures that small Lua arrays are always encoded as sparse arrays.
---By default, attempting to encode an excessively sparse array will generate an error.
---If convert is set to true, excessively sparse arrays will be converted to a JSON object.
---The current settings are always returned. A particular setting is only changed when the argument is provided (non-nil).
---Example: Encoding a sparse array
---cjson.encode({ [3] = "data" })
---- Returns: '[null,null,"data"]'
---Example: Enabling conversion to a JSON object
---cjson.encode_sparse_array(true)
---cjson.encode({ [1000] = "excessively sparse" })
---- Returns: '{"1000":"excessively sparse"}'
---配置,编码稀疏数组设置
function cjson.encode_sparse_array(convert,ratio,safe)
end



---This fork of mpx/lua-cjson is included in the OpenResty bundle and includes a few bugfixes and improvements,
---especially to facilitate the encoding of empty tables as JSON Arrays.
---
---Please refer to the lua-cjson documentation for standard usage, this README only provides informations regarding this fork's additions.
---
---See mpx/master..openresty/master for the complete history of changes.

---syntax: cjson.encode_empty_table_as_object(true|false|"on"|"off")
---
---Change the default behavior when encoding an empty Lua table.
---
---By default, empty Lua tables are encoded as empty JSON Objects ({}). If this is set to false, empty Lua tables will be encoded as empty JSON Arrays instead ([]).
---
---This method either accepts a boolean or a string ("on", "off").
---配置,编码空table的行为 false=[] true={},默认
function cjson.encode_empty_table_as_object(setting)
end

---syntax: cjson.empty_array
---
---设置一个值,json编码为一个[]
---A lightuserdata, similar to cjson.null, which will be encoded as an empty JSON Array by cjson.encode().
---
---For example, since encode_empty_table_as_object is true by default:
---
---local cjson = require "cjson"
---
---local json = cjson.encode({
---    foo = "bar",
---    some_object = {},
---    some_array = cjson.empty_array
---})
---This will generate:
---
---{
---    "foo": "bar",
---    "some_object": {},
---    "some_array": []
---}
cjson.empty_array = 0

---syntax: setmetatable({}, cjson.array_mt)
---
---When lua-cjson encodes a table with this metatable, it will systematically encode it as a JSON Array. The resulting,
---encoded Array will contain the array part of the table, and will be of the same length as the # operator on that table.
---Holes in the table will be encoded with the null JSON value.
---
---Example:
---
---local t = { "hello", "world" }
---setmetatable(t, cjson.array_mt)
---cjson.encode(t) --- ["hello","world"]
---Or:
---
---local t = {}
---t[1] = "one"
---t[2] = "two"
---t[4] = "three"
---t.foo = "bar"
---setmetatable(t, cjson.array_mt)
---cjson.encode(t) --- ["one","two",null,"three"]
---This value was introduced in the 2.1.0.5 release of this module.
---编码稀疏数组的元表
cjson.array_mt = {}

---syntax: setmetatable({}, cjson.empty_array_mt)
---A metatable which can "tag" a table as a JSON Array in case it is empty
---(that is, if the table has no elements, cjson.encode() will encode it as an empty JSON Array).
---编码空table为[]的元表
cjson.empty_array_mt = {}

---4.1. _NAME
---The name of the Lua CJSON module ("cjson").
cjson._NAME = "cjson"

---4.2. _VERSION
---The version number of the Lua CJSON module ("2.1.0").
cjson._VERSION = "2.1.0"

---4.3. null
---Lua CJSON decodes JSON null as a Lua lightuserdata NULL pointer. cjson.null is provided for comparison.
cjson.null = nil

