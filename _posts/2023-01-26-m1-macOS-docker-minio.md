---
title: m1 macOS 使用 docker 搭建 minio
date: 2023/01/26 01:40:03
categories: 
- 博客
- 笔记
tags: 
- m1
- docker
- minio
---

### 一、使用 docker 部署 minio

1. 创建自定义的 `docker` 网络

```shell
$ docker network create --subnet=172.31.7.0/24 customnet

# 查看自定义的 customnet 网络
$ docker network ls
NETWORK ID     NAME                                 DRIVER    SCOPE
137dcc3baf0b   bridge                               bridge    local
9952847bffe2   customnet                            bridge    local
```

2. `docker pull minio/minio`

```shell
$ docker pull minio/minio
```
<!--more-->

3. 指定 `network` 为 `customnet`，指定 `IP` 为 `172.31.7.92` 运行容器

```shell
# MINIO_SERVER_URL 为 API 域名，此处使用本地 /etc/hosts 中配置的域名
docker run -d --name=minio \
  --restart=always \
  --network customnet \
  --ip 172.31.7.92 \
  -p 9000:9000 \
  -p 9091:9091 \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin" \
  -e TZ="Asia/Shanghai" \
  -e MINIO_SERVER_URL=http://priv.streamelody.minio:9000 \
  -v /Users/shuangyeying/.docker/minio:/data \
  -v /Users/shuangyeying/.docker/minio:/root/.minio \
  minio/minio server /data --console-address ":9091" --address ":9000"
```

4. 查看已经启动成功的容器

```shell
$ docker ps -a
CONTAINER ID   IMAGE                          COMMAND                  CREATED              STATUS              PORTS                                                                    NAMES
80f100b2d81c   minio/minio                    "/usr/bin/docker-ent…"   About a minute ago   Up About a minute   0.0.0.0:9091->9091/tcp, 0.0.0.0:19000->9000/tcp                          minio

# 查看已经启动容器的 IP
$ docker inspect 80f100b2d81c |grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.31.7.92",
```



### 二、创建 bucket 并设置为永久访问

1. 访问 [http://priv.streamelody.minio:9091](http://priv.streamelody.minio:9091) 并且登录

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/01/image-20230126001744640.png" alt="image-20230126001744640" style="zoom:50%;" />

2. 创建一个 `bucket`，此处创建一个名为 `confluence` 的 `bucket`

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/01/image-20230126001902005.png" alt="image-20230126001902005" style="zoom:50%;" />

3. 将 `Access Policy` 设置为 `Public`

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/01/image-20230126002358216.png" alt="image-20230126002358216" style="zoom:50%;" />



4. 使用 `mc` 将创建的 `bucket` 设置为 `public`

```shell
# 进入容器内部
docker exec -it minio /bin/bash

# 下载对应版本的 mc，m1 下载 linux-arm64 版本
curl https://dl.minio.io/client/mc/release/linux-arm64/mc --outout mc

# 设置可执行权限
chmod +x ./mc

# 添加 minio
[root@80f100b2d81c /]# ./mc config host add minio http://127.0.0.1:9000 minioadmin minioadmin
Added `minio` successfully.

# 设置创建的 confluence 权限为 public
[root@80f100b2d81c /]# ./mc anonymous set public minio/confluence
Access permission for `minio/confluence` is set to `public`
```



### 三、使用 uPic 进行上传配置

1. 图床选择 `Amazon S3`，按照下图进行配置。

2. 保存路径设置为 `{year}/{month}/{day}/{hour}/{filename}{.suffix}`

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/01/image-20230126175619202.png" alt="image-20230126175619202" style="zoom:50%;" />

### 参考文章

1. [部署 MinIO 通用 S3 协议对象存储服务当网盘和图床使用](https://www.ioiox.com/archives/151.html/comment-page-1)
2. [MacOS + typora + upic + github图床配置](https://blog.csdn.net/weixin_51216553/article/details/127181022)
3. [MiniO Client(mc)简单使用指南](https://www.cnblogs.com/panw/p/16801534.html)