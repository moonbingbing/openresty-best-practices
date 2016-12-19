# 定时任务

在[请求返回后继续执行](../ngx_lua/continue_after_eof.md)章节中，我们介绍了一种实现的方法，这里我们
介绍一种更优雅更通用的方法：[ngx.timer.at()](https://github.com/openresty/lua-nginx-module#ngxtimerat)。
这个函数是在后台用nginx轻线程（light thread），在指定的延时后，调用指定的函数。
有了这种机制，ngx_lua的功能得到了非常大的扩展，我们有机会做一些更有想象力的功能出来。比如
批量提交和cron任务。

需要特别注意的是：有一些ngx_lua的API不能在这里调用，比如子请求、ngx.req.\*和向下游输出的API(ngx.print、ngx.flush之类)，原因是这些请求都需要绑定某个请求，但是对于 `ngx.timer.at` 自身的运行，是与当前任何请求都没关系的。

比较典型的用法，如下示例：

```lua
 local delay = 5
 local handler
 handler = function (premature)
     -- do some routine job in Lua just like a cron job
     if premature then
         return
     end
     local ok, err = ngx.timer.at(delay, handler)
     if not ok then
         ngx.log(ngx.ERR, "failed to create the timer: ", err)
         return
     end
 end

 local ok, err = ngx.timer.at(delay, handler)
 if not ok then
     ngx.log(ngx.ERR, "failed to create the timer: ", err)
     return
 end
```
