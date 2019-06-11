---
title: ProxMox 5.4 创建 Ubuntu 虚拟机
date: 2019/06/07 11:35:16
categories: 
- 博客
- 随笔
tags: 
- ProxMox
- Ubuntu
- 远程桌面
- 内网穿透
---

# ProxMox VE 相关配置

```shell
# 配置分辨率
# 在 /etc/pve/qemu-server/xxx.conf 最后加入以下代码
vga: vmware

# ISO 镜像上传目录
/var/lib/vz/template/iso

# 备份目录
/var/lib/vz/dump
```

<!--more-->

# 配置 FRP 客户端

```shell
# 直接在 ProxMox VE 的 Shell 下配置
# 下载 64 位 Linux 版 frp
wget https://github.com/fatedier/frp/releases/download/v0.27.0/frp_0.27.0_linux_amd64.tar.gz
# 解压
tar -zxvf frp_0.27.0_linux_amd64.tar.gz
# 赋予权限
cd frp_0.27.0_linux_amd64
chmod +x frpc
# 将 frpc 放到 /usr/bin/ 目录下
cp frpc /usr/bin/
# 将配置文件复制到对应的配置文件目录
mkdir /etc/frp/
cp frpc.ini /etc/frp/

# frpc.ini 配置示例
[common]
server_addr = 67.230.171.47
server_port = 7000
auto_token = 12345678

[ssh]
type = tcp
local_ip = 192.168.2.117
local_port = 22
remote_port = 6000

[pve]
type = https
local_ip = 192.168.2.117
local_port = 8006
use_encryption = true
use_compression = true
subdomain = pve

# 使用 systemd 配置开机自启
vi /etc/systemd/system/frpc.service
# 以下是配置文件
[Unit]
Description=FRP Client Daemon
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/bin/frpc -c /etc/frp/frpc.ini
Restart=always
RestartSec=20s
User=nobody

[Install]
WantedBy=multi-user.target

# 开机启动 frp 客户端
systemctl enable frpc

# 重启和查看 frp 客户端状态
systemctl restart frpc
systemctl status frpc
```

# Ubuntu 虚拟机配置

```shell
# 参考这篇文章可以安装 Ubuntu
# https://www.kclouder.cn/proxmox-ve-installation/

# ISO 镜像必须通过 Web 控制台上传，以下为其位置
/var/lib/vz/template/iso

#备份目录一般在 
/var/lib/vz/dump

# 创建虚拟机时，硬盘选 SATA，网络选 Intel E1000
# 查看文件大小
ls -lht

# 默认是没有安装 SSH Server
sudo apt-get install openssh-server  
ps -e | grep ssh

# 开启桌面共享
sudo apt install vino
# 在终端执行，"your_password"修改为自己的密码
export DISPLAY=":0"
gsettings set org.gnome.Vino require-encryption false
gsettings set org.gnome.Vino prompt-enabled false
gsettings set org.gnome.Vino authentication-methods "['vnc']"
gsettings set org.gnome.Vino vnc-password "$(echo -n "your_password" | base64)"

# 配置开机自启
sudo vi /etc/xdg/autostart/vino-server.desktop
# 以下是配置文件
[Desktop Entry]
Name=Desktop Sharing
Comment=GNOME Desktop Sharing Server
Keywords=vnc;share;remote;
NoDisplay=true
Exec=/usr/lib/vino/vino-server --sm-disable
Icon=preferences-desktop-remote-desktop
Terminal=false
Type=Application
X-GNOME-Autostart-Phase=Applications
X-GNOME-AutoRestart=true
X-GNOME-UsesNotifications=true
X-Ubuntu-Gettext-Domain=vino
```

# Ubuntu 安装 Docker

```shell
# 解决依赖
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
    
# 安装 GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   
# 安装 Docker    
sudo apt-get update
sudo apt install docker.io

# 将当前用户加入 Docker 用户组，退出用户，重新登录（关键）。
sudo usermod -aG docker ${USER}

# 测试
docker --version
```

# 参考文章

1. [Proxmox VE 安装介绍](https://www.kclouder.cn/proxmox-ve-installation/)
2. [Proxmox环境下 Ubuntu16.04 + CUDA 8.0 GA2 安装](https://blog.csdn.net/Fate10_55/article/details/78182799Proxmox)
3. [Proxmox + Ubuntu16.04 + CUDA 8.0 环境下，安装Tensorflow](https://blog.csdn.net/Fate10_55/article/details/78194817)
4. [Mint 19 Cinnamon / Remote Access](https://www.reddit.com/r/linuxmint/comments/9ilpkx/mint_19_cinnamon_remote_access_vnc/)
5. [Debian9系统使用FRP内网穿透](https://zocodev.com/debian9-frp-internal-network-penetration.html)
6. [Linux Mint 19 Tara 安装 Docker CE](https://it.ismy.fun/2019/01/18/linuxmint-install-docker/)

