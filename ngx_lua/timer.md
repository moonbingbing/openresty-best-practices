# 定时任务

在[请求返回后继续执行](/ngx_lua//ngx_lua/timer.md)章节中，我们介绍了一种实现的方法，这里我们
介绍一种更优雅更通用的方法：[ngx.timer.at()](http://wiki.nginx.org/HttpLuaModule#ngx.timer.at)。
这个函数是在后台用nginx轻线程（light thread），在指定的延时后，调用指定的函数。
有了这种机制，ngx_lua的功能得到了非常大的扩展，我们有机会做一些更有想象力的功能出来。比如
批量提交和cron任务。

需要特别注意的是：有一些ngx_lua的API不能在这里调用，比如子请求、ngx.req.\*和向下游输出的API(ngx.print、ngx.flush之类)。
