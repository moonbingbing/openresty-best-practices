# Nginx 静态文件服务

Nginx 提供了强大的静态文件服务功能，利用 Nginx 的反向代理缓存以及静态文件压缩功能，
我们可以有效地提高静态文件服务的效率。

#### 反向代理缓存

什么是反向代理？我们知道正向代理是面向客户端的，用户主动使用代理软件连接到代理服务器，起到一个跳板的作用，一般可以用于内网访问外网或者“翻墙”。而反向代理则顾名思义是面向服务端的，用户并不知道我们 Nginx 反向代理服务器的存在，通过增加一层反向代理，对主服务器起到一个保护、缓冲和负载均衡的作用。

而Nginx作为知名的反向代理服务器软件，为我们封装了完备的反向代理功能，我们只需要在配置文件中做出少量的设置，就可以搭建一台反向代理服务器。下面我们给出一个典型的反向代理缓存的配置。

```nginx
http{
    //反向代理设置
    upstream realserver{
        server localhost:4321; #这里我们代理localhost的4321端口
    }
    proxy_connect_timeout 5;   #设置与被代理服务器建立连接的超时时间。
    proxy_read_timeout 60;     #设置接收一个被代理服务器请求的超时时间。
    proxy_send_timeout 5;      #设置传输一个请求到被代理服务器的超时时间。
    proxy_buffer_size 16k;     #设置缓冲区大小，若不设置，默认与内存页大小相同。
    proxy_busy_buffers_size 128k;  #当来自被代理服务器的应答缓冲被开启时，在应答没有被完全
                                   #读取时，限制被用于发送应答到客户端的缓冲区大小。可以简
                                   #单地理解成缓冲区上限。

    proxy_temp_file_write_size 128k;  #当缓冲区不够用时，设置限制一次写到临时文件中的大小。
    proxy_temp_path /tmp/proxy_temp_dir;  
    //代理缓存设置
    proxy_cache_path /tmp/proxy_cache_dir levels=1:2 keys_zone=cache_one:100m inactive=1d max_size=10g;
}

location / {
    ##代理设置
    proxy_pass http://realserver;                ##对应upstream后的名称
    proxy_setHeader Host $host;
    proxy_setheader X-Forwarded-For $remote_addr;

    ##代理缓存设置
    proxy_cache cache_one;                       ##对应proxy_cache_path中的keys_zone
    proxy_cache_valid 200 304 1d;                ##对于200及304的http页面缓存
    proxy_cache_key $host$uri$is_args$args;      ##缓存的key值
}
```

说明：
keys_zone=cache_one:100m 表示这个zone名称为cache_one，分配的内存大小为100MB  
/tmp/proxy_cache_dir 表示cache1这个zone的文件要存放的目录  
levels=1:2 表示缓存目录的第一级目录是1个字符，第二级目录是2个字符，即/usr/local/nginx/proxy_cache_dir/cache1/a/1b这种形式  
inactive=1d 表示这个zone中的缓存文件如果在1天内都没有被访问，那么文件会被cache manager进程删除掉  
max_size=10g 表示这个zone的硬盘容量为10GB  

上面这个例子主要是给大家介绍文件

#### Memcached缓存

计算机世界有个名言：计算机科学领域的任何问题都可以通过增加间接的中间件来解决。

如果上面的配置仍然不能满足你的应用对静态文件服务的需求的话，可以使用Nginx的memcached模块，形成一个三层的缓冲结构。被代理服务器-》Nginx反向代理缓存-》Nginxmemcached缓存。该模块已经被包含在Nginx的模块当中，需要在Nginx编译安装时，通过指定参数的方式来开启。  
这种方式有好处也有坏处，好处是：如果你的静态文件存储于不同的文件系统下（这在分布式的环境中很常见），那么由于memcached使用内存来进行文件缓存，一来可以避免文件系统的问题，二来内存速度远快于硬盘IO速度。
坏处是：memcached服务器如果宕掉，内存中的缓冲文件就会全部丢失。但是由于我们这个应用场景下，memcached只是被代理服务器的一个缓冲，所有静态文件在被代理服务器中都有备份，即使memcached服务器宕掉，被代理服务器中的静态文件不会有任何影响，所以这个方案几乎是只有好处没有坏处。




upstream memcacheds {
        server 127.0.0.1:11211;
}
server  {
        listen       8080;
        server_name  nm.ttlsa.com;
        index index.html index.htm index.php;
        root  /data/wwwroot/test.ttlsa.com/webroot;
 
        location /images/ {
                set $memcached_key $request_uri;
                add_header X-mem-key  $memcached_key;
                memcached_pass  memcacheds;
                default_type text/html;
                error_page 404 502 504 = @app;
        }
 
        location @app {
                rewrite ^/.* /nm_ttlsa.php?key=$request_uri;
        }
 
        location ~ .*\.php?$
        {
                include fastcgi_params;
                fastcgi_pass  127.0.0.1:10081;
                fastcgi_index index.php;
                fastcgi_connect_timeout 60;
                fastcgi_send_timeout 180;
                fastcgi_read_timeout 180;
                fastcgi_buffer_size 128k;
                fastcgi_buffers 4 256k;
                fastcgi_busy_buffers_size 256k;
                fastcgi_temp_file_write_size 256k;
                fastcgi_intercept_errors on;
                fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        }
}





#### 静态文件压缩


#### alias

在Nginx中配置proxy_pass时，如果是按照^~匹配路径时,要注意proxy_pass后的url最后的/,当加上了/，相当于是绝对根路径，则Nginx不会把location中匹配的路径部分代理走;如果没有/，则会把匹配的路径部分也给代理走。


（注：上面这个代码并没有走通，我只是先提交让大家看看我的工作进展）