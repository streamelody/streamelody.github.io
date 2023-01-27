---
title: Mac 使用 Docker 搭建 Oracle 12.2 数据库
date: 2018/08/11 19:01:12
categories:
- 博客
- 笔记
tags: 
- docker
- oracle
---

### 一、安装 Docker

1. 下载并安装 [Docker Community Edition for Mac](https://store.docker.com/editions/community/docker-ce-desktop-mac)。
<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_01.png" width="584"/>

2. 下载并安装 [Kitematic](https://github.com/docker/kitematic/releases)。

3. 可以使用 `docker info` 进行检查。

```shell
docker info
```

<!--more-->

### 二、部署 Oracle Docker 的 Build File

1. 下载 Build File：[docker-images-master.zip. 

2. 解压到 `~/iDocker` 目录下

3. 下载 [linuxx64_12201_database.zip](https://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html)
<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_02.png" width="533"/>

4. 解压之后放在

 `~/.iDocker/docker-images-master/OracleDatabase/SingleInstance/dockerfiles/12.2.0.1` 文件夹下。

### 三、部署 Oracle 数据库在 Docker 中

1. 终端中使用以下命令。

```shell
cd ~/.iDocker/docker-images-master/OracleDatabase/SingleInstance/dockerfiles/12.2.0.1
./buildDockerImage.sh -v 12.2.0.1 -e
```

2. 安装过程中需要联网， 大概需要15分钟左右。
<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_03.png" style="zoom:50%;" />  

3. 可以使用 `docker images` 查看安装情况。
<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_04.png" style="zoom:50%;" />  

### 四、安装 Oracle 实例在 Docker 中
1. 终端中使用以下命令。

```shell
docker run --name oracle -p 1521:1521 -p 5500:5500 -v ~/oradata:/opt/oracle/oradata oracle/database:12.2.0.1-ee

# 附一个安装 oracle 11g 的命令
docker pull jaspeen/oracle-11g
docker run --privileged --name oracle11g -p 1521:1521 -p 5500:5500 --restart always -v ~/.docker/oracle:/install -v ~/.docker/oracle/oradata:/opt/oracle/oradata jaspeen/oracle-11g
```

2. 注意：ORACLE_SID 默认值 `ORCLCDB`，ORACLE_PDB 默认值 `ORCLPDB1`。


3. 出现下面这里会一直卡住。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_05_01.png" style="zoom:50%;" /> 

4. 另外开启一个终端，输入 `docker stop oracle` 即可完成安装。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_05.png" style="zoom:50%;" /> 

5. 密码可以在终端搜索 `SYSTEM AND PDBADMIN` 得到。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_06.png" style="zoom:50%;" /> 

### 五、使用 IDEA 连接 Oracle 数据库
1. 开启 Oracle。

```shell
docker stop oracle
docker start oracle
```

2. 修改数据库默认密码。

```shell
docker exec oracle ./setPassword.sh XXXXXX
```

3. 使用 IDEA 进行连接。
<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_docker_oracle/mac_docker_oracle_07.png" style="zoom:50%;" /> 

### 参考文章

1. [在MAC上安装docker并部署oracle12.2](https://oracleblog.org/study-note/how-to-deploy-122-on-docker-on-mac/#comment-9330)
2. [How to Create an Oracle Database Docker Image](https://dzone.com/articles/creating-an-oracle-database-docker-image)
3. [使用Docker安装oracle 11g](http://www.thxopen.com/linux/docker/2019/04/17/install-oracle11g-on-docker)
