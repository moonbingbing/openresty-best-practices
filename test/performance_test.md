# 性能测试

性能测试应该有两个方向：

* 单接口压力测试
* 生产环境模拟用户操作高压力测试

生产环境模拟测试，目前我们都是交给公司的 QA 团队专门完成的。这块我只能粗略列举一下：

* 获取 1000 用户以上生产用户的访问日志（统计学要求 1000 是最小集合）
* 计算指定时间内（例如 10 分钟），所有接口的触发频率
* 使用测试工具（loadrunner, jmeter 等）模拟用户请求接口
* 适当放大压力，就可以模拟 2000、5000 等用户数的情况

#### ab 压测

单接口压力测试，我们都是由研发团队自己完成的。传统一点的方法，我们可以使用 ab(apache bench)这样的工具。

```
#ab -n10 -c2 http://haosou.com/

-- output:
...
Complete requests:      10
Failed requests:        0
Non-2xx responses:      10
Total transferred:      3620 bytes
HTML transferred:       1780 bytes
Requests per second:    22.00 [#/sec] (mean)
Time per request:       90.923 [ms] (mean)
Time per request:       45.461 [ms] (mean, across all concurrent requests)
Transfer rate:          7.78 [Kbytes/sec] received
...
```

大家可以看到 ab 的使用超级简单，简单的有点弱了。在上面的例子中，我们发起了 10 个请求，每个请求都是一样的，如果每个请求有差异，ab 就无能为力。

#### wrk 压测

单接口压力测试，为了满足每个请求或部分请求有差异，我们试用过很多不同的工具。最后找到了这个和我们距离最近、表现优异的测试工具[wrk](https://github.com/wg/wrk)，这里我们重点介绍一下。

wrk 如果要完成和 ab 一样的压力测试，区别不大，只是命令行参数略有调整。下面给大家举例每个请求都有差异的例子，供大家参考。

> scripts/counter.lua

```lua
-- example dynamic request script which demonstrates changing
-- the request path and a header for each request
-------------------------------------------------------------
-- NOTE: each wrk thread has an independent Lua scripting
-- context and thus there will be one counter per thread

counter = 0

request = function()
   path = "/" .. counter
   wrk.headers["X-Counter"] = counter
   counter = counter + 1
   return wrk.format(nil, path)
end
```

> shell执行

```
# ./wrk -c10 -d1 -s scripts/counter.lua http://baidu.com
Running 1s test @ http://baidu.com
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    20.44ms    3.74ms  34.87ms   77.48%
    Req/Sec   226.05     42.13   270.00     70.00%
  453 requests in 1.01s, 200.17KB read
  Socket errors: connect 0, read 9, write 0, timeout 0
Requests/sec:    449.85
Transfer/sec:    198.78KB
```

> WireShark抓包印证一下

```
GET /228 HTTP/1.1
Host: baidu.com
X-Counter: 228

...(应答包 省略)

GET /232 HTTP/1.1
Host: baidu.com
X-Counter: 232

...(应答包 省略)
```

wrk 是个非常成功的作品，它的实现更是从多个开源作品中挖掘优秀的代码融入自身，如果你每天还在用 C/C++，那么 wrk 的成功，对你应该有绝对的借鉴意义，多抬头，多看优秀代码，我们绝对可以创造奇迹。

引用[wrk](https://github.com/wg/wrk)官方结尾：

```
wrk contains code from a number of open source projects including the 'ae'
 event loop from redis, the nginx/joyent/node.js 'http-parser', and Mike
 Pall's LuaJIT.
```

