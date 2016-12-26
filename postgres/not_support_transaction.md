# 不支持事务

我们继续上一章节的内容，大家应该记得我们 `Lua` 代码中是如何完成 `ngx_postgres` 模块调用的。我们把他简单改造一下，让他更接近真实代码。

```lua
	local json = require "cjson"

	function db_exec(sql_str)
	    local res = ngx.location.capture('/postgres',
	        { args = {sql = sql_str } }
	    )

	    local status = res.status
	    local body = json.decode(res.body)

	    if status == 200 then
	        status = true
	    else
	        status = false
	    end
	    return status, body
	end

	-- 转账操作，对ID=100的用户加10，同时对ID=200的用户减10。
?	local status
?	status = db_exec("BEGIN")
?	if status then
?		db_exec("ROLLBACK")
?	end
?
?	status = db_exec("UPDATE ACCOUNT SET MONEY=MONEY+10  WHERE ID = 100")
?	if status then
?		db_exec("ROLLBACK")
?	end
?
?	status = db_exec("UPDATE ACCOUNT SET MONEY=MONEY-10  WHERE ID = 200")
?	if status then
?		db_exec("ROLLBACK")
?	end
?
?	db_exec("COMMIT")
```

后面这部分有问题的代码，在没有并发的场景下使用，是不会有任何问题的。但是这段代码在高并发应用场景下，错误百出。你会发现最后执行结果完全摸不清楚。明明是个转账逻辑，一个收入，一直支出，最后却发现总收入比支出要大。如果这个错误发生在金融领域，那不知道要赔多少钱。

如果你能靠自己很快明白错误的原因，那么恭喜你你对数据库连接 `Nginx` 机理都是比较清楚的。如果你想不明白，那就听我给你掰一掰这面的小知识。

数据库的事物成功执行，事物相关的所有操作是必须执行在一条连接上的。`SQL` 的执行情况类似这样：

```
连接：`BEGIN` -> `SQL(UPDATE、DELETE... ...)` -> `COMMIT`。
```

但如果你创建了两条连接，每条连接提交的 SQL 语句是下面这样：

```
连接1：`BEGIN` -> `SQL(UPDATE、DELETE... ...)`
连接2：`COMMIT`
```

这时就会出现连接 1 的内容没有被提交，行锁产生。连接 2 提交了一个空的 `COMMIT`。

说到这里你可能开始鄙视我了，谁疯了非要创建两条连接来这么用 SQL 啊。又麻烦，又不好看，貌似从来没听说过还有人在一次请求中创建多个数据库连接，简直就是非人类嘛。

或许你不会主动、显示的创建多个连接，但是刚刚的示例代码，高并发下这个事物的每个 SQL 语句都可能落在不同的连接上。为什么呢？这是因为通过 `ngx.location.capture` 跳转到 `/postgres` 小节后，`Nginx` 每次都会从连接池中挑选一条空闲连接，而当时哪条连接是空闲的，完全没法预估。所以上面的第二个例子，就这么静悄悄的发生了。如果你不了解 `Nginx` 的机理，那么他肯定会一直困扰你。为什么一会儿好，一会儿不好。

同样的道理，我们推理到 `DrizzleNginxModule`、`RedisNginxModule`、`Redis2NginxModule`，他们都是无法做到在两次连续请求落到同一个连接上的。

由于这个 `Bug` 藏得比较深，并且不太好讲解，所以我觉得生产中最好用 `lua-resty-*` 这类的库，更符合标准调用习惯，直接可以绕过这些坑。不要为了一点点的性能，牺牲了更大的蛋糕。看得见的，看不见的，都要了解用用，最后再做决定，肯定不吃亏。
