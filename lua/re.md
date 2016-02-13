# 正则表达式

在*OpenResty*中，同时存在两套正则表达式规范： *Lua* 语言的规范和*Nginx*的规范，即使您对 *Lua* 语言中的规范非常熟悉，我们仍不建议使用 *Lua* 中的正则表达式。一是因为 *Lua* 中正则表达式的性能并不如 *Nginx* 中的正则表达式优秀；二是 *Lua* 中的正则表达式并不符合 *POSIX* 规范，而 *Nginx* 中实现的是标准的 *POSIX* 规范，后者明显更具备通用性。

*Lua* 中的正则表达式与Nginx中的正则表达式相比，有5%-15%的性能损失，而且Lua将表达式编译成Pattern之后，并不会将Pattern缓存，而是每此使用都重新编译一遍，潜在地降低了性能。 *Nginx* 中的正则表达式可以通过参数缓存编译过后的Pattern，不会有类似的性能损失。

o选项参数用于提高性能，指明该参数之后，被编译的Pattern将会在worker进程中缓存，并且被当前worker进程的每次请求所共享。Pattern缓存的上限值通过lua_regex_cache_max_entries来修改。

```
# nginx.conf
location /test {
    content_by_lua_block {
        local regex = [[\\d+]]

        -- 参数"o"是开启缓存必须的
        local m = ngx.re.match("hello, 1234", regex, "o")  
        if m then
            ngx.say(m[0])
        else
            ngx.say("not matched!")
        end
    }
}
# 在网址中输入"yourURL/test"，即会在网页中显示1234。
```

#### Lua正则简单汇总

-  *string.find* 的基本应用是在目标串内搜索匹配指定的模式的串。函数如果找到匹配的串，就返回它的开始索引和结束索引，否则返回 *nil*。*find* 函数第三个参数是可选的：标示目标串中搜索的起始位置，例如当我们想实现一个迭代器时，可以传进上一次调用时的结束索引，如果返回了一个*nil*值的话，说明查找结束了.


```lua
local s = "hello world"
local i, j = string.find(s, "hello")
print(i, j) --> 1 5
```

- *string.gmatch* 我们也可以使用返回迭代器的方式。

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

-  *string.gsub* 用来查找匹配模式的串，并将使用替换串其替换掉，但并不修改原字符串，而是返回一个修改后的字符串的副本，函数有目标串，模式串，替换串三个参数，使用范例如下：

```lua
local a = "Lua is cute"
local b = string.gsub(a, "cute", "great")
print(a) --> Lua is cute
print(b) --> Lua is great
```

-  还有一点值得注意的是，'%b' 用来匹配对称的字符，而不是一般正则表达式中的单词的开始、结束。
'%b' 用来匹配对称的字符，而且采用贪婪匹配。常写为 '%bxy' ，x 和 y 是任意两个不同的字符；x 作为
匹配的开始，y 作为匹配的结束。比如，'%b()' 匹配以 '(' 开始，以 ')' 结束的字符串：

```lua
--> a line
print(string.gsub("a (enclosed (in) parentheses) line", "%b()", ""))
```
