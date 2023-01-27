---
title: m1 macOS 使用 docker 安装 mysql 8.0.31
date: 2023/01/26 13:01:16
categories: 
- 博客
- 笔记
tags: 
- m1
- docker
- mysql
---

### 一、下载镜像

```shell
$ docker pull mysql:8.0.31-oracle
```

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20221017035914341.png" alt="image-20221017035914341" style="zoom: 33%;" />



### 二、启动

1. 创建自定义的 `docker` 网络

```shell
$ docker network create --subnet=172.31.7.0/24 customnet

# 查看自定义的 customnet 网络
$ docker network ls
NETWORK ID     NAME                                 DRIVER    SCOPE
137dcc3baf0b   bridge                               bridge    local
9952847bffe2   customnet                            bridge    local
```
<!--more-->
2. 指定 `network` 为 `customnet`，指定 `IP` 为 `172.31.7.90` 运行容器

```shell
# mysqld --lower_case_table_names=1 配置不区分表名的大小写
$ docker run -d --name mysql \
  --privileged=true \
  --restart always \
  --network customnet \
  --ip 172.31.7.90 \
  -p 3306:3306 \
  -v /Users/shuangyeying/.docker/mysql/log:/var/log/mysql \
  -v /Users/shuangyeying/.docker/mysql/data:/var/lib/mysql \
  -v /Users/shuangyeying/.docker/mysql/conf:/etc/mysql/conf.d \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -e TZ="Asia/Shanghai" \
  mysql:8.0.31-oracle \
  mysqld --lower_case_table_names=1
```

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20221017075002748.png" alt="image-20221017075002748" style="zoom: 33%;" />

3. 查看已经启动成功的容器

```shell
$ docker ps -a
CONTAINER ID   IMAGE                          COMMAND                  CREATED          STATUS          PORTS                                                                    NAMES
67f915a1ce2e   mysql:8.0.31-oracle            "docker-entrypoint.s…"   24 minutes ago   Up 24 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp                                        mysql

# 查看已经启动容器的 IP
$ docker inspect 67f915a1ce2e |grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.31.7.90",
```



### 三、调整 mysql 默认编码为 utf8mb4

1. 编辑 `/Users/shuangyeying/.docker/mysql/conf/mysqld.cnf`

```shell
$ vim /Users/shuangyeying/.docker/mysql/conf/mysqld.cnf

# mysqld.conf 配置如下
# 通过 sql_mode 关闭 ONLY_FULL_GROUP_BY 
[client]
default-character-set = utf8mb4 

[mysql]
default-character-set = utf8mb4

[mysqld]
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_bin
default-storage-engine = INNODB
max_allowed_packet = 1024M
innodb_log_file_size = 4GB
transaction-isolation = READ-COMMITTED
binlog_format = row
log_bin_trust_function_creators = 1
init_connect = 'SET NAMES utf8mb4'
```

2. 重启 `docker` 容器。

```shell
# 查看 mysql 
$ docker ps -a
CONTAINER ID   IMAGE                 COMMAND                  CREATED        STATUS          PORTS                               NAMES
1109bd232e6e   mysql:8.0.31-oracle   "docker-entrypoint.s…"   17 hours ago   Up 10 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp   mysql

# 重启 mysql
$ docker restart mysql      
mysql
```

3. 查看当前 mysql 编码。

```shell
# 进入到 docker 容器中
$ docker exec -it mysql /bin/bash

# 在容器中使用 mysql -uroot -p 连接 mysql
bash-4.4# mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.31 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

# 查看编码
# SHOW VARIABLES WHERE Variable_name LIKE 'character\_set\_%' OR Variable_name LIKE 'collation%'; 
mysql> SHOW VARIABLES WHERE Variable_name LIKE 'character\_set\_%' OR Variable_name LIKE 'collation%';
+--------------------------+-------------+
| Variable_name            | Value       |
+--------------------------+-------------+
| character_set_client     | utf8mb4     |
| character_set_connection | utf8mb4     |
| character_set_database   | utf8mb4     |
| character_set_filesystem | binary      |
| character_set_results    | utf8mb4     |
| character_set_server     | utf8mb4     |
| character_set_system     | utf8mb3     |
| collation_connection     | utf8mb4_bin |
| collation_database       | utf8mb4_bin |
| collation_server         | utf8mb4_bin |
+--------------------------+-------------+
10 rows in set (0.03 sec)

# 在启动 mysql 后，只关注下列变量是否符合我们的要求。
character_set_client
character_set_connection
character_set_database
character_set_results
character_set_server

# 下列两个系统变量不需要关心，不会影响乱码等问题。
character_set_filesystem
character_set_system

# 查看忽略大小写设置情况
mysql> show variables like '%table_names';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| lower_case_table_names | 1     |
+------------------------+-------+
1 row in set (0.00 sec)
```



### 四、创建 Confluence 数据库以及用户名

```shell
# 创建 Confluence 数据库
CREATE DATABASE confdb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

# show databases 可以查看创建出来的 confdb
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| confdb             |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

# 创建用户名
CREATE USER 'confuser'@'%' IDENTIFIED BY 'GUf2ySKHvu';
GRANT ALL PRIVILEGES ON *.* TO 'confuser'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

# select host,user from mysql.user; 查看 user 对应的 host
# 如下，confuser 对应的 host 为 %，表示对所有 IPv4 地址都生效
mysql> select host,user from mysql.user;
+-----------+------------------+
| host      | user             |
+-----------+------------------+
| %         | confuser         |
| %         | root             |
| localhost | mysql.infoschema |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
+-----------+------------------+
6 rows in set (0.00 sec)

# Confluence 要求设置事务级别为 READ-COMMITTED
set global transaction_isolation='READ-COMMITTED';
```



### 参考文档

https://confluence.atlassian.com/doc/database-setup-for-mysql-128747.html
