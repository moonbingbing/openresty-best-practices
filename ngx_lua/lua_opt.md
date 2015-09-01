#网上有大量对Lua调优的推荐，我们应该如何看待？
Lua的解析器有官方的standard Lua和LuaJIT，需要明确一点的是目前大量的优化文章都比较陈旧，而且都是针对standard Lua解析器的，standard Lua解析器在性能上需要书写着自己规避，才能写出高性能来。需要各位看官注意的是，ngx-lua最新版默认已经绑定LuaJIT，优化手段和方法已经略有不同。我们现在的做法是：代码易读是首位，目前还没有碰到同样代码换个写法就有质的提升，如果我们对某个单点功能有性能要求，那么建议用LuaJIT的FFI方法直接调用C接口更直接一点。

代码出处：http://www.cnblogs.com/lovevivi/p/3284643.html

```
3.0 避免使用table.insert()

下面来看看4个实现表插入的方法。在4个方法之中table.insert()在效率上不如其他方法，是应该避免使用的。
使用table.insert
local a = {}
local table_insert = table.insert
for i = 1,100 do
   table_insert( a, i )
end

使用循环的计数

local a = {}
for i = 1,100 do
   a[i] = i
end
使用table的size

local a = {}
for i = 1,100 do
   a[#a+1] = i
end
使用计数器

local a = {}
local index = 1
for i = 1,100 do
   a[index] = i
   index = index+1
end

4.0 减少使用 unpack()函数
Lua的unpack()函数不是一个效率很高的函数。你完全可以写一个循环来代替它的作用。

使用unpack()

local a = { 100, 200, 300, 400 }
for i = 1,100 do
   print( unpack(a) )
end
代替方法

local a = { 100, 200, 300, 400 }
for i = 1,100 do
   print( a[1],a[2],a[3],a[4] )
end
```

针对这篇文章内容写了一些测试代码：

```
local start = os.clock()

local function sum( ... )
    local args = {...}
    local a = 0
    for k,v in pairs(args) do
        a = a + v
    end
    return a
end

local function test_unit(  )
    -- t1: 0.340182 s
    -- local a = {}
    -- for i = 1,1000 do
    --    table.insert( a, i )
    -- end

    -- t2: 0.332668 s
    -- local a = {}
    -- for i = 1,1000 do
    --    a[#a+1] = i
    -- end

    -- t3: 0.054166 s
    -- local a = {}
    -- local index = 1
    -- for i = 1,1000 do
    --    a[index] = i
    --    index = index+1
    -- end

    -- p1: 0.708012 s
    -- local a = 0
    -- for i=1,1000 do
    --     local t = { 1, 2, 3, 4 }
    --     for i,v in ipairs( t ) do
    --        a = a + v
    --     end
    -- end

    -- p2: 0.660426 s
    -- local a = 0
    -- for i=1,1000 do
    --     local t = { 1, 2, 3, 4 }
    --     for i = 1,#t do
    --        a = a + t[i]
    --     end
    -- end

    -- u1: 2.121722 s
    -- local a = { 100, 200, 300, 400 }
    -- local b = 1
    -- for i = 1,1000 do
    --    b = sum(unpack(a))
    -- end

    -- u2: 1.701365 s
    -- local a = { 100, 200, 300, 400 }
    -- local b = 1
    -- for i = 1,1000 do
    --    b = sum(a[1], a[2], a[3], a[4])
    -- end

    return b
end

for i=1,10 do
    for j=1,1000 do
        test_unit()
    end
end

print(os.clock()-start)
```

从运行结果来看，除了t3有本质上的性能提升（六倍性能差距，但是t3写法相当丑陋），其他不同的写法都在一个数量级上。你是愿意让代码更易懂还是更牛逼，就看各位看官自己的抉择了。不要盲信，也不要不信，各位要睁开眼自己多做测试。

另外说明：文章提及的使用局部变量、缓存table元素，在LuaJIT中还是很有用的。

todo：优化测试用例，让他更直观，自己先备注一下。