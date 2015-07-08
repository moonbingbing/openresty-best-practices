#抵制使用module()函数来定义Lua模块

旧式的模块定义方式是通过*module("filename"[,package.seeall])*来显示声明一个包，现在官方不推荐再使用这种方式。这种方式将会返回一个由*mymodule*模块函数组成的*table*，并且还会定义一个包含该*table*的全局变量。

如果只给*module*函数一个参数（也就是文件名）的话，前面定义的全局变量就都不可用了，包括*print*函数等，如果要让之前的全局变量可见，必须在定义*module*的时候加上参数package.seeall。调用完*module*函数之后，print这些系统函数不可使用的原因，是当前的整个环境被压入栈，不再可达。

*module("filename", package.seeall)*这种写法仍然是不提倡的，官方给出了两点原因：

1.  *package.seeall*这种方式破坏了模块的高内聚，原本引入"filename"模块只想调用它的*foobar()*函数，但是它却可以读写全局属性，例如*"filename.os"*。

2.  *module*函数压栈操作引发的副作用，污染了全局环境变量。例如*module("filename")*会创建一个*filename*的*table*，并将这个*table*注入全局环境变量中，这样使得没有引用它的文件也能调用*helloworld*模块的方法。

比较推荐的模块定义方法是：
```lua
--定义一个用于复数计算的模块
local moduleName = ...

local M = {}    -- 局部的变量
_G[moduleName] = M     -- 将这个局部变量最终赋值给模块名

package.loaded[moduleName] = M  --将模块table直接赋值给package.loaded，避免了在模块文件末尾return语句的麻烦。

function M.new(r, i) return {r = r, i = i} end

-- 定义一个常量i
M.i = M.new(0, 1)

function M.add(c1, c2)
    return M.new(c1.r + c2.r, c1.i + c2.i)
end

function M.sub(c1, c2)
    return M.new(c1.r - c2.r, c1.i - c2.i)
end

--不用return M，因为前面已经将其载入package.loaded表中了

```

-  另一个跟lua的module模块相关需要注意的点是，每次require一个模块，这个模块的生命周期将会一直持续到该次回话(session)结束，或者直到被显式地调用如下语句：
```lua
package.loaded.yourModuleName = nil
```