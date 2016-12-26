# 如何对 Nginx Lua module 添加新 api

本文真正的目的，绝对不是告诉大家如何在 Nginx Lua module 添加新 api 这么点东西。而是以此为例，告诉大家 Nginx 模块开发环境搭建、码字编译、编写测试用例、代码提交、申请代码合并等。给大家顺路普及一下 git 的使用。

目前有个应用场景，需要获取当前 Nginx worker 数量的需要，所以添加一个新的接口 ngx.config.workers()。由于这个功能实现简单，非常适合大家当做例子。废话不多说，let's fly now！

> 获取openresty默认安装包（辅助搭建基础环境）：

```sh
$ wget http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz
$ tar -xvf ngx_openresty-1.7.10.1.tar.gz
$ cd ngx_openresty-1.7.10.1
```

> 从 GitHub 上 fork 代码

* 进入[lua-nginx-module](https://github.com/openresty/lua-nginx-module)，点击右侧的 Fork 按钮
* Fork 完毕后，进入自己的项目，点击 Clone in Desktop 把项目 clone 到本地

> 预编译，本步骤参考[这里](http://openresty.com/#Installation)：

```sh
$ ./configure
$ make
```

`注意这里不需要make install`

> 修改自己的源码文件

```
# ngx_lua-0.9.15/src/ngx_http_lua_config.c
```

> 编译变化文件

```sh
$ rm ./nginx-1.7.10/objs/addon/src/ngx_http_lua_config.o
$ make
```

# 搭建测试模块
> 安装perl cpan [点击查看](http://www.cnblogs.com/itech/archive/2009/08/10/1542832.html)

```
$ cpan
cpan[2]> install Test::Nginx::Socket::Lua
```

> 书写测试单元

```
$ cat 131-config-workers.t
# vim:set ft= ts=4 sw=4 et fdm=marker:
use lib 'lib';
use Test::Nginx::Socket::Lua;

#worker_connections(1014);
#master_on();
#workers(2);
#log_level('warn');

repeat_each(2);
#repeat_each(1);

plan tests => repeat_each() * (blocks() * 3);

#no_diff();
#no_long_string();
run_tests();

__DATA__

=== TEST 1: content_by_lua
--- config
    location /lua {
        content_by_lua_block {
            ngx.say("workers: ", ngx.config.workers())
        }
    }
--- request
GET /lua
--- response_body_like chop
^workers: 1$
--- no_error_log
[error]
```

```
$ cat 132-config-workers_5.t
# vim:set ft= ts=4 sw=4 et fdm=marker:
use lib 'lib';
use Test::Nginx::Socket::Lua;

#worker_connections(1014);
#master_on();
workers(5);
#log_level('warn');

repeat_each(2);
#repeat_each(1);

plan tests => repeat_each() * (blocks() * 3);

#no_diff();
#no_long_string();
run_tests();

__DATA__

=== TEST 1: content_by_lua
--- config
    location /lua {
        content_by_lua_block {
            ngx.say("workers: ", ngx.config.workers())
        }
    }
--- request
GET /lua
--- response_body_like chop
^workers: 5$
--- no_error_log
[error]
```

# 单元测试

```sh
$ export PATH=/path/to/your/nginx/sbin:$PATH    #设置nginx查找路径
$ cd ngx_lua-0.9.15                     # 进入你修改的模块
$ prove t/131-config-workers.t          # 测试指定脚本
t/131-config-workers.t .. ok
All tests successful.
Files=1, Tests=6,  1 wallclock secs ( 0.04 usr  0.00 sys +  0.18 cusr  0.05 csys =  0.27 CPU)
Result: PASS
$
$ prove t/132-config-workers_5.t        # 测试指定脚本
t/132-config-workers_5.t .. ok
All tests successful.
Files=1, Tests=6,  0 wallclock secs ( 0.03 usr  0.00 sys +  0.17 cusr  0.04 csys =  0.24 CPU)
Result: PASS
```

# 提交代码，推动我们的修改被官方合并

* 首先把代码 commit 到 GitHub
* commit 成功后，以次点击 GitHub 右上角的 Pull request -> New pull request
* 这时候 GitHub 会弹出一个自己与官方版本对比结果的页面，里面包含有我们所有的修改，确定我们的修改都被包含其中，点击 Create pull request 按钮
* 输入标题、内容（you'd better write in english）, 点击 Create pull request 按钮
* 提交完成，就可以等待官方作者是否会被采纳了（代码 + 测试用例，必不可少）

来看看我们的成果吧：

pull request : [点击查看](https://gitHub.com/openresty/lua-nginx-module/pull/531)
commit detail: [点击查看](https://github.com/membphis/lua-nginx-module/commit/9d991677c090e1f86fa5840b19e02e56a4a17f86)
