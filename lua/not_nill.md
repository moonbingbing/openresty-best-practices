# 非空判断

大家在使用Lua的时候，一定会遇到不少和nil有关的坑吧。有时候不小心引用了一个没有赋值的变量，这时它的值默认为nil。如果对一个nil进行索引的话，会导致异常。
如下：
```
local person = {name = "Bob", sex = "M"}

-- do something
person = nil
-- do something

print(person.name)
```
上面这个例子把nil的错误用法显而易见地展示出来，执行后，会提示这样的错误：
```
stdin:1:attempt to index global 'person' (a nil value)
stack traceback:
   stdin:1: in main chunk
   [C]: ?
```
然而，在实际的工程代码中，我们很难这么轻易地发现我们引用了nil变量。因此，在很多情况下我们在访问一些table型变量时，需要先判断该变量是否为nil，例如将上面的代码改成：
```
local person = {name = "Bob", sex = "M"}

-- do something
person = nil
-- do something
if (person ~= nil and person.name ~= nil) then
  print(person.name)
else
  -- do something
end
```

对于简单类型的变量，我们可以用 *if (var == nil) then* 这样的简单句子来判断。但是对于table型的Lua对象，就不能这么简单判断它是否为空了。一个table型变量的值可能是{}，这时它不等于nil。我们来看下面这段代码：
```
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

if c== nil then
	print("c == nil")
end

if d== nil then
	print("d == nil")
end

if _G.next(a) == nil then
	print("_G.next(a) == nil")
end

if _G.next(b) == nil then
	print("_G.next(b) == nil")
end

if _G.next(c) == nil then
	print("_G.next(c) == nil")
end

-- error
--if _G.next(d) == nil then
--	print("_G.next(d) == nil")
--end
```
返回的结果如下：
```
0
0
2
d == nil
_G.next(a) == nil
```
因此，我们要判断一个table是否为{},不能采用#table == 0的方式来判断。可以用下面这样的方法来判断：
```
function isTableEmpty(t)
	if t == nil or _G.next(t) == nil then
		return true
	else
		return false
	end
end
```
