#break,return 关键字
####break
break用来终止while,repeat,for三种循环的执行，并跳出当前循环体，继续执行当前循环之后的语句。下面举一个while循环中的break的例子来说明：

```lua
--计算最小的x,使从1到x的所有数相加和大于100
sum = 0
i = 1
while true do
    sum = sum + i
    i = i + 1;
    if sum > 100 then
        break
    end
end
print("答案是 "..i)
```
运行结果如下：
答案是 15


在实际应用中，break经常用于嵌套循环中。

####return
return主要用于从函数中返回一个或多个值，相关的细节可以参考[函数的返回值](lua/function_result.md)章节。return只能写在最后的语句块，一旦执行了return语句，该语句之后的所有语句都不会再执行。若要写在函数中间，则只能写在一个显式的语句块内，参见示例代码：

```lua
function add(x, y)
    return x + y
    --print("add: I will return the result "..(x+y)) --因为前面有个return，若不注释该语句，则会报错
end
function is_positive(x)
    if x > 0 then
        return x.." is positive"
    else
        return x.." is non-positive"
    end
    print("function end!")--由于return只出现在前面显式的语句块，所以此语句不注释也不会报错，但是不会被执行，此处不会产生输出
end
sum = add(10, 20)
print("The sum is "..sum)
answer = is_positive(-10);
print(answer)
```

>运行结果如下：
The sum is 30
-10 is non-positive
