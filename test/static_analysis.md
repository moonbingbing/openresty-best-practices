# 代码静态分析

代码静态分析可以在不运行代码的情况下，提前检测代码。

主要可以做两点
1. 语法检测
2. 编码规范检测

作为开发人员，在日常编码中，难免会范一些低级错误，比如少个括号，少个逗号，使用了未定义变量等等，我们往往会使用编辑器的 lint 插件来检测此类错误。

对于我们 OpenResty 开发中，日常开发的都是 Lua 代码，所以我们可以使用 [luacheck](https://github.com/mpeterv/luacheck) 这款静态代码检测工具来帮助我们检查，比较好的一点是这款工具对 ngx_lua 做了一些支持，我们使用的 ngx 变量在开启了配置 `--std ngx_lua` 后即可被 luacheck 识别，而不会被认为是未定义的变量。

我们可以通过 luarocks 来安装:

```shell
➜ luarocks install luacheck
```

使用也很方便，只需要 `luacheck filename or directory` 即可。

```shell
$ luacheck src extra_file.lua another_file.lua
Checking src/good_code.lua               OK
Checking src/bad_code.lua                3 warnings

    src/bad_code.lua:3:23: unused variable length argument
    src/bad_code.lua:7:10: setting non-standard global variable embrace
    src/bad_code.lua:8:10: variable opt was previously defined as an argument on line 7

Checking src/python_code.lua             1 error

    src/python_code.lua:1:6: expected '=' near '__future__'

Checking extra_file.lua                  5 warnings

    extra_file.lua:3:18: unused argument baz
    extra_file.lua:4:8: unused loop variable i
    extra_file.lua:13:7: accessing uninitialized variable a
    extra_file.lua:14:1: value assigned to variable x is unused
    extra_file.lua:21:7: variable z is never accessed

Checking another_file.lua                2 warnings

    another_file.lua:2:7: unused variable height
    another_file.lua:3:7: accessing undefined variable heigth

Total: 10 warnings / 1 error in 5 files
```

当然你也可以指定一些参数来运行 luacheck，常见的有 std、ignore、globals 等，我们一般会必选上 `--std ngx_lua` 来识别 ngx_lua 的全局变量，具体的规则可以查看 [官方文档](http://luacheck.readthedocs.io/en/stable/cli.html#command-line-options)

除了使用命令行参数，luacheck 还支持使用配置文件的形式，这也是我们推荐的做法。luacheck 使用时会优先查找当前目录下的 `.luacheckrc` 文件，未找到则去上层目录查找，以此类推。所以我们可以在项目的根目录下放置一个我们配置好的 `.luacheckrc` 文件以便之后使用。

一个 `.luacheckrc` 大概是这样子的：
```lua
-- .luacheckrc 文件其实就是个 lua 代码文件
cache = true
std = 'ngx_lua'
ignore = {"_"}
-- 这里因为客观原因，定的比较松。如果条件允许，你可以去掉这些豁免条例。
unused = false
unused_args = false
unused_secondaries = false
redefined = false
-- top-level module name
globals = {
    -- 标记 ngx.header and ngx.status 是可以被写入的
    "ngx",
}

-- 因为历史遗留原因，我们代码里有部分采用了旧风格的 module(..., package.seeall)
-- 来定义模块。下面一行命令用于找出这一类文件，并添加豁免的规则。
-- find -name '*.lua' -exec grep '^module(' -l {} \; | awk '{ print "\""$0"\"," }'
local old_style_modules = {
    -- ...
}
for _, path in ipairs(old_style_modules) do
    files[path].module = true
    files[path].allow_defined_top = true
end

-- 对用了 busted 测试框架的测试文件添加额外的标准
files["test/*_spec.lua"].std = "+busted"

-- 不检查来自第三方的代码库
exclude_files = {
    "nginx/resty",
}
```

luacheck 也可以集成进编辑器使用，支持的有 Vim，Sublime Text，Atom，Emacs，Brackets。基本主流的编辑器都有支持。具体可以看相应的 [使用文档](https://github.com/mpeterv/luacheck#editor-support)，这里就不做说明了。

这里特别说一下的是，我们在项目中使用了 git pre-commit hooks 来进行静态检查，在 git commit 前会检测本次提交修改和新增的代码，判断是否通过了 luacheck 的检测，未通过会给出提示并询问是否退出这次 commit。这一切都是通过 git hooks 来做的，顾名思义我们的钩子是下在 commit 这个动作上的，只要进行了 commit 操作，就会触发我们的钩子。git 内置了一些钩子，不同的 git 操作会触发不同的钩子，这些钩子放在项目文件夹的 `.git/hooks/` 文件夹下，我们这里用到的是 pre-commit。

```shell
#!/usr/bin/env bash
lua_files=$(git status -s|awk '{if (($1=="M"||$1=="A") && $2 ~ /.lua$/)print $2;}')

if [[ "$lua_files" != "" ]]; then
    result=$(luacheck $lua_files)

    if [[ "$result" =~ .*:.*:.*: ]]; then
        echo "$result"
        echo ""
        exec < /dev/tty
        read -p "Abort commit?(Y/n)"

        if [[ "$REPLY" == y* ]] || [[ "$REPLY" == Y* ]]; then
            echo "Abort commit"
            exit 1
        fi
    fi
fi
```
