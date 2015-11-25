# 调试
调试是一个程序猿非常重要的能力，人写的程序总会有bug，所以需要debug。***如何方便和快速的定位bug***，是我们讨论的重点，只要bug能定位，解决就不是问题。

对于熟悉用Visual Studio和Eclipse这些强大的集成开发环境的来做C++和Java的同学来说，OpenResty的debug要原始很多，但是对于习惯Python开发的同学来说，又是那么的熟悉。
张银奎有本[《软件调试》](http://book.douban.com/subject/3088353/)的书，windows客户端程序猿应该都看过，大家可以去试读下，看看里面有多复杂:(

对于OpenResty，坏消息是，没有单步调试这些玩意儿（我们尝试搞出来过ngx Lua的单步调试，但是没人用...）;好消息是，它像Python一样，非常简单，不用复杂的技术，只靠print和log就能定位绝大部分问题，难题有[火焰图](/flame_gragh.md)这个神器。

* ####关闭code cache
这个选项在调试的时候最好关闭。
```lua
lua_code_cache off;
```
这样，你修改完代码后，不用reload nginx就可以生效了。在生产环境下记得打开这个选项。

* ####记录日志

这个看上去谁都会的东西，要想做好也不容易。

你有遇到这样的情况吗？QA发现了一个bug，开发说我修改代码加个日志看看，然后QA重现这个问题，发现日志不够详细，需要再加，反复几次，然后再给QA一个没有日志的版本，继续测试其他功能。

如果产品已经发布到用户那里了呢？如果用户那里是隔离网，不能远程怎么办？

***你在写代码的时候，就需要考虑到调试日志。*** 比如这个代码：
```lua
local response, err = redis_op.finish_client_task(client_mid, task_id)
if response then
    put_job(client_mid, result)
    ngx.log(ngx.WARN, "put job:", common.json_encode({channel="task_status", mid=client_mid, data=result}))
end
```
我们在做一个操作后，就把结果记录到nginx的error.log里面，等级是warn。在生产环境下，日志等级默认为error，在我们需要详细日志的时候，把等级调整为warn即可。在我们的实际使用中，我们会把一些很少发生的重要事件，做为error级别记录下来，即使它并不是nginx的错误。

与日志配套的，你需要[logrotate](http://linuxcommand.org/man_pages/logrotate8.html)来做日志的切分和备份。
