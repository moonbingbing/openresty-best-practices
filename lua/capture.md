# ngx.location.capture() 传递消息体

-  ngx.location.capture()用于请求的内部转发，在实现上是函数级别的调用，但是在capture前如果调用ngx.req.read_body()，body将被取出，captrue的目标location将不能获取到body，正确地使用示例：

```
ngx.req.read_body()
local data = ngx.req.get_body_data()
location res = ngx.location.capture('/foo/bar'，{ method = ngx.HTTP_POST, body = data})
```
这样在/foo/bar这个location中就能继续read_body()获取消息体

当然location还有很多其它的玩儿法，包括设置method，设置args等等

