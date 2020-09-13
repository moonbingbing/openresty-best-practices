# Lua 编辑器选择

一个好用趁手的编辑器可以为我们带来极大的工作效率提升，Lua 本身并不挑编辑器，程序文件只是一个纯文本。
但是如果能有代码提示，方便的 goto 跳转，在我们理解别人的代码效率上将会有极大的提升。

我从最初的记事本编辑，vi，到后来的 UE 自定义语法高亮和函数列表，以及 scite 等，寻找和尝试过能找到的绝大部分的 Lua 编辑器。
我想在编辑器选择上面 (Linux 下的不熟= =) 应该比较有发言权。 这里我主要讲我的环境是如何配置的。

选择过程我就不详述了，这里只讲解如何在你自己的 Windows 上配置好 IDE。

#### 下载 IDEA 并配置

IDEA 是一个在 Java 语言开发者中广受好评的编辑器，但是并不是只支持 Java。

目前通过开放的插件机制已经支持绝大部分语言且非常地好用顺手，相信使用过的都会有深切感受的。[下载地址](https://www.jetbrains.com/idea/download/#section=windows)

其中 Community 版本是免费的，下载完后双击安装即可。

安装完成后打开 File->Settings->Plugins 在其中输入 Emmylua 点击右边的 install 安装并重启 IDEA。

![](../images/installplugins.png)

新建一个 Lua 项目
在 File->Project Structure 里面配置好 modules 和 lib，如下图。

![](../images/lua_settingmodules.png)

![](../images/lua_importlib.png)

至此一个包含 Lua 语法提示和调试的编辑器环境就配置好了。

有关 Emmylua 的详细帮助文档请看 [这里](https://emmylua.github.io/zh_CN/)

#### 插件基本用法
**1. 方法提示**

你可以在 Setting 里面配置鼠标移动到方法上之后，自动弹出其相关说明的延迟时间

![](../images/lua_quickdoc.png)

也可以按 Ctrl+q 手动弹出，效果如下 (= =目前我使用的版本文档中的换行显示还有问题)
![](../images/lua_quickdocui.png)


**2. 快速跳转**

在任何已经被定义的方法上按住 Ctrl+鼠标点击该方法就可以自动打开和跳转到方法定义上面，非常方便。


**3. 方法提示**

在你输入识别的全局或者局部变量上面按点会自动出现可选方法作为提示，不用记住所有的方法。

![](../images/lua_autofunc.png)


#### 进阶配置
由于 Emmylua 并没有自带 OpenResty 的库函数，所以我们需要自己写函数提示，这里我提供自己写的供你们 [下载](/codes/emmylua_ngx.lua) 和丰富。 请使用“右键-->另存为”方式下载，然后丢到你的 lualib 根目录中。

下面是一个简单的库函数定义示例：

```lua
---语法: pid = ngx.worker.pid()
---
---语法: set_by_lua*， rewrite_by_lua*， access_by_lua*， content_by_lua*， header_filter_by_lua*， body_filter_by_lua*， log_by_lua*， ngx.timer.*， init_by_lua*， init_worker_by_lua*
---
---这个函数返回一个 Lua 数字，它是当前 Nginx 工作进程的进程 ID （PID）。 这个 API 比 ngx.var.pid 更有效，ngx.var.VARIABLE API 不能使用的地方（例如 init_worker_by_lua），该 API 是可以的。
---@return number
function ngx.worker.pid()
end
```

方法提示不一定要使用独立的文件定义，可以直接在库里面定义，如:
![](../images/lua_func.png)

至于里面的含义就要去 [这里](https://emmylua.github.io/zh_CN/) 看和理解啦。

总之，如果你的库都定义好了方法提示，在你理解源码的时候将会非常方便快速。 相信我。

