---
title: N1 小钢炮 FRP，rclone，OpenVPN 安装
date: 2019/04/27 23:01:18
categories: 
- 博客
- 笔记
tags: 
- frp
- N1
- rclone
- openvpn
---

# 升级 FRP 

```shell
# SSH 登陆到 N1 小钢炮

# 备份原来的 frp 客户端
mv /usr/local/apps/frp frpBaking

# 下载 0.27 版本的 frp 客户端
cd ~
wget https://github.com/fatedier/frp/releases/download/v0.27.0/frp_0.27.0_linux_arm64.tar.gz
# 解压
tar -zxvf frp_0.27.0_linux_arm64.tar.gz
# 将 frpc 移动到 /usr/local/apps/frp 下
mkdir /usr/local/apps/frp
cd frp_0.27.0_linux_arm64/
mv frpc /usr/local/apps/frp
# 赋予权限
chmod 755 /usr/local/apps/frp
chmod 755 /usr/local/apps/frp/frpc

# 删除不需要的文件
rm -rf ~/frp_0.27.0_linux_arm64
rm ~/frp_0.27.0_linux_arm64.tar.gz

# 重启小钢炮
```

<!--more-->

# FRP 服务器配置

```shell
# frps 配置 (以下 YOUR_xxx_HERE 的地方需要自行填写，其它项根据自己的需求调整)
# by 荒野无灯 @date 2018-07-29

[common]
# frps 监听地址
bind_addr = 0.0.0.0
# frps 监听端口 （frpc端通过这个端口与frps通信），默认7000
bind_port = 7000

# udp port 主要用于udp打洞穿透nat，默认 7001
bind_udp_port = 7001

# udp port used for kcp protocol, it can be same with 'bind_port'
# if not set, kcp is disabled in frps
# 用于kcp协议的udp端口，可以与bind_port相同
# 如果这一项没有设置，则kcp协议不会启用
# kcp_bind_port = 7000

# 代理监听地址, 默认与bind_addr相同
# proxy_bind_addr = 127.0.0.1

# 这两个配置是分别给http和https 类型的tunnel用的
# 注： 如有需要，这两项的值可与bind_port相同
vhost_http_port = 8081
vhost_https_port = 8443

# frps控制面板的监听地址和端口
# dashboard_addr的默认值与bind_addr相同
dashboard_addr = 0.0.0.0
# 若不设置dashboard_port，则控制面板不会启用
dashboard_port = 7500

# frps控制面板 登录用户名, 若不设置，则默认为admin
dashboard_user = admin
# frps控制面板 用户密码, 若不设置，则默认为admin
dashboard_pwd = YOUR_PASSWD_HERE

# dashboard assets directory(only for debug mode)
# assets_dir = ./assets/static

# 日志文件路径，其值可为 console 或 文件路径
log_file = /var/log/frps.log

# 日志级别，可选的值有 trace, debug, info, warn, error
# 日常使用建议设置为info, warn, error三者之一
log_level = info

# 日志保留天数
log_max_days = 7

# auth token, frpc客户端填写时需要与这个一样
token = YOUR_TOKEN_HERE

# 心跳发送间隔，不建议修改默认值（默认是10)
# heartbeat_interval = 10
# 心跳超时设置，不建议修改默认值（默认是90)
# heartbeat_timeout = 90

# 允许客户端绑定的端口，如果留空，表示没有任何限制
privilege_allow_ports = 2000-3000,3001,3003,4000-50000

# pool_count in each proxy will change to max_pool_count if they exceed the maximum value
max_pool_count = 5

# max ports can be used for each client, default value is 0 means no limit
max_ports_per_client = 0

# authentication_timeout means the timeout interval (seconds) when the frpc connects frps
# if authentication_timeout is zero, the time is not verified, default is 900s
authentication_timeout = 900

# 配置http或https类型的tunnel时需要这个
# 假设这里填写的是 p4davan.80x86.io , 客户端那边的subdomain值是test,
# 那么最终访问的域名是: test.p4davan.80x86.io
subdomain_host = YOUR_DOMAIN_HERE

# 是否开启tcp stream multiplexing, 注意客户端这个项的值要与这里一致
tcp_mux = true
```

# 安装 screen 和 rclone

```shell
# N1 小钢炮不能通过 apt-get install 安装
# 从 Debian 软件包下载对应的 .deb 包，然后拆包之后手动安装即可 
# 下载文件
wget https://streamelody.github.io/assets/attachment/n1_screen_rclone/screen
wget https://streamelody.github.io/assets/attachment/n1_screen_rclone/rclone
wget https://streamelody.github.io/assets/attachment/n1_screen_rclone/libcap-ng.so.0
wget https://streamelody.github.io/assets/attachment/n1_screen_rclone/libtinfo.so.5
wget https://streamelody.github.io/assets/attachment/n1_screen_rclone/libaudit.so.1
wget https://streamelody.github.io/assets/attachment/n1_screen_rclone/libpam.so.0

# 移动文件
mv screen /usr/bin/
mv rclone /usr/bin/

mv libcap-ng.so.0 /usr/lib/   
mv libtinfo.so.5 /usr/lib/ 
mv libaudit.so.1 /usr/lib/     
mv libpam.so.0 /usr/lib/ 

# 赋予权限
chmod 777 /usr/bin/screen
chmod 777 /usr/bin/rclone
chmod 755 /usr/lib/libcap-ng.so.0   
chmod 755 /usr/lib/libtinfo.so.5
chmod 755 /usr/lib/libaudit.so.1    
chmod 755 /usr/lib/libpam.so.0
```

# 安装 OpenVPN

```shell
# SSH 登陆小钢炮
# 1. 安装 entware
rm -rf /opt
mkdir /opt
cd /opt
wget -O - http://bin.entware.net/aarch64-k3.10/installer/alternative.sh | sh
# 将自带 opkg 改名为 opkg_bak
mv /usr/bin/opkg /usr/bin/opkg_bak

# 2. 配置entware环境变量
vi /etc/profile
# 直接在 /usr/sbin:\ 这行下直接添加下两行
/opt/bin:\
/opt/sbin:\
# 使配置生效
source /etc/profile

# 3. 检查entware环境安装情况看是否报错
opkg update
opkg list

# 4. 安装 openvpn 
# 查找 openvpn 软件包
opkg list|grep openvpn

# 安装 openvpn-nossl
opkg install openvpn-openssl

# 查看是否已经安装
opkg list-installed |grep openvpn-openssl

# 找到一个 .ovpn 配置文件
# 连接 OpenVPN
screen 
/opt/sbin/openvpn /root/tw-hk3.nordvpn.com.tcp.ovpn
# 输入密码
Enter Auth Username:shadow_2806@Web.de
Enter Auth Password:
# 查看 openvpn 是否连接上
curl ip.sb
```

# 参考文章

1. [荒野无灯 frps.ini](http://rom.nanodm.net/opt/frp/)
2. [/ 获取 debian / 软件包](https://www.debian.org/distrib/packages)
3. [为小钢炮装上entware运行库](https://www.right.com.cn/forum/thread-343953-1-1.html)
