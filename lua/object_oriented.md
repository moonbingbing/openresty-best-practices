# Lua面向对象编程

#### 类

在 Lua 中，我们可以使用表和函数实现面向对象。将函数和相关的数据放置于同一个表中就形成了一个对象。

请看文件名为 `account.lua` 的源码，这是账户：

```Lua
local _M = {}

local mt = { __index = _M }

function _M.deposit (self, v)  
	self.balance = self.balance + v
end

function _M.withdraw (self, v) 
	if self.balance > v then
		self.balance = self.balance - v
	else
		error("insufficient funds")
	end
end

function _M.new (self, balance) 
	balance = balance or 0
	setmetatable({balance = balance}, mt)
	return o
end

return _M
```

```
local account = require("account")

local a = account:new()
a:deposit(100)

local b = account:new()
b:deposit(50)

print(a.balance)  -->100
print(b.balance)  -->50
```

上面这段代码 "setmetatable({balance = balance}, mt)"， 其中 mt 代表 `{ __index = _M }` ，这句话值得注意。根据我们在元表这一章学到的知识，我们明白，setmetatable 将 _M 作为新建表的原型，所以在自己的表内找不到 'deposit'、'withdraw' 这些方法和变量的时候，便会到 \_\_index 所指定的 _M 类型中去寻找。

#### 继承

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

#### 多重继承

FIXME 这个继承的实现通用性不好，没有太大的实用价值。更合理的做法是使用级联 __index 元方法。让子类 B 的元表 b 使用父类 A 的元表 a 作为其自身的 `__index` 元表。

FIXME 多重继承引入的麻烦比解决的问题还要多，我们还是不要在本书中介绍了。

多重继承肯定不能采用我们在单继承中的所使用的方法，因为直接采用setmetatable的方式，会造成metatable的覆盖。
在多重继承中，我们自己利用 '\_\_index' 元方法定义恰当的访问行为。

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

解释一下上面的代码。我们定义了一个通用的创建多重继承类的函数'createClass'，这个函数可以接受多个类。如何让我们新建的多重继承类恰当地访问从不同类中继承来的函数或者成员变量呢？
我们就用到了'search'函数，该函数接受两个参数，第一个参数是想要访问的类成员的名字，第二个参数是被继承的类列表。
通过一个for循环在列表的各个类中寻找想要访问成员。

我们再定一个新类，来验证'createClass'的正确性。

```Lua
Named = {}
function Named:getname ()
	return self.name
end
function Named:setname (n)
	self.name = n
end

NamedAccount = createClass(Account, Named)   --同时继承Account 和 Named两个类
account = NamedAccount:new{name = "Paul"}    --使用这个多重继承类定义一个实例
print(account:getname())          --> Pauls
account:deposit(100)
print(account.balance)            --> 100
```

#### 成员私有性

在面向对象当中，如何将成员内部实现细节对使用者隐藏，也是值得关注的一点。在 Lua 中，成员的私有性，使用类似于函数闭包的形式来实现。在我们之前的银行账户的例子中，我们使用一个工厂方法来创建新的账户实例，通过工厂方法对外提供的闭包来暴露对外接口。而不想暴露在外的例如balace成员变量，则被很好的隐藏起来。

```Lua
function newAccount (initialBalance)
	local self = {balance = initialBalance}
	local withdraw = function (v)
		self.balance = self.balance - v
	end
	local deposit = function (v)
		self.balance = self.balance + v
	end
	local getBalance = function () return self.balance end
	return {
		withdraw = withdraw,
		deposit = deposit,
		getBalance = getBalance
	}
end

a = newAccount(100)
a.deposit(100)
print(a.getBalance()) --> 200
print(a.balance)      --> nil
```

注：在动态语言中引入成员私有性并没有太大的必要，反而会显著增加运行时的开销，毕竟这种检查无法像许多静态语言那样在编译期完成。下面的技巧把对象作为各方法的 upvalue，本身是很巧妙的，但会让子类继承变得困难，同时构造函数动态创建了函数，会导致构造函数无法被 JIT 编译。


