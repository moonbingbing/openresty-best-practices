# 定时任务
在[请求返回后继续执行](/ngx_lua//ngx_lua/timer.md)章节中，我们介绍了一种实现的方法，这里我们
介绍一种更优雅更通用的方法：[ngx.timer.at()](http://wiki.nginx.org/HttpLuaModule#ngx.timer.at)。
这个函数是在后台用nginx轻线程（light thread），在指定的延时，调用指定的函数。
有了这种机制，ngx_lua的功能得到了非常大的扩展，我们有机会做一些更有想象力的功能出来。比如
批量提交、定期任务、 
