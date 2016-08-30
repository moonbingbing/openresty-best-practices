# 数据合法性检测

对用户输入的数据进行合法性检查，避免错误非法的数据进入服务，这是业务系统最常见的需求。很可惜Lua目前没有特别好的数据合法性检查库。

坦诚我们自己做的也不够好，这里只能抛砖引玉，看看大家是否有更好办法。

我们有这么几个主要的合法性检查场景：

- JSON 数据格式
- 关键字段编码为 HEX（0-9，a-f，A-F），长度不定
- TABLE 内部字段类型

#### JSON 数据格式

这里主要是`JSON DECODE`时，可能存在 Crash 的问题。我们已经在 [JSON 解析的异常捕获](../json/parse_exception.md) 一章中详细说明了问题本身以及解决方法，这里就不再重复。

#### 关键字段编码为 HEX，长度不定

HEX 编码，最常见的存在有 MD5 值等。他们是由 0-9，A-F（或 a-f）组成。笔者把使用过的代码版本逐一罗列，并进行性能测试。通过这个测试，我们不仅仅可以收获参数校验的正确写法，以及可以再次印证一下效率最高的匹配，应该注意什么。

```lua
-- 纯 lua 版本，优点是兼容性好，可以使用任何 lua 语言环境
function check_hex_lua( str, correct_len )
    if "string" ~= type(str) then
        return false
    end

    for i=1, #str do
        local c = str:sub(i, i)
        if (c >= 'A' and c <= 'F') or
         (c >= 'a' and c <= 'f') or
         (c >= '0' and c <= '9')
         then
            -- print(c)
        else
            return false
        end
    end

    if correct_len and correct_len ~= #str then
      return false
    end

    return true
end

-- 使用 ngx.re.* 完成，没有使用任何调优参数
function check_hex_default( str )
    if "string" ~= type(str) then
        return false
    end

    return ngx.re.find(str, "([^0-9^a-f^A-F])")
end

-- 使用 ngx.re.* 完成，使用调优参数 "jo"
function check_hex_jo( str )
    if "string" ~= type(str) then
        return false
    end

    return ngx.re.find(str, "([^0-9^a-f^A-F])", "jo")
end


-- 下面就是测试用例部分代码
function do_test( name, fun )
    ngx.update_time()
    local start = ngx.now()

    local t = "012345678901234567890123456789abcdefABCDEF"
    for i=1,10000*300 do
        fun(t)
    end

    ngx.update_time()
    print(name, "\ttimes:", ngx.now() - start)
end

do_test("check_hex_lua", check_hex_lua)
do_test("check_hex_default", check_hex_default)
do_test("check_hex_jo", check_hex_jo)
```

把上面的源码在 OpenResty 环境中运行，输出结果如下：

```shell
➜  resty test.lua
check_hex_lua   times:2.8619999885559
check_hex_default   times:4.1790001392365
check_hex_jo    times:0.91899991035461
```

不知道这个结果大家是否有些意外，`check_hex_default` 的运行效率居然比 `check_hex_lua` 要差。不过所幸的是我们对正则开启了 `jo` 参数优化后，速度上有明显提升。

引用一下 ngx.re.* 官方 wiki 的原文：在优化性能时，o 选项非常有用，因为正则表达式模板将仅仅被编译一次，之后缓存在 worker 级的缓存中，并被此 nginx worker 处理的所有请求共享。缓存数量上限可以通过 lua_regex_cache_max_entries 指令调整。

> 课后小作业：为什么测试用例中要使用 ngx.update_time() 呢？好好想一想。

#### TABLE 内部字段类型

当我们接收客户端请求，除了指定字段的特殊校验外，我们最常见的需求就是对指定字段的类型做限制了。比如用户注册接口，我们就要求对方姓名、邮箱等是个字符串，手机号、电话号码等是个数字类型，详细信息可能是个图片又或者是个嵌套的 TABLE 。

例如我们接受用户的注册请求，注册接口示例请求 body 如下：

```json
{
    "username":"myname",
    "age":8,
    "tel":88888888,
    "mobile_no":13888888888,
    "email":"***@**.com",
    "love_things":["football", "music"]
}
```

这时候可以用一个简单的字段描述格式来表达限制关系，如下：

```json
{
    "username":"",
    "age":0,
    "tel":0,
    "mobile_no":0,
    "email":"",
    "love_things":[]
}
```

对于有效字段描述格式，数据值是不敏感的，但是数据类型是敏感的，只要数据类型能匹配，就可以让我们轻松不少。

来看下面的参数校验代码以及基本的测试用例：

```lua
function check_args_template(args, template)
    if type(args) ~= type(template) then
      return false
    elseif "table" ~= type(args) then
      return true
    end

    for k,v in pairs(template) do
      if type(v) ~= type(args[k]) then
        return false
      elseif "table" == type(v) then
        if not check_args_template(args[k], v) then
          return false
        end
      end
    end

    return true
end

local args = {name="myname", tel=888888, age=18,
    mobile_no=13888888888, love_things = {"football", "music"}}

print("valid   check: ", check_args_template(args, {name="", tel=0, love_things={}}))
print("unvalid check: ", check_args_template(args, {name="", tel=0, love_things={}, email=""}))
```

运行一下上面的代码，结果如下：

```shell
➜  resty test.lua
valid   check: true
unvalid check: false
```

可以看到，当我们业务层面需要有 email 地址但是请求方没有上送，这时候就能检测出来了。大家看到这里也许会笑，尤其是从其他成熟 web 框架中过来的同学，我们这里的校验可以说是比较粗糙简陋的，很多开源框架中的参数限制，都可以做到更加精确的限制。

如果你有更好更优雅的解决办法，欢迎与我们联系。


