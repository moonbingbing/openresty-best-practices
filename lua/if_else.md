#控制结构：if-else
if-else是我们熟知的一种控制结构。Lua 跟其他语言一样，提供了if-else的控制结构。因为是大家熟悉的语法，本节只简单介绍一下它的使用方法。
#### 单个 if 分支 型
```lua
if expression then
    block
end
```
#### 两个分支： if-else 型
```lua
if expression then
    block1
else
    block2
end
```
#### 多个分支： if-elseif-else型
```lua
if expression1 then
    block1
elseif expression2 then
    block2
--此处可以添加多个elseif
else
    block3
end
```

与C语言的不同之处是elseif是连在一起的，若不else与if写成"else if"则相当于在else 里嵌套,如下代码：
```lua
if expression1 then
    block1
elseif expression2 then
    block2
else
    if expresion3 then  
        block3
    else
        block4
    end --此处要添加一个end
end
```
