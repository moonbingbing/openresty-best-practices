# 超时

当我们所有数据库的`SQL`语句是通过子查询方式完成，对于超时的控制往往很容易被大家忽略。因为大家在代码里看不到任何调用`set_timeout`的地方。实际上`PostgreSQL`已经为我们预留好了两个设置。

请参考下面这段配置：

```nginx
location /postgres {
    internal;

    default_type text/html;
    set_by_lua $query_sql 'return ngx.unescape_uri(ngx.var.arg_sql)';

    postgres_pass   pg_server;
    rds_json          on;
    rds_json_buffer_size 16k;
    postgres_query  $query_sql;
    postgres_connect_timeout 1s;
    postgres_result_timeout 2s;
}
```

生产中使用这段配置，遇到了一个不大不小的坑。在我们的开发机、测试环境上都没有任何问题的安装包，到了用户那边出现所有数据库操作异常，而且是数据库连接失败，但手工连接本地数据库，发现没有任何问题。同样的执行程序再次copy回来后，公司内环境不能复现问题。考虑到我们当次升级刚好修改了`postgres_connect_timeout`和`postgres_result_timeout`的默认值，所以我们尝试去掉了这两行个性设置，重启服务后一切都好了。

起初我们也很怀疑出了什么诡异问题，要知道我们的`nginx`和`PostgreSQL`可是安装在本机，都是使用`127.0.0.1`这样的 IP 来完成通信的，难道客户的机器在这个时间内还不能完成连接建立？

经过后期排插问题，发现是客户的机器上安装了一些趋势科技的杀毒客户端，而趋势科技为了防止无效连接，对所有连接的建立均阻塞了一秒钟。就是这一秒钟，让我们的服务彻底歇菜。

本以为是一次比较好的优化，没想到因为这个原因没能保留下来，反而给大家带来麻烦。只能说企业版环境复杂，边界比较多。但也好在我们一直使用最常见的技术、最常见的配置解决各种问题，让我们的经验可以复用到其他公司里。



