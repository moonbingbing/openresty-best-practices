# 局部变量

Lua中的局部变量要用*local*关键字来显示定义，不用local显示定义的变量就是全局变量：

```lua
g_var = 1         -- global var
local l_var = 2   -- local var
```

局部变量的生命周期是有限的，它的作用域仅限于声明它的块（block）。

>一个块是一个控制结构的执行体、或者是一个函数的执行体再或者是一个程序块（chunk）

我们可以通过下面这个例子来理解一下局部变量作用域的问题：

> 示例代码test.lua

```lua
x = 10
local i = 1         --程序块中的局部变量

while i <=x do
  local x = i * 2   --while循环体中的局部变量
  print(x)          --打印2, 4, 6, 8, ...
  i = i + 1
end

if i > 20 then
  local x           --then中的局部变量
  x = 20
  print(x + 2)      --如果i > 20 将会打印22，此处的x是局部变量
else
  print(x)          --打印10， 这里x是全局变量
end

print(x)            --打印10
```

使用局部变量的一个好处是，局部变量可以避免将一些无用的名称引入全局环境，避免全局环境的污染。另外，访问局部变量比访问全局变量更快。同时，由于局部变量出了作用域之后生命周期结束，这样可以被垃圾回收器及时释放。

>“尽量使用局部变量”是一种良好的编程风格

然而，我们在使用Lua时，很容易忘记加上“local”来定义局部变量，这时变量就会自动变成全局变量，很可能导致程序出现诡异的问题。那么我们怎么检测哪些变量是全局变量呢？我们如何防止全局变量导致的影响呢？下面给出一段代码，利用**元表**的技术来自动检查全局变量，并打印必要的调试信息：

> 自动检查全局变量的使用：

```lua
setmetatable(_G, {
     __newindex = function (t, k, v)
          print("attempt to write to undeclared variable: key=" .. k..", val="..v)
          print(debug.traceback())
          rawset(t, k, v)
     end
})
```

将上面这段代码放在原来的lua代码前面，就能检测出全局变量的使用。

```
setmetatable(_G, {
     __newindex = function (t, k, v)
          print("attempt to write to undeclared variable: key=" .. k..", val="..v)
          print(debug.traceback())
          rawset(t, k, v)
     end
})

x = 10
local i = 1         --程序块中的局部变量
if x < i then
  print("x < i")
else
  print(" x >= i")
end

-----output:
attempt to write to undeclared variable: key=x, val=10
stack traceback:
	C:\Users\qgr\Desktop\a.lua:4: in function <C:\Users\qgr\Desktop\a.lua:2>
	C:\Users\qgr\Desktop\a.lua:9: in main chunk
	[C]: ?
2
4
6
8
10
12
14
16
18
20
10
10
 ```

从上面这段代码的输出中，我们可以看到全局变量"x"被检测出来。这利用了元表的特性。想了解更多元表的内容，可以查看[元表](/lua/metatable)章节

>在Lua中，应该尽量让定义变量的语句靠近使用变量的语句，这也可以被看做是一种良好的编程风格。在C这样的语言中，强制程序员在一个块（或一个过程）的起始处声明所有的局部变量，所以有些程序员认为在一个块的中间使用声明语句是一种不良好地习惯。实际上，在需要时才声明变量并且赋予有意义的初值，这样可以提高代码的可读性。对于程序员而言，相比在块中的任意位置顺手声明自己需要的变量，和必须跳到块的起始处声明，大家应该能掂量哪种做法比较方便了吧？
