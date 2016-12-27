# ngx.location.capture() 传递消息体

-  ngx.location.capture()用于请求的内部转发，在实现上是函数级别的调用，但是在 capture 前如果调用 ngx.req.read_body()，body 将被取出，captrue 的目标 location 将不能获取到 body，正确地使用示例：

```
ngx.req.read_body()
local data = ngx.req.get_body_data()
location res = ngx.location.capture('/foo/bar'，{ method = ngx.HTTP_POST, body = data})
```
这样在/foo/bar 这个 location 中就能继续 read_body()获取消息体

当然 location 还有很多其它的玩儿法，包括设置 method，设置 args 等等

