---
title: m1 macOS使用 docker 安装 Confluence 8.0.2
date: 2023/01/26 13:04:51
categories: 
- 博客
- 笔记
tags: 
- m1
- docker
- confluence
---

### 一、Clone

```shell
$ git clone --recurse-submodule https://bitbucket.org/atlassian-docker/docker-atlassian-confluence-server.git

Cloning into 'docker-atlassian-confluence-server'...
Receiving objects: 100% (2868/2868), 1.41 MiB | 1.55 MiB/s, done.
Resolving deltas: 100% (2063/2063), done.
Submodule 'shared-components' (https://bitbucket.org/atlassian-docker/docker-shared-components.git) registered for path 'shared-components'
Cloning into '/Users/shuangyeying/Downloads/docker-atlassian-confluence-server/shared-components'...
Receiving objects: 100% (351/351), 59.77 KiB | 264.00 KiB/s, done.
Resolving deltas: 100% (170/170), done.
Submodule path 'shared-components': checked out '52cd98f0136e31e69b2e75a35f81e315d646cf82'
```

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20220820012627628.png" alt="image-20220820012627628" style="zoom:50%;" />
<!--more-->

### 二、build

1. 查看 Confluence 最新版本：https://www.atlassian.com/software/confluence/download-archives
2. 当前最新版 8.0.2 下载地址为：https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-8.0.2.tar.gz
3. EAP 版本下载：https://www.atlassian.com/software/confluence/download-eap

```shell
# 编译镜像
$ docker build --tag confluence:8.0.2-m1 --build-arg CONFLUENCE_VERSION=8.0.2 .

# 查看镜像
$ docker images
REPOSITORY                     TAG             IMAGE ID       CREATED         SIZE
confluence                     8.0.2-m1        3aa9cd0eda36   2 minutes ago   1.33GB
```

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230122095212604.png" alt="image-20230122095212604" style="zoom:50%;" />

### 三、构建镜像

1. 从 https://downloads.mysql.com/archives/c-j/ 下载  `MySQL Driver`，解压后得到 `mysql-connector-j-8.0.31.jar`。此处根据自身需要，下载对应的数据库连接驱动。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230125134406339.png" alt="image-20230125134406339" style="zoom:50%;" />

2. `vim Dockerfile`  编写 `Dockerfile`。

```shell
FROM confluence:8.0.2-m1

USER root

# 将 atlassian-agent.jar 加入容器
COPY "atlassian-agent.jar" /opt/atlassian/confluence/
COPY "mysql-connector-j-8.0.31.jar" /opt/atlassian/confluence/confluence/WEB-INF/lib

# 设置启动加载代理包
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/confluence/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/confluence/bin/setenv.sh
```

3. 构建

```shell
docker build -t confluence:8.0.2 .
```

4. 使用 `docker images` 查看已经构建完成的镜像

```shell
$ docker images
REPOSITORY                     TAG             IMAGE ID       CREATED         SIZE
confluence                     8.0.2           9e85bd46b31f   3 seconds ago   1.34GB
```

### 四、启动容器

1. 创建自定义的 `docker` 网络

```shell
$ docker network create --subnet=172.31.7.0/24 customnet

# 查看自定义的 customnet 网络
$ docker network ls
NETWORK ID     NAME                                 DRIVER    SCOPE
137dcc3baf0b   bridge                               bridge    local
9952847bffe2   customnet                            bridge    local
```

2. 指定 `network` 为 `customnet`，指定 `IP` 为 `172.31.7.91` 运行容器

```shell
docker run -d --name confluence \
  --restart always \
  --network customnet \
  --ip 172.31.7.91 \
  -p 8090:8090 \
  --privileged \
  -e TZ="Asia/Shanghai" \
  -v /Users/shuangyeying/.docker/confluence:/var/atlassian/application-data/confluence \
  confluence:8.0.2
```

3. 查看已经启动成功的容器

```shell
$ docker ps -a
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS                                                                    NAMES
62d094a5c032   confluence:8.0.2               "/usr/bin/tini -- /e…"   2 seconds ago   Up 2 seconds   0.0.0.0:8090->8090/tcp, 8091/tcp                                         confluence

# 查看已经启动容器的 IP
$ docker inspect 62d094a5c032 |grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.31.7.91",
```

### 五、安装 Confluence

1. 浏览器访问 http://127.0.0.1:8090/

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230125132152409.png" alt="image-20230125132152409" style="zoom:50%;" />

2. 获取 Confluence 安装密钥

```shell
# 获取 Confluence 安装密钥
$ java -jar atlassian-agent.jar -d -m shuangyeying@gmail.com -n BAT -p conf -o http://127.0.0.1:8090 -s B8QT-23BD-44VQ-R6DS

====================================================
=======     Atlassian Crack Agent v1.3.1     =======
=======           https://zhile.io           =======
=======          QQ Group: 30347511          =======
====================================================

Your license code(Don't copy this line!!!): 

AAABpg0ODAoPeJxtUU2PmzAUvPtXIPVMAoYQNpKlJkC+lJAS2FTtzaGP4BYMMiYs++vrEFaVqhW+M
GPPzJv35Tv80vaUa3immdYCWwsba16caNjAFvIEUMkq7lMJ5IHohqnjGQrutGgHhmS0aAD50KSC1
QPyygtWMql0C5YCb0C79louZd0sptP3nBUwYRU6iRvlrHmKPFhFmng+MdRnLlzjxUBpxbMJTSW7A
5GiBeRVXKr/4EhZQZq8pfzWQ8/47eutVNAkrUo0em5pk5Oj13nrzXoVueV+/eOtFklb19Ni+87y/
e9umi/zc3WIfl5Os03XhcWm3Ia5MM+RkzlF1hHyTBBLKiSIcdIBOjxNkr6GkJZAvNPxGJy93fKAV
DYugVOeQvBWM9GP3bkvujFXB41vdz457Pw4CPWD6cxtB9sYY3dmoxjEHYSiV26U6Nha+bptXyL97
Pjx010pUg/4I9NQyx/oLyCaR5GmYxhzw7Us88Pn8xDfWpHmtIH/Fzu29yGHUdxe/212cBsihG15B
XHKXht1k+gmUoOQT4YZNzaUtFomfwFEQsogMCwCFCqj7cZKKWoXfpl6w6xJnkl9T+iUAhQWHCPcI
JC6lo+UBH6bqN3fQVANTQ==X02kc
```

3. 按需选择部署方式，这里选择 `single node` 类型

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230125132439764.png" alt="image-20230125132439764" style="zoom:50%;" />

4. 设置 `MySQL` 数据库，数据库的 IP 使用之前自定义 docker 容器的 IP。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230125150335694.png" alt="image-20230125150335694" style="zoom:50%;" />

5. 稍等一会之后，来到这个界面，可以选择 `Empty Site`。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230125150709968.png" alt="image-20230125150709968" style="zoom:50%;" />

6. 按照提示设置用户名和组即可。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230125150757401.png" alt="image-20230125150757401" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/13/image-20230125150854976.png" alt="image-20230125150854976" style="zoom:50%;" />



### 参考文章

https://bitbucket.org/atlassian-docker/docker-atlassian-confluence-server/src/master/

https://hub.docker.com/r/atlassian/confluence/tags?page=1&name=m69