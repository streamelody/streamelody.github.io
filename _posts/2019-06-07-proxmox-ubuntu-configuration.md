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

# frpc.ini 配置示例，这里兼容 N1 小钢炮 FRP 的设置
# frps.ini 服务端配置参考这里：https://streamelody.github.io/2019/04/n1-disk-mangaer-frp-update/
[common]
server_addr = 服务端 IP 地址
server_port = 7000
log_file = /var/log/frpc.log
log_level = info
log_max_days = 3
token = 12345678
admin_addr = 127.0.0.1
admin_port = 7400
admin_user = admin
admin_passwd = admin
pool_count = 5
tcp_mux = true
login_fail_exit = false
protocol = tcp
heartbeat_interval = 10
heartbeat_timeout = 90

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
ps -e | grep frpc
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

# 启用嵌套虚拟化

```shell
# SSH 进入 ProxMox，查看是否开启嵌套虚拟化，显示 “N” 表示没有开启
cat /sys/module/kvm_intel/parameters/nested

# 首先关闭所有虚拟机
qm list
qm stop <vm_id>

# 开启内核支持，开启之前确保所有的虚拟机已经关闭
modprobe -r kvm_intel  
modprobe kvm_intel nested=1

# 再次查看是否已经开启，显示 “Y” 表示已经开启
cat /sys/module/kvm_intel/parameters/nested

# 编辑配置文件，重启能够自动加载
echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf

# 在 /etc/pve/qemu-server/ 下的配置文件添加命令
args: -cpu +vmx

# 启动 macOS Mojave 虚拟机，执行以下命令
sysctl -a | grep machdep.cpu.features

# Linux 执行以下命令
egrep "vmx|svm" /proc/cpuinfo 

# 得到结果，当结果包含 VMX 时，表示已经成功开启嵌套虚拟化
machdep.cpu.features: FPU VME DE PSE TSC MSR PAE MCE CX8 APIC SEP MTRR PGE MCA CMOV PAT PSE36 CLFSH MMX FXSR SSE SSE2 HTT SSE3 VMX SSSE3 CX16 SSE4.1 SSE4.2 x2APIC POPCNT AES VMM PCID XSAVE
```

# 开机自动挂载 NFS

```shell
# 安装 nfs-common
sudo apt-get install nfs-common

# 查看共享的目录
showmount -e 192.168.2.109

# 创建本地的挂载目录
mkdir -p /mnt/Downloads

# 挂载命令
mount 192.168.2.109:/Volumes/Downloads /mnt/Downloads

# 开机自动挂载
sudo vim /etc/fstab
192.168.2.109:/Volumes/Downloads /mnt/Downloads nfs defaults 0 2
# 第一个数字：0 表示开机不检查磁盘，1 表示开机检查磁盘。
# 第二个数字：0 表示交换分区，1 代表启动分区（Linux），2 表示普通分区。
```

# Ubuntu VPS 搭建 Gnome 桌面以及使用 VNC 连接

```shell
# 搭建 Gnome 桌面

# 使用 SSH 登录服务器
# 更新源及系统
apt-get update
apt upgrade -y

# 安装桌面环境，完整版(不推荐)
apt-get install ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal

# 安装桌面环境核心组件，不安装如 office 等额外组件
apt-get install --no-install-recommends ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal -y

# 安装 vnc4server
apt-get install vnc4server

# 设置当前用户 vnc 密码
vncpasswd

# 启动 vncserver，之前没有设置密码这里会要求设置密码
# ":1" 代表 display 号，vncserver 的端口号为 5900 + display 号，这里为 5901
vncserver :1

# 结束 vncserver
vncserver -kill :1

# 修改配置文件 xstartup
vim ~/.vnc/xstartup

# 这里是 xstartup 配置文件内容
#!/bin/sh

export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

gnome-panel &
gnmoe-settings-daemon &
metacity &
nautilus &
gnome-terminal &

# 重新赋予一下权限
chmod 777 ~/.vnc/xstartup

# 重新启动 vncserver
vncserver :1

# 配置开机启动
# 打开crontab任务
crontab -e

# 另起一行，输入以下命令
@reboot /usr/bin/vncserver :1

# 使用 VNC 连接
vnc://server_ip_address:5901
```

# Debain VPS 搭建 xfce 桌面以及使用 VNC 连接

```shell
# 使用 SSH 登录服务器
# 更新源及系统
apt-get update
apt upgrade -y

# 安装桌面环境，完整版
apt install xfce4 xfce4-goodies

# 安装 TightVNC 服务器
apt install tightvncserver

# 设置当前用户 vnc 密码
vncserver

# 结束 vncserver
vncserver -kill :1

# 配置 VNC 服务器
# 备份原始文件
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
vim ~/.vnc/xstartup
# 这里是 xstartup 配置文件内容
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &

# 重新赋予一下权限
chmod +x ~/.vnc/xstartup

# 重新启动 vncserver
vncserver

# 获取当前用户
whoami
# 获取当前组
groups

# 将 VNC 作为系统服务运行
vim /etc/systemd/system/vncserver@.service

# 以下为 vncserver@.service 配置文件
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=root
Group=root
WorkingDirectory=/root

PIDFile=/root/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target

# 启用单元文件
systemctl daemon-reload
systemctl enable vncserver@1.service

# 重启 vncserver
vncserver -kill :1
systemctl start vncserver@1

# 验证 vncserver 状态
systemctl status vncserver@1
```

# 参考文章

1. [Proxmox VE 安装介绍](https://www.kclouder.cn/proxmox-ve-installation/)
2. [Proxmox环境下 Ubuntu16.04 + CUDA 8.0 GA2 安装](https://blog.csdn.net/Fate10_55/article/details/78182799Proxmox)
3. [Proxmox + Ubuntu16.04 + CUDA 8.0 环境下，安装Tensorflow](https://blog.csdn.net/Fate10_55/article/details/78194817)
4. [Mint 19 Cinnamon / Remote Access](https://www.reddit.com/r/linuxmint/comments/9ilpkx/mint_19_cinnamon_remote_access_vnc/)
5. [Debian9系统使用FRP内网穿透](https://zocodev.com/debian9-frp-internal-network-penetration.html)
6. [Linux Mint 19 Tara 安装 Docker CE](https://it.ismy.fun/2019/01/18/linuxmint-install-docker/)
7. [ubuntu 18.04 安装NFS 共享文件夹,Linux挂载，Mac 挂载](https://my.oschina.net/u/1440971/blog/2996084)
8. [Ubuntu14.04使用VNC无法显示图形界面问题的解决](https://blog.csdn.net/wwq_1111/article/details/46502873)
9. [Ubuntu16.04 用VNC链接 GNOME 桌面](https://blog.csdn.net/u014389734/article/details/79513517)
