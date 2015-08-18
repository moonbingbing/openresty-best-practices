nginx中location之间的配合，主要是通过rewrite指令来进行的。
有这些指令会与rewrite指令协同使用：set、if、return、break。
rewrite的基本规则如下：

> 语法:	rewrite regex replacement [flag];

> 上下文环境:	server, location, if

* rewrite指令的执行流程

因为server区块可以有多条rewrite指令。当rewrite指令在server区块时，会逐代码地
检查是否匹配。在检测到匹配之后，rewrite指令在server区块最先执行且仅执行一次，
会重定向到指明的replacement地址，然后判断是否被某个location块捕获。
如果被某个location块捕获，则继续执行location块中的rewrite指令，执行完成之后，
倘若没有用break等语句停止该过程的话，则会不断地重复rewrite -> locatio ->
rewrite -> location这样的操作。这样的循环会重复10次，10次之后，会返回一个500代码。


rewrite指令的flag可以设置为break、last、redirect、permanent。在nginx的wike官方文档中介绍：
* last 停止当前rewrite指令，并且用更改后的URI在配置文件中搜寻相应的location匹配。
* break 停止当前rewrite指令，但是继续执行除了rewrite之外的指令。
* redirect 如果replament不是以 "http://" 或者 "https://" 开头的话，那么返回
一个302临时重定向。
* permanent 返回一个301永久重定向。


```shell
location /download/ {
  rewrite  ^(/download/)/audio/(.*)\..*$  $1/mp3/$2.mp3  break;
  rewrite  ^(/download/)/movie/(.*)\..*$  $1/mkv/$2.mkv  break;
  rewrite  ^(/download/)/image/(.*)\..*$  $1/jpg/$2.jpg  break;
}
```

```shell
location /download/ {
  rewrite  ^(/download/)/audio/(.*)\..*$  $1/mp3/$2.mp3  last;
  rewrite  ^(/download/)/movie/(.*)\..*$  $1/mkv/$2.mkv  last;
  rewrite  ^(/download/)/image/(.*)\..*$  $1/jpg/$2.jpg  last;
}
```

我们用 `/download/moive/test.avi` 来向服务器发起请求。

当我们使用last时: 在第2行rewrite处终止,并重试location /download，程序陷入循环，
在循环10次之后，返回一个500代码。  

当我们使用break时: 在第2行rewrite处终止,其结果为最终的rewrite地址，成功取回数据。

rewrite指令有如下两点值得注意的细节：
1. rewrite只对相对路径进行匹配,不包含hostname。  
使用相对路径rewrite时,会根据HTTP header中的HOST跟nginx的server_name匹配后进行rewrite,如果HOST不匹配或者
没有HOST信息的话则rewrite到server_name设置的第一个域名,如果没有设置
server_name的话,会使用本机的localhost进行rewrite。

2. 前面提到过,rewrite的正则是不匹配query string的,所以默认情况下,query string是自动追加到rewrite后的地址上的,如果不想自动追加query string,
则在rewrite地址的末尾添加?。
