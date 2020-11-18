# 正则表达式

### POSIX 规范
在 OpenResty 中，同时存在两套正则表达式规范：Lua 语言的规范和 `ngx.re.*` 的规范，即使您对 Lua 语言中的规范非常熟悉，我们 **强烈建议不使用 Lua 中的正则表达式**。
- 一是因为 Lua 中正则表达式的性能并不如 `ngx.re.*` 中的正则表达式优秀；
- 二是 Lua 中的正则表达式并 **不符合 POSIX 规范**，而 `ngx.re.*` 中实现的是标准的 POSIX 规范，后者明显更具备通用性。

### 性能对比
Lua 中的正则表达式与 Nginx 中的正则表达式相比，有 5% - 15% 的性能损失，原因如下：
- Lua 将表达式编译成 Pattern 之后，并不会将 Pattern 缓存，而是每次使用都重新编译一遍，潜在地降低了性能。

- `ngx.re.*` 中的正则表达式可以通过参数缓存编译过后的 Pattern，不会有类似的性能损失。

### `ngx.re.*` 中的选项：

- `ngx.re.*` 中的 `o` 选项，若指明该参数，被编译的 Pattern 将会在工作进程中 **缓存**，并且被当前工作进程的每次请求所 **共享**。
Pattern 缓存的上限值通过 `lua_regex_cache_max_entries` 来修改，它的默认值为 1024。

- `ngx.re.*` 中的 `j` 选项，若指明该参数，如果使用的 PCRE 库支持 JIT，OpenResty 会在编译 Pattern 时启用 JIT。 启用 JIT 后正则匹配会有明显的性能提升。
较新的平台，自带的 PCRE 库均支持 JIT。 如果系统自带的 PCRE 库不支持 JIT，出于性能考虑，最好自己编译一份 libpcre.so，然后在编译 OpenResty 时链接过去。

要想验证当前 PCRE 库是否支持 JIT，可以这么做：
- 1、 编译 OpenResty 时在 `./configure` 中指定 `--with-debug` 选项；
- 2、 在 `error_log` 指令中指定日志级别为 `debug`；
- 3、 运行正则匹配代码，查看日志中是否有 `pcre JIT compiling result: 1`。

即使运行在不支持 JIT 的 OpenResty 上，加上 `j` 选项也不会带来坏的影响。在 OpenResty 官方的 Lua 库中，正则匹配至少都会带上 `jo` 这两个选项。

```nginx
location /test {
    content_by_lua_block {
        local regex = [[\d+]]

        -- 参数 "j" 启用 JIT 编译，参数 "o" 是开启缓存必须的
        local m = ngx.re.match("hello, 1234", regex, "jo")
        if m then
            ngx.say(m[0])
        else
            ngx.say("not matched!")
        end
    }
}
```

测试结果如下：

```shell
➜  ~ curl 127.0.0.1/test
1234
```

另外还可以试试引入 `lua-resty-core` 中的正则表达式 API。这么做需要在代码里加入 `require 'resty.core.regex'`。
`lua-resty-core` 版本的 `ngx.re.*`，是通过 FFI 而非 Lua/C API 来跟 OpenResty C 代码交互的。某些情况下，会带来明显的性能提升。

### Lua 正则简单汇总

Lua 中正则表达式语法上 **最大的区别，Lua 使用 `%` 来进行转义**，而其他语言的正则表达式使用 **`\`** 符号来进行转义。 其次，Lua 中并不使用 **`?`** 来表示非贪婪匹配，而是定义了不同的字符来表示是否为贪婪匹配。

定义如下：
| 符号 | 匹配次数 | 匹配模式 |
|:---:|:---|:---|
| `+` | 匹配前一字符 1 次或多次 | 非贪婪 |
| `*` | 匹配前一字符 0 次或多次 | 贪婪   |
| `-` | 匹配前一字符 0 次或多次 | 非贪婪 |
| `?` | 匹配前一字符 0 次或 1 次  | 仅用于此，不用于标识是否贪婪 |

| 符号 | 匹配模式 |
|:---:|:----------|
| x  |x 是一个随机字符，代表它自身。(x 不是^$()%.[]*+-? 等特殊字符）     |
| .  |任意字符     |
| %a |字母         |
| %c |控制字符     |
| %d |数字         |
| %l |小写字母     |
| %p |标点字符     |
| %s |空白符       |
| %u |大写字母     |
| %w |字母和数字   |
| %x |十六进制数字 |
| %z |代表 0 的字符|
| [ABC] |匹配 `[...]` 中的所有字符，例如 `[aeiou]` 匹配字符串 "google runoob taobao" 中所有的 e o u a 字母。|
| [^ABC] |匹配除了 `[...]` 中字符的所有字符，例如 `[^aeiou]` 匹配字符串 "google runoob taobao" 中除了 e o u a 字母的所有字母。|

### 常用的正则函数
- `string.find` 的基本应用是在目标串内搜索匹配指定的模式的串。
    - 函数如果找到匹配的串，就返回它的开始索引和结束索引，否则返回 `nil`。
    - `find` 函数第三个参数是可选的：标示目标串中搜索的起始位置。
    例如当我们想实现一个迭代器时，可以传进上一次调用时的结束索引，如果返回了一个 `nil` 值的话，说明查找结束了。

    ```lua
    local s    = "hello world"
    local i, j = string.find(s, "hello")
    print(i, j) --> 1 5
    ```

- `string.gmatch` 我们也可以使用返回迭代器的方式。

    ```lua
    local s = "hello world from Lua"

    for w in string.gmatch(s, "%a+") do
        print(w)
    end

    -- output :
    --    hello
    --    world
    --    from
    --    Lua
    ```

- `string.gsub` 用来查找匹配模式的串，并使用替换串将其替换掉，但并不修改原字符串，而是返回一个修改后的字符串的副本。
    函数有 **目标串、模式串、替换串** 三个参数，使用范例如下：

    ```lua
    local a = "Lua is cute"
    local b = string.gsub(a, "cute", "great")
    print(a) --> Lua is cute
    print(b) --> Lua is great
    ```

-  还有一点值得注意的是，**'%b' 用来匹配对称的字符，而不是一般正则表达式中的单词的开始、结束。 而且采用的是贪婪匹配模式**。
    常写为 '%bxy'，x 和 y 是任意两个不同的字符，x 作为匹配的开始，y 作为匹配的结束。 比如，'%b()' 匹配以 '(' 开始，以 ')' 结束的字符串，示例如下：

    ```lua
    print(string.gsub("a (enclosed (in) parentheses) line", "%b()", ""))

    -- output: a  line 1
    ```
