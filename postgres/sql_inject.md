# SQL 注入

有使用 SQL 语句操作数据库经验的朋友，应该都知道使用 SQL 过程中有一个安全问题叫 SQL 注入。所谓 SQL 注入，就是通过把 SQL 命令插入到 Web 表单提交或输入域名或页面请求的查询字符串，最终达到欺骗服务器执行恶意的 SQL 命令的目的。
为了防止 SQL 注入，在生产环境中使用 OpenResty 的时候就要注意添加防范代码。

延续之前的 `ngx_postgres` 调用代码的使用，

```lua
local sql_normal = [[select id, name from user where name=']] ..
                    ngx.var.arg_name .. [[' and password=']] ..
                    ngx.var.arg_password .. [[' limit 1;]]

local res = ngx.location.capture(
    '/postgres',
    { args = {sql = sql } }
)

local body = json.decode(res.body)

if (table.getn(res) > 0) {
    return res[1];
}

return nil;
```

假设我们在用户登录使用上述 SQL 语句查询账号和密码是否正确，用户可以通过 GET 方式请求并发送登录信息比如：

```
# curl http://localhost/login?name=person&password=12345
```

那么我们上面的代码通过 `ngx.var.arg_name` 和 `ngx.var.arg_password` 获取查询参数，并且与 SQL 语句格式进行字符串拼接，最终 `sql_normal` 会是这个样子的：
```lua
local sql_normal = [[select id, name from user where name='person' and password='12345' limit 1;]]
```

正常情况下，如果 person 账号存在并且 `password` 是 12345，那么 SQL 执行结果就应该是能返回 id 号的。这个接口如果暴露在攻击者面前，那么攻击者很可能会让参数这样传入：

```
name="' or ''='"
password="' or ''='"
```

那么这个 `sql_normal` 就会变成一个永远都能执行成功的语句了。
```lua
local sql_normal = [[select id, name from user where name='' or ''='' and password='' or ''='' limit 1;]]
```

这就是一个简单的 SQL Inject（注入）的案例，那么问题来了，面对这么凶猛的攻击者，我们有什么办法防止这种 SQL 注入呢？

很简单，我们只要把传入参数的变量做一次字符转义，把不该作为破坏 SQL 查询语句结构的双引号或者单引号等做转义，把 `'` 转义成 `\'`，那么变量 `name` 和 `password` 的内容还是乖乖的作为查询条件传入，他们再也不能为非作歹了。

那么怎么做到字符转义呢？要知道每个数据库支持的 SQL 语句格式都不太一样啊，尤其是双引号和单引号的应用上。有以下几个选择：

```lua
ndk.set_var.set_quote_sql_str()
ndk.set_var.set_quote_pgsql_str()
ngx.quote_sql_str()
```

对这三个函数，解释如下：
- 前面两个是 `ndk.set_var` 跳转调用，其实是 `HttpSetMiscModule` 这个模块提供的函数，是一个 C 模块实现的函数；
    - `set_quote_sql_str()` 是用于 MySQL 格式的 SQL 语句字符转义；
    - `set_quote_pgsql_str()` 是用于 PostgreSQL 格式的 SQL 语句字符转义。
- `ngx.quote_sql_str()` 是一个 `ngx_lua` 模块中实现的函数，也是用于 MySQL 格式的 SQL 语句字符转义。

让我们看看代码怎么写：

```lua
local name       = ngx.quote_sql_str(ngx.var.arg_name)
local password   = ngx.quote_sql_str(ngx.var.arg_password)
local sql_normal = [[select id, name from user where name=]] ..
                    name .. [[ and password=]] ..
                    password .. [[ limit 1;]]

local res = ngx.location.capture(
    '/postgres',
    { args = {sql = sql } }
)

local body = json.decode(res.body)

if (table.getn(res) > 0) {
    return res[1];
}

return nil;
```

注意上述代码有两个变化：
- 用 `ngx.quote_sql_str()` 把 `ngx.var.arg_name` 和 `ngx.var.arg_password` 包了一层，把返回值拼接起来组成 SQL 语句。
- 原本在 SQL 语句中添加的单引号去掉了，因为 `ngx.quote_sql_str()` 的返回值正确的带上引号了。

这样已经可以抵御 SQL 注入的攻击手段了，但开发过程中需要不断地产生新功能新代码，这时候也一定注意不要忽视对 SQL 注入的防护，安全防御代码就像织网一样，只要有一处漏洞，鱼儿可就游走了。
