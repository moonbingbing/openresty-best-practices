# 集群功能
kong是基于openresty开发的，简单来说就是Nginx+lua，Nginx本身并没有提供集群功能，因此，kong团队选择了第三方软件来实现[serf](https://www.serf.io/)，serf可以提供足够轻量、健壮的集群功能。