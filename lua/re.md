# 正则表达式
在*OpenResty*中，同时存在两套正则表达式规范：*Lua*语言的规范和*Nginx*的规范，即使您对*Lua*语言中的规范非常熟悉，我们仍不建议使用*Lua*中的正则表达式。一是因为*Lua*中正则表达式的性能并不如*Nginx*中的正则表达式优秀；二是*Lua*中的正则表达式并不符合*POSIX*规范，而*Nginx*中实现的是标准的*POSIX*规范，后者明显更具备通用性。

*Lua*中的正则表达式与Nginx中的正则表达式相比，有5%-15%的性能损失，而且Lua将表达式编译成Pattern之后，并不会将Pattern缓存，而是每此使用都重新编译一遍，潜在地降低了性能。*Nginx*中的正则表达式可以通过参数缓存编译过后的Pattern，不会有类似的性能损失。

o选项参数用于提高性能，指明该参数之后，被编译的Pattern将会在worker进程中缓存，并且被当前所有的worker进程所共享。Pattern缓存的上限值通过lua_regex_cache_max_entries来修改。

 ```
# nginx.conf
location /test {
    content_by_lua '
        local regex = "\\\\d+"
        local m = ngx.re.match("hello, 1234", regex, "o")  --参数"o"是开启缓存必须的
        if m then ngx.say(m[0]) else ngx.say("not matched!") end
    ';
}
# 在网址中输入"yourURL/test"，即会在网页中显示1234。
```

*Lua*中正则表达式语法上最大的区别，*Lua*使用*'%'*来进行转义，而其他语言的正则表达式使用*'\'*符号来进行转义。其次，*Lua*中并不使用*'?'*来表示非贪婪匹配，而是定义了不同的字符来表示是否是贪婪匹配。定义如下：

|符号 |匹配次数                   |匹配模式                      |
| --- |---|---|
| + | 匹配前一字符 1 次或多次| 非贪婪                       |
| * | 匹配前一字符 0 次或多次| 贪婪                         |
| - | 匹配前一字符 0 次或多次| 非贪婪                       |
| ? | 匹配前一字符 0 次或1次 | 仅用于此，不用于标识是否贪婪 |

|符号|匹配模式     |
|--- |-------------|
| .  |任意字符     |
|%a  |字母         |
|%c  |控制字符     |
|%d  |数字         |
|%l  |小写字母     |
|%p  |标点字符     |
|%s  |空白符       |
|%u  |大写字母     |
|%w  |字母和数字   |
|%x  |十六进制数字 |
|%z  |代表 0 的字符|

-  *string.find* 的基本应用是在目标串内搜索匹配指定的模式的串。函数如果找到匹配的串返回他的开始索引和结束索引，否则返回 *nil*。*find*函数第三个参数是可选的：标示目标串中搜索的起始位置。当我们想实现一个迭代器时，可以传进上一次调用时的结束索引，如果返回了一个*nil*值的话，说明查找结束了.
  

```lua
local s = "hello world"
local i, j = {string.find(s, "hello")}
print(i, j) --> 1 5 
```

- 当然，我们也可以直接使用返回一个迭代器的函数：*string.gmatch(str, pattern)*

```lua
local s = "hello world from Lua" 
for w in string.gmatch(s, "%a+") do  
　print(w)  
end 
```

-  *string.gsub* 用来查找匹配模式的串，并将使用替换串其替换掉,但并不修改原字符串，而是返回一个修改后的字符串的副本，函数有目标串，模式串，替换串三个参数，使用范例如下：

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
print(string.gsub("a (enclosed (in) parentheses) line", "%b()", ""))    --> a line
```

-  常用的这种模式有：'%b()' ，'%b[]'，'%b%{%}' 和 '%b<>'。不过我们可以使用任何字符作为分隔符。

