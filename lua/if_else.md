#控制结构：if-else
if-else是我们熟知的一种控制结构。Lua 跟其他语言一样，提供了if-else的控制结构。因为是大家熟悉的语法，本节只简单介绍一下它的使用方法。
#### 单个 if 分支 型

```lua
x=10
if x>0 then
    print("x is a positive number")
end
--output:x is a positive number
```

#### 两个分支： if-else 型

```lua
x=10
if x>0 then
    print("x is a positive number")
else
    print("x is a non-positive number")
end
--output:x is a positive number
```

#### 多个分支： if-elseif-else型

```lua
score=90
if score==100 then
    print("Very good!Your score is 100")
elseif score>=60 then
    print("Congratulations, you have passed it,your score greater or equal to 60")
--此处可以添加多个elseif
else
    print("Sorry, you do not pass the exam! ")
end
--output:Congratulations, you have passed it,your score greater or equal to 60
```

与C语言的不同之处是elseif是连在一起的，若不else与if写成"else if"则相当于在else 里嵌套,如下代码：

```lua
score=0
if score==100 then
    print("Very good!Your score is 100")
elseif score>=60 then
    print("Congratulations, you have passed it,your score greater or equal to 60")
else
    if score>0 then  
        print("Your score is better than 0")
    else
        print("My God, your score turned out to be 0")
    end --此处要添加一个end
end
--output:My God, your score turned out to be 0
```
