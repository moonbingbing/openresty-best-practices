# PostgresNginxModule

PostgreSQL 是加州大学博客利分校计算机系开发的对象关系型数据库管理系统(ORDBMS)，目前是免费开源的，且是全功能的自由软件数据库。
PostgreSQL 支持大部分 SQL 标准，其特性覆盖了 SQL-2/SQL-92 和 SQL-3/SQL-99，并且提供了许多其他现代特点，如复杂查询、外键、触发器、视图、事务完整性、多版本并行控制系统（MVCC）等。
PostgreSQL 可以使用许多方法扩展，比如，通过增加新的数据类型、函数、操作符、聚集函数、索引方法、过程语言等。

PostgreSQL 在灵活的 BSD 风格许可证下发行，任何人都可以根据自己的需要免费使用、修改和分发 PostgreSQL，不管是用于私人、商业、还是学术研究。

ngx\_postgres 是一个提供 nginx 与 PostgreSQL 直接通讯的 upstream 模块。应答数据采用了 rds 格式,所以模块与 ngx\_rds\_json 和 ngx\_drizzle 模块是兼容的。

