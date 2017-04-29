# 非空判断

大家在使用 Lua 的时候，一定会遇到不少和 nil 有关的坑吧。有时候不小心引用了一个没有赋值的变量，这时它的值默认为 nil。如果对一个 nil 进行索引的话，会导致异常。

如下：

```lua
local person = {name = "Bob", sex = "M"}

-- do something
person = nil
-- do something

print(person.name)
```

上面这个例子把 nil 的错误用法显而易见地展示出来，执行后，会提示下面的错误：

```lua
stdin:1:attempt to index global 'person' (a nil value)
stack traceback:
   stdin:1: in main chunk
   [C]: ?
```

然而，在实际的工程代码中，我们很难这么轻易地发现我们引用了 nil 变量。因此，在很多情况下我们在访问一些 table 型变量时，需要先判断该变量是否为 nil，例如将上面的代码改成：

```lua
local person = {name = "Bob", sex = "M"}

-- do something
person = nil
-- do something
if person ~= nil and person.name ~= nil then
  print(person.name)
else
  -- do something
end
```

对于简单类型的变量，我们可以用 *if (var == nil) then* 这样的简单句子来判断。但是对于 table 型的 Lua 对象，就不能这么简单判断它是否为空了。一个 table 型变量的值可能是 `{}`，这时它不等于 nil。我们来看下面这段代码：

```lua
local next = next
local a = {}
local b = {name = "Bob", sex = "Male"}
local c = {"Male", "Female"}
local d = nil

print(#a)
print(#b)
print(#c)
--print(#d)    -- error

if a == nil then
	print("a == nil")
end

if b == nil then
	print("b == nil")
end

if c == nil then
	print("c == nil")
end

if d== nil then
	print("d == nil")
end

if next(a) == nil then
	print("next(a) == nil")
end

if next(b) == nil then
	print("next(b) == nil")
end

if next(c) == nil then
	print("next(c) == nil")
end
```

返回的结果如下：

```bash
0
0
2
d == nil
next(a) == nil
```

因此，我们要判断一个 table 是否为 `{}`，不能采用 `#table == 0` 的方式来判断。可以用下面这样的方法来判断：

```lua
function isTableEmpty(t)
    return t == nil or next(t) == nil
end
```

注意：`next` 指令是不能被 LuaJIT 的 JIT 编译优化，并且 LuaJIT 貌似没有明确计划支持这个指令优化，在不是必须的情况下，尽量少用。
