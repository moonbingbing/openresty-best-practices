# 日期时间函数

在 Lua 中，函数 `time`、`date` 和 `difftime` 提供了所有的日期和时间功能。

### （推荐）基于缓存的 ngx_lua 时间接口

事实上，在 Nginx/Openresty 中，会经常使用到获取时间操作，通常一次请求最少有几十次获取时间操作，当单核心 RPS/QPS 达到 10K 以上时，获取时间操作往往会达到 200K+量级的调用，是一个非常高频的调用。所以 Nginx 会将时间和日期进行缓存，并非每次调用或每次请求获取时间和日期。

**推荐** 使用 ngx_lua 模块提供的带缓存的时间接口，如 `ngx.today`, `ngx.time`, `ngx.utctime`,
`ngx.localtime`, `ngx.now`, `ngx.http_time`，以及 `ngx.cookie_time` 等。

#### ngx.today()

语法：`str = ngx.today()`

该接口从 Nginx 缓存的时间中获取时间，返回当前的时间和日期，其格式为`yyyy-mm-dd`（与 Lua 的日期库不同，不涉及系统调用）。

#### ngx.time()

语法：`secs = ngx.time()`

该接口从 Nginx 缓存的时间中获取时间，返回当前时间戳的历时秒数（与 Lua 的日期库不同，不涉及系统调用）。

#### ngx.now()

语法：`secs = ngx.now()`

该接口从 Nginx 缓存的时间中获取时间，以秒为单位（包括小数部分的毫秒）返回从当前时间戳开始的浮点数（与 Lua 的日期库不同，不涉及系统调用）。

> ngx.time() 和 ngx.now() 辨析：ngx.time() 获取到的是秒级时间，ngx.now() 获取到的是毫秒级时间。

#### ngx.localtime()

语法：`str = ngx.localtime()`

返回 Nginx 缓存时间的当前时间戳（格式为 `yyyy-mm-dd hh:MM:ss`）（与 Lua 的日期库不同，不涉及系统调用）。

#### ngx.utctime()

语法：`str = ngx.utctime()`

返回 Nginx 缓存时间的当前 UTC 时间戳（格式为 `yyyy-mm-dd hh:MM:ss`）（与 Lua 的日期库不同，不涉及系统调用）。

#### ngx.update_time()

语法：`ngx.update_time()`

强制更新 Nginx 当前时间缓存。这个调用涉及到一个系统调用，因此有一些开销，所以不要滥用。

#### 获取时间示例代码

示例代码：

```lua
ngx.log(ngx.INFO, ngx.today())
ngx.log(ngx.INFO, ngx.time())
ngx.log(ngx.INFO, ngx.now())
ngx.log(ngx.INFO, ngx.localtime())
ngx.log(ngx.INFO, ngx.utctime())

ngx.update_time()

ngx.log(ngx.INFO, ngx.today())
ngx.log(ngx.INFO, ngx.time())
ngx.log(ngx.INFO, ngx.now())
ngx.log(ngx.INFO, ngx.localtime())
ngx.log(ngx.INFO, ngx.utctime())

-->output
2020/12/31 15:37:27 [error] 15851#0: *2153324: 2020-12-31
2020/12/31 15:37:27 [error] 15851#0: *2153324: 1609400247
2020/12/31 15:37:27 [error] 15851#0: *2153324: 1609400247.704 --**
2020/12/31 15:37:27 [error] 15851#0: *2153324: 2020-12-31 15:37:27
2020/12/31 15:37:27 [error] 15851#0: *2153324: 2020-12-31 07:37:27
2020/12/31 15:37:27 [error] 15851#0: *2153324: 2020-12-31
2020/12/31 15:37:27 [error] 15851#0: *2153324: 1609400247
2020/12/31 15:37:27 [error] 15851#0: *2153324: 1609400247.705 --缓存时间有变化
2020/12/31 15:37:27 [error] 15851#0: *2153324: 2020-12-31 15:37:27
2020/12/31 15:37:27 [error] 15851#0: *2153324: 2020-12-31 07:37:27
```

### （不推荐） Lua 自带的日期和时间函数

在 OpenResty 的世界里，**不推荐** 使用这里的标准时间函数，因为这些函数通常会引发不止一个昂贵的系统调用，同时无法为 LuaJIT JIT 编译，对性能造成较大影响。

所以下面的部分函数，简单了解一下即可。

#### os.time ([table])

- 如果不使用参数 table 调用 `time` 函数，它会返回 **当前** 的时间和日期（它表示从某一时刻到现在的秒数）。

- 如果用 table 参数，它会返回一个数字，表示该 table 中所描述的日期和时间（它表示从某一时刻到 table 中描述日期和时间的秒数）。

table 的字段如下：

|字段名称|取值范围|
|:------:|:------:|
|year|四位数字|
|month|1--12|
|day|1--31|
|hour|0--23|
|min|0--59|
|sec|0--61|
|isdst|boolean（true 表示夏令时）|

对于 `time` 函数，如果参数为 table，那么 table 中 **必须** 含有 year、month、day 字段。其他字段缺省时，默认为中午（12:00:00）。

>示例代码：（地点为北京）

```lua
print(os.time())    -->output  1438243393
a = { year = 1970, month = 1, day = 1, hour = 8, min = 1 }
print(os.time(a))   -->output  60
```

#### os.difftime (t2, t1)

返回 t1 到 t2 的时间差，单位为秒。

>示例代码：

```lua
local day1 = { year = 2015, month = 7, day = 30 }
local t1 = os.time(day1)

local day2 = { year = 2015, month = 7, day = 31 }
local t2 = os.time(day2)
print(os.difftime(t2, t1))   -->output  86400
```

#### os.date ([format [, time]])

把一个表示日期和时间的数值，转换成更高级的表现形式。

- 第一个参数 format 是一个格式化字符串，描述了要返回的时间形式。

- 第二个参数 time 就是日期和时间的数字表示，缺省时默认为当前的时间。

使用格式字符 "\*t"，创建一个时间 table。

> 示例代码：

```lua
local tab1 = os.date("*t")       --返回一个描述当前日期和时间的表
local ans1 = "{"
for k, v in pairs(tab1) do       --把 tab1 转换成一个字符串
    ans1 = string.format("%s %s = %s,", ans1, k, tostring(v))
end

ans1 = ans1 .. "}"
print("tab1 = ", ans1)

local tab2 = os.date("*t", 360)  --返回一个描述日期和时间数为 360 秒的表
local ans2 = "{"
for k, v in pairs(tab2) do       --把 tab2 转换成一个字符串
    ans2 = string.format("%s %s = %s,", ans2, k, tostring(v))
end

ans2 = ans2 .. "}"
print("tab2 = ", ans2)

-->output
tab1 = { hour = 17, min = 28, wday = 5, day = 30, month = 7, year = 2015, sec = 10, yday = 211, isdst = false,}

tab2 = { hour = 8, min = 6, wday = 5, day = 1, month = 1, year = 1970, sec = 0, yday = 1, isdst = false,}
```

该表中除了使用到了 `time` 函数参数 table 的字段外，这还提供了星期（wday，星期天为 1）和一年中的第几天（yday，一月一日为 1）。
除了使用 "\*t" 格式字符串外，如果使用带标记（见下表）的特殊字符串，`os.date` 函数会将相应的标记位以时间信息进行填充，得到一个包含时间的字符串。
表如下：

|格式字符|含义|
|:------:|------|
|%a|一星期中天数的简写（例如：Wed）|
|%A|一星期中天数的全称（例如：Wednesday）|
|%b|月份的简写（例如：Sep）|
|%B|月份的全称（例如：September）|
|%c|日期和时间（例如：07/30/15 16:57:24）|
|%d|一个月中的第几天 [01 ~ 31]|
|%H|24 小时制中的小时数 [00 ~ 23]|
|%I|12 小时制中的小时数 [01 ~ 12]|
|%j|一年中的第几天 [001 ~ 366]|
|%M|分钟数 [00 ~ 59]|
|%m|月份数 [01 ~ 12]|
|%p|“上午（am）”或“下午（pm）”|
|%S|秒数 [00 ~ 59]|
|%w|一星期中的第几天 [1 ~ 7 = 星期天 ~ 星期六]|
|%x|日期（例如：07/30/15）|
|%X|时间（例如：16:57:24）|
|%y|两位数的年份 [00 ~ 99]|
|%Y|完整的年份（例如：2015）|
|%%|字符'%'|

> 示例代码：

```lua
print(os.date("today is %A, in %B"))
print(os.date("now is %x %X"))

-->output
today is Thursday, in July
now is 07/30/15 17:39:22
```
