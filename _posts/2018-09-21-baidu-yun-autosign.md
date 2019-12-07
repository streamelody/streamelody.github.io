---
title: Ubuntu 16.0.4 安装百度云签到
date: 2018/09/21 18:11:53
categories: 
- 博客
- 随笔
tags: 
- 百度云
- VPS
---

① 安装 Docker 和 Docker Compose。

```shell
# 安装必要的一些系统工具
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# 安装 GPG 证书
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# 更新并安装 Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce
# 设置开机启动
sudo systemctl enable docker
sudo systemctl start docker
# 把当前用户加入 Docker 组
sudo groupadd docker
sudo usermod -aG docker $USER
sudo service docker restart
# 查看 Docker 服务是否启动
systemctl status docker
# 测试 Docker 
docker run hello-world
# 安装 Docker Compose
sudo curl -L https:/github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# 为 Compose 安装命令行自动补全功能
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.23.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
```

<!--more-->

② 下载 docker-compose.yml 并启动服务。

```shell
wget https://raw.githubusercontent.com/zsnmwy/Tieba-Cloud-Sign/master/docker-compose.yml
# 修改配置使得 docker 容器自启
vim docker-compose.yml
# 以下为 docker-compose.yml 配置
version: '3'
services:

  web:
    image: "zsnmwy/tieba-cloud-sign"
    restart: always
    environment:
      DB_HOST: db:3306
      DB_USER: root
      DB_PASSWD: janejane123456
      DB_NAME: tiebacloud
      CSRF: "true"
    ports:
      - "8080:8080"
    links:
      - db
    depends_on:
      - db


  db:
    image: "mysql:5.5"
    restart: always
    environment:
      MYSQL_DATABASE: tiebacloud
      MYSQL_ROOT_PASSWORD: janejane123456
    volumes:
      - /opt/tieba/mysql:/var/lib/mysql
# 启动容器
docker-compose up -d
```

③ 进入网页配置。

启动完之后，直接访问`远程机子的IP`，本机就访问`127.0.0.1`。
在配置数据库连接的时候，选择`自动导入`即可。

④ 假如出现`CSRF`防御提示。可以修改`config.php `中`ANTI_CSRF`属性为`false`。

```shell
# 列出所有的容器，找到 zsnmwy/tieba-cloud-sign 对应的 CONTAINER ID
docker ps -a 
# 进入容器
docker exec -it {CONTAINER ID} /bin/bash
# 使用 vi 命令修改 config.php 中以下的属性
define('ANTI_CSRF',false);
```

⑤ 安装 SSR 脚本

```shell
# 一键安装 SSR
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr.sh && chmod +x ssr.sh && bash ssr.sh

# CentOS 安装 SSR+BBR
# 参考网址 https://www.zhujiboke.com/2017/03/386.html
wget -N --no-check-certificate https://raw.githubusercontent.com/91yun/uml/master/bbr/uml-centos.sh && bash uml-centos.sh
```

# 参考文章

1. [UBuntu 16.04下安装Docker](https://yq.aliyun.com/articles/675833)
2. [Ubuntu 16.04 安装 Docker 和 Docker Compose](https://www.jianshu.com/p/77a46925006c)
3. [docker/compose/](https://github.com/docker/compose/releases)
4. [Command-line completion](https://docs.docker.com/compose/completion/)

