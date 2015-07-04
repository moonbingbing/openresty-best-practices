# 请求返回后继续执行

在一些请求中，我们会做一些日志的推送、用户数据的统计等和返回给终端数据无关的操作。而这些操作，即使你用异步非阻塞多方式，在终端看来，也是会影响速度的。这个和我们的原则：***终端请求，需要用最快的速度返回给终端***，是冲突的。

这时候，最理想的是，获取完给终端返回的数据后，就断开连接，后面的日志和统计等动作，在断开连接后，后台继续完成即可。

怎么做到呢？还是看下代码吧：

```lua
local response, user_stat = logic_func.get_response(request)
ngx.say(response)
ngx.eof()

if user_stat then
   local ret = db_redis.update_user_data(user_stat)
end
```
没错，最关键的一行代码就是[ngx.eof()](http://wiki.nginx.org/HttpLuaModule#ngx.eof)， 它可以即时关闭连接，把数据返回给终端，后面的数据库操作还会运行。比如上面代码中的
```lua
local response, user_stat = logic_func.get_response(request)
```
运行了0.1秒，而
```lua
db_redis.update_user_data(user_stat)
```
运行了0.2秒，在没有使用ngx.eof()之前，终端感知到的是0.3秒，而加上ngx.eof()之后，终端感知到的只有0.1秒。

但是，需要注意的是，***你不能任性的把阻塞的操作加入代码，即使在ngx.eof()之后。***虽然已经返回了终端的请求，但是，nginx的worker还在被你占用。如果你加入了阻塞的代码，nginx的高并发就是空谈。
