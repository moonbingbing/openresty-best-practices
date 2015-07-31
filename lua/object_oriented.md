#Lua面向对象编程

####类
在 Lua 中，我们可以使用表和函数实现面向对象。将函数和相关的数据放置于同一个表中就形成了一个对象。

```Lua
Account = {balance = 0}
function Account:deposit (v)  --注意，此处使用冒号，可以免写self关键字；如果使用.号，第一个参数必须是self
	self.balance = self.balance + v
end

function Account:withdraw (v)  --注意，此处使用冒号，可以免写self关键字；
	if self.balance > v then
		self.balance = self.balance - v
	else
		error("insufficient funds")
	end
end

function Account:new (o)  --注意，此处使用冒号，可以免写self关键字；
	o = o or {}  -- create object if user does not provide one
	setmetatable(o, {__index = self})
	return o
end

a = Account:new()
a:deposit(100)
b = Account:new()
b:deposit(50)
print(a.balance)  -->100
print(b.balance)  -->50
--本来笔者开始是自己写的例子，但发现的确不如lua作者给的例子经典，所以还是沿用作者的代码。
```

上面这段代码"setmetatable(o, {\_\_index = self})"这句话值得注意。根据我们在元表这一章学到的知识，我们明白，setmetatable将Account作为新建'o'表的原型，所以当o在自己的表内找不到'balance'、'withdraw'这些方法和变量的时候，便会到__index所指定的Account类型中去寻找。

####继承
继承可以用元表实现，它提供了在父类中查找存在的方法和变量的机制。

```Lua
--定义继承
--定义继承
SpecialAccount = Account:new({limit = 1000}) --开启一个特殊账户类型，这个类型的账户可以取款超过余额限制1000元
function SpecialAccount:withdraw (v)
	if v - self.balance >= self:getLimit() then
		error("insufficient funds")
	end
	self.balance = self.balance - v
end

function SpecialAccount:getLimit ()
	return self.limit or 0
end

spacc = SpecialAccount:new()
spacc:withdraw(100)
print(spacc.balance)  --> -100
acc = Account:new()
acc:withdraw(100)     --> 超出账户余额限制，抛出一个错误
```

####多重继承

多重继承肯定不能采用我们在单继承中的所使用的方法，因为直接采用setmetatable的方式，会造成metatable的覆盖。
在多重继承中，我们自己利用'\_\_index'元方法定义恰当的访问行为。

```Lua
local function search (k, plist)
	for i=1, table.getn(plist) do
	local v = plist[i][k]  -- try 'i'-th superclass
	if v then return v end
	end
end

function createClass (...)
	local c = {} -- new class
	-- class will search for each method in the list of its
	-- parents (`args' is the list of parents)
	args = {...}
	setmetatable(c, {__index = function (self, k)
		return search(k, args)
	end})

	-- prepare `c' to be the metatable of its instances
	c.__index = c

	-- define a new constructor for this new class
	function c:new (o)
		o = o or {}
		setmetatable(o, c)
		return o
	end
	-- return new class
	return c
end
```
