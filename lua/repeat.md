#repeat控制结构
Lua中的repeat控制结构类似于其他语言（如：C++语言）中的do-while，但是控制方式是刚好相反的。简单点说，执行repeat循环体后，直到until的条件为真时才结束，而其他语言（如：C++语言）的do-while则是当条件为假时就结束循环。
>以下代码将会形成死循环：

```lua
x=10
repeat
    print(x)
until false
--[[output:
10
...
此处输出无限个10
]]
```

>而在C++中的以下下代码，只会执行一次循环体

```cpp
#include<iostream>
int main()
{
    int x=10;
    do
    {
        std::cout<<x<<"\n";
    }
    while(false);
    return 0;
}
//output :10
```

除此之外，repeat与其他语言的do-while基本是一样的。当然，Lua中的repeat也可以在使用break退出。
