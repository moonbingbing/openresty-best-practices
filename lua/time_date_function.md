#日期时间函数

在lua中，函数time、date和difftime提供了所有的日期和时间功能。

####os.time ([table])
如果不使用参数table调用time函数，它会返回当前的时间和日期（它表示从某一时刻到现在的秒数）。如果用table参数，它会返回一个数字，表示该table中所描述的日期和时间（它表示从某一时刻到table中描述日期和时间的秒数）。table的字段如下：

|字段名称|取值范围|
|:------:|:------:|
|year|四位数字|
|month|1--12|
|day|1--31|
|hour|0--23|
|min|0--59|
|sec|0--61|
|isdst|boolean（true表示夏令时）|

对于time函数，如果参数为table，那么table中必须含有year、month、day字段。其他字缺省时段默认为中午（12:00:00）。

>示例代码：（地点为北京）

```lua
print(os.time())    -->output  1438243393
a = { year = 1970, month = 1, day = 1, hour = 8, min = 1 }
print(os.time(a))   -->output  60
```

####os.difftime (t2, t1)
返回t1到t2的时间差，单位为秒。

>示例代码:

```lua
local day1 = { year = 2015, month = 7, day = 30 }
local t1 = os.time(day1)

local day2 = { year = 2015, month = 7, day = 31 }
local t2 = os.time(day2)
print(os.difftime(t2, t1))   -->output  86400
```

####os.date ([format [, time]])
把一个表示日期和时间的数值，转换成更高级的表现形式。其第一个参数format是一个格式化字符串，描述了要返回的时间形式。第二个参数time就是日期和时间的数字表示，缺省时默认为当前的时间。
使用格式字符 "*t"，创建一个时间表。

>示例代码：

```lua
local tab1 = os.date("*t")  --返回一个描述当前日期和时间的表
local ans1 = "{"
for k, v in pairs(tab1) do  --把tab1转换成一个字符串
    ans1 = string.format("%s %s = %s,", ans1, k, tostring(v))
end

ans1 = ans1 .. "}"
print("tab1 = ", ans1)


local tab2 = os.date("*t", 360)  --返回一个描述日期和时间数为360秒的表
local ans2 = "{"
for k, v in pairs(tab2) do      --把tab2转换成一个字符串
    ans2 = string.format("%s %s = %s,", ans2, k, tostring(v))
end

ans2 = ans2 .. "}"
print("tab2 = ", ans2)

-->output
tab1 = { hour = 17, min = 28, wday = 5, day = 30, month = 7, year = 2015, sec = 10, yday = 211, isdst = false,}
tab2 = { hour = 8, min = 6, wday = 5, day = 1, month = 1, year = 1970, sec = 0, yday = 1, isdst = false,}
```

该表中除了使用到了time函数参数table的字段外，这还提供了星期（wday，星期天为1）和一年中的第几天（yday，一月一日为1）。
除了使用 "*t" 格式字符串外，如果使用带标记（见下表）的特殊字符串，os.data函数会将相应的标记位以时间信息进行填充，得到一个包含时间的字符串。
表如下：

|格式字符|含义|
|:------:|:------:|
|%a|一星期中天数的简写（例如：Wed）|
|%A|一星期中天数的全称（例如：Wednesday）|
|%b|月份的简写（例如：Sep）|
|%B|月份的全称（例如：September）|
|%c|日期和时间（例如：07/30/15 16:57:24）|
|%d|一个月中的第几天[01 ~ 31]|
|%H|24小时制中的小时数[00 ~ 23]|
|%I|12小时制中的小时数[01 ~ 12]|
|%j|一年中的第几天[001 ~ 366]|
|%M|分钟数[00 ~ 59]|
|%m|月份数[01 ~ 12]|
|%p|“上午（am）”或“下午（pm）”|
|%S|秒数[00 ~ 59]|
|%w|一星期中的第几天[1 ~ 7 = 星期天 ~ 星期六]|
|%x|日期（例如：07/30/15）|
|%X|时间（例如：16:57:24）|
|%y|两位数的年份[00 ~ 99]|
|%Y|完整的年份（例如：2015）|
|%%|字符'%'|

>示例代码：

```lua
print(os.date("today is %A, in %B"))
print(os.date("now is %x %X"))

-->output
today is Thursday, in July
now is 07/30/15 17:39:22
```
