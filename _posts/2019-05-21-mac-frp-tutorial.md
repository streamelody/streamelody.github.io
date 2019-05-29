---
title: Mac 下使用 FRP 实现内网穿透
date: 2019/05/21 13:21:37
categories: 
- 博客
- 随笔
tags: 
- mac
- frp
---

>之前安装好了黑苹果作为文件服务器，现在来配置 FRP 内网穿透。
>
>需要准备一个域名 + 一台外网服务器。
>
>服务器使用搬瓦工 Ubuntu 16.0.4。

# 注册及解析域名

① 这里使用 [FreeNom](http://www.freenom.com/en/index.html) 注册一个免费域名。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_frp/mac_frp_001.png)

② 使用 [dnspod](www.dnspod.cn) 将域名解析到服务器。

<!--more-->

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_frp/mac_frp_002.png)



③ 在 [dnspod](www.dnspod.cn) 修改 DNS。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_frp/mac_frp_003.png)

④ 使用`ping`命令检查域名是否解析成功。

```shell
ping domain.tk
```

# 配置服务端 FRP

① 服务器端安装 FRP。

```shell
# 使用 arch 获取系统硬件架构类型
arch
x86_64
# 下载 64 位 Linux 版 frp
wget https://github.com/fatedier/frp/releases/download/v0.27.0/frp_0.27.0_linux_amd64.tar.gz
# 解压并移动文件夹
tar -zxvf frp_0.27.0_linux_amd64.tar.gz
mv frp_0.27.0_linux_amd64 frp
# 赋予权限
cd frp
chmod +x frps
# 修改服务器配置文件
vim frps.ini

# 以下为 frps.ini 配置
[common]
bind_port = 7000
auto_token=12345678

dashboard_port = 7500
# dashboard 用户名密码，默认都为 admin
dashboard_user = admin
dashboard_pwd = admin
```

② 使用`supervisor`设置开机自启。

```shell
# 安装 supervisor
apt-cache search supervisor
apt-get install supervisor
# 编辑 frp.conf 设置开机自启
cd /etc/supervisor/conf.d/
touch frp.conf
vim frp.conf
# 以下为 frp.conf 配置
[program:frp]
command = /root/frp/frps -c /root/frp/frps.ini 
autostart = true
autorestart = true
startsecs=0
# systemctl 查看开机启动项
systemctl list-unit-files | grep supervisor
```

③ 访问  [服务端ip:7500]()，查看服务端是否配置成功。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_frp/mac_frp_004.png)

# 配置客户端 FRP

① 客户端安装 FRP。

```shell
# 客户端和服务端的版本号要一致
# 客户端使用黑苹果，下载这个版本 frp_0.27.0_darwin_amd64.tar.gz
https://github.com/fatedier/frp/releases/download/v0.27.0/frp_0.27.0_darwin_amd64.tar.gz
# 解压并移动文件夹
tar zxvf frp_0.27.0_darwin_amd64.tar.gz
mkdir /usr/local/bin/frpc
mv frp_0.27.0_darwin_amd64/* /usr/local/bin/frpc
rm -rf frp_0.27.0_darwin_amd64
# 赋予权限
cd /usr/local/bin/frpc
chmod +x frpc
# 修改服务器配置文件
vim frpc.ini

# 以下为 frpc.ini 配置
[common]
server_addr = 这里修改为 frp 服务端的 ip 地址
server_port = 7000
auto_token=12345678

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000
```

② 配置`frpc.plist`实现开机自启。

```shell
touch ~/Library/LaunchAgents/frpc.plist
vim ~/Library/LaunchAgents/frpc.plist

# 以下为 frpc.plist 配置
https://streamelody.github.io/assets/attachment/frpc.plist

# 加载生效
sudo chown root ~/Library/LaunchAgents/frpc.plist
sudo launchctl load -w ~/Library/LaunchAgents/frpc.plist
```

③  访问 [服务端ip:7500]()，查看客户端是否`online`。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_frp/mac_frp_005.png)

# 参考文章

1. [利用frp实现Mac的内网穿透](https://www.newlearner.site/2018/12/12/frp-mac.html)
2. [使用Frp内网穿透快速搭建Web应用实践](https://yq.aliyun.com/articles/630646)
3. [frp实现内网穿透并配置自动启动](https://blog.csdn.net/sinat_29963957/article/details/83591264)
4. [利用Docker搭建FRP内网穿透](https://www.centos.bz/2018/10/利用docker搭建frp内网穿透/)
5. [内网穿透 frp、ssh远程访问内网、VNC远程桌面控制、macOS、ubuntu](https://blog.csdn.net/u010953692/article/details/)
6. [frp/README_zh.md](https://github.com/fatedier/frp/blob/master/README_zh.md)
7. [Mac设置开机启动](https://www.jianshu.com/p/49dabd8ec9bb)

