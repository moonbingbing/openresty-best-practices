# location 匹配规则

### 语法规则

>```nginx
> location [=|~|~*|^~]  /uri/  { … }
>```

| 序号 | 模式 | 含义 |
|:---:|---|---|
| 1 | location =  /uri| `=` 表示 **精确匹配**，只有完全匹配上才能生效 |
| 2 | location ^~ /uri| `^~` 开头表示对 URL 路径进行 **前缀匹配**，发生在 **正则匹配** <font color=red>之前</font> |
| 3 | location ~ pattern  | **正则匹配**，`~` 开头表示 **区分** 大小写 |
| 3 | location ~* pattern | **正则匹配**，`~` 开头表示 **不区分** 大小写 |
| 4 | location /uri| 不带任何修饰符，同样也表示 **前缀匹配**，但是在 **正则匹配** <font color=red>之后</font> |
| 5 | location /| **通用匹配**，任何未匹配到其他 location 的请求都会匹配到，<br>相当于 switch 中的 default |

**注意**： 前缀匹配时，Nginx 不对 url 做编码，因此请求为 `/static/20%/aa` 时，可以被规则 `^~ /static/ /aa` 匹配到（注意是空格）。

### 匹配顺序

存在多个 location 配置块的情况下，匹配顺序如下：
> (参考资料而来，还未实际验证，试试就知道了，不必拘泥，仅供参考)

- (1) 首先，**精确匹配** `=`
- (2) 其次，**前缀匹配** `^~`
- (3) 再次，按文件中书写顺序的 **正则匹配**
- (4) 然后，匹配不带任何修饰符的 **前缀匹配**
- (5) 最后，交给 `/` **通用匹配**
- (6) 当有匹配成功时，停止匹配，按当前匹配规则处理请求


**注意**：前缀匹配，如果有包含关系时，按最大匹配原则执行。
比如存在前缀匹配：`location /dir01` 与 `location /dir01/dir02`，现在有请求 `http://localhost/dir01/dir02/file` 最终将匹配到 `location /dir01/dir02`。

例子，有如下匹配规则：
```nginx
location = / {
   echo "规则A";
}
location = /login {
   echo "规则B";
}
location ^~ /static/ {
   echo "规则C";
}
location ^~ /static/files {
	echo "规则X";
}
location ~ \.(gif|jpg|png|js|css)$ {
   echo "规则D";
}
location ~* \.png$ {
   echo "规则E";
}
location /img {
	echo "规则Y";
}
location / {
   echo "规则F";
}

```

那么产生的效果如下：

* (1) 访问根目录 `/`，比如 `http://localhost/` 将匹配 `规则 A`。
* (2) 访问 `http://localhost/login` 将匹配 `规则 B`，
      `http://localhost/register` 则匹配 `规则 F`。
* (3) 访问 `http://localhost/static/a.html` 将匹配 `规则 C`。
* (4) 访问 `http://localhost/static/files/a.exe` 将匹配 `规则 X`。
      虽然 `规则 C` 也能匹配到，但因为 **最大匹配原则**，最终选中了 `规则 X`。
      你可以测试下，去掉`规则 X` ，则当前 URL 会匹配上 `规则 C`。
* (5) 访问 `http://localhost/a.gif`, `http://localhost/b.jpg` 将匹配 `规则 D` 和 `规则 E` 。
      因为 `规则 D` **顺序优先**，所以 `规则 E` 不起作用。
      而 `http://localhost/static/c.png` 则优先匹配到 `规则 C`。
* (6) 访问 `http://localhost/a.PNG` 则匹配 `规则 E`，而不会匹配 `规则 D`，因为 `规则 E` 不区分大小写。
* (7) 访问 `http://localhost/img/a.gif` 会匹配 `规则 D`。
      虽然 `规则 Y` 也可以匹配上，但是因为 **正则匹配优先**，而忽略了 `规则 Y`。
* (8) 访问 `http://localhost/img/a.tiff` 会匹配上 `规则 Y`。

* (9) 访问 `http://localhost/category/id/1111` 则最终匹配到 `规则 F`。
      因为以上规则都不匹配，这个时候应该是 Nginx 转发请求给后端应用服务器，比如 FastCGI (php)，tomcat (jsp)，Nginx 作为反向代理服务器存在。

### 三个匹配规则

综上，所以在实际使用中，笔者觉得至少有三个匹配规则定义，如下：

- **第一个必选规则**
    > 直接匹配网站根，通过域名访问网站首页比较频繁，使用这个会加速处理，官网如是说。
    > 这里是直接转发给后端应用服务器了，也可以是一个静态首页。
    ```
    location = / {
        proxy_pass http://tomcat:8080/index
    }
    ```

- **第二个必选规则**
    > 处理静态文件请求，这是 nginx 作为 http 服务器的强项。
    > 有两种配置模式，**目录匹配** 和 **后缀匹配**，任选其一或搭配使用。
    ```
    location ^~ /static/ {
        root /webroot/static/;
    }
    location ~* \.(gif|jpg|jpeg|png|css|js|ico)$ {
        root /webroot/res/;
    }
    ```

- **第三个必选规则**
    > 即通用规则，用来转发动态请求到后端应用服务器。
    > 非静态文件请求就默认是动态请求，自己根据实际把握
    > 毕竟目前的一些框架的流行，带 `.php`、`.jsp` 后缀的情况很少了。
    ```
    location / {
        proxy_pass http://tomcat:8080/
    }
    ```

### rewrite 语法

- 1、 常用的 flag
    - last          – 基本上都用这个 flag
    - break         – 中止 rewrite，不再继续匹配
    - redirect      – 返回临时重定向的 HTTP 状态 302
    - permanent     – 返回永久重定向的 HTTP 状态 301

- 2、下面是可以用来判断的表达式：
    - `-f` 和 `!-f` 用来判断是否存在 **文件**
    - `-d` 和 `!-d` 用来判断是否存在 **目录**
    - `-e` 和 `!-e` 用来判断是否存在 **文件或目录**
    - `-x` 和 `!-x` 用来判断文件是否 **可执行**

- 3、下面是可以用作判断的全局变量
    例：http://localhost:88/test1/test2/test.php?k=v

    ```nginx
    $host：localhost
    $server_port：88

    $request_uri：/test1/test2/test.php?k=v
    $document_uri：/test1/test2/test.php

    $document_root：D:\nginx/html
    $request_filename：D:\nginx/html/test1/test2/test.php
    ```

### redirect 语法

```nginx
server {
    listen 80;
    server_name start.igrow.cn;

    index index.html index.php;
    root html;

    if ($http_host !~ "^star\.igrow\.cn$") {
        rewrite ^(.*) http://star.igrow.cn$1 redirect;
    }
}
```

### 防盗链

```nginx
location ~* \.(gif|jpg|swf)$ {
    valid_referers none blocked start.igrow.cn sta.igrow.cn;
    if ($invalid_referer) {
       rewrite ^/ http://$host/logo.png;
    }
}
```

### 根据文件类型设置过期时间

```nginx
location ~* \.(js|css|jpg|jpeg|gif|png|swf)$ {
    if (-f $request_filename) {
        expires 1h;
        break;
    }
}
```

### 禁止访问某个目录

```nginx
location ~* \.(txt|doc)$ {
    root /data/www/wwwroot/linuxtone/test;
    deny all;
}
```

一些可用的全局变量，可以参考 [获取 Nginx 内置绑定变量](../openresty/inline_var.md) 章节。
