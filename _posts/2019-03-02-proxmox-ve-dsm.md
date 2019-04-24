---
title: Proxmox VE 安装群晖的方法
date: 2019/03/02 09:23:10
categories: 
- 博客
- 随笔
tags: 
- Proxmox
- NAS
- 群晖
---

①  下载 [Proxmox VE ISO Installer](https://www.proxmox.com/en/downloads)。

②  使用 [balenaEtcher](https://www.balena.io/etcher/) 将`Proxmox VE`镜像烧录到优盘中。

③  主机使用优盘安装`Proxmox VE`。

④  WEB 访问 https://ip:8006/ 。

⑤  修改`/usr/share/pve-manager/js/pvemanagerlib.js`

```shell
将 if(data.status!=='Active') 替换为 if(false)
```
<!--more-->

⑥  将硬盘进行分区。

```shell
# 查看磁盘分区
fdisk -l
fdisk /dev/sda
# 输入 m 查看可以进行的操作
# 输入 n 进行分区
# 格式化分区为 ext4 格式
mkfs.ext4 /dev/sda1
# 挂载磁盘到目录
mkdir /storage
mount /dev/sda1 /storage
# 设置自动挂载硬盘
vi /etc/fstab
/dev/sda1 /storage ext4 defaults 0 0

# 硬盘直通
apt-get update
apt-get install lshw
ls -l /dev/disk/by-id/
# 注意 sata 的编号要增量不能相同，比如第二个直通的磁盘就是sata3
qm set 100 --sata1 /dev/disk/by-id/ata-ST500DM002-1BD142_S2A5WF81-part1
```

⑦  下载以下文件。

[引导文件](https://roo.ooo/go/aHR0cHM6Ly9wYW4uYmFpZHUuY29tL3MvMWdHQ1dQZUNZQTBFTTRuUmxybnA3N2c=) 解压密码：k8tn  
[img2kvm](https://roo.ooo/go/aHR0cHM6Ly9yb28tMTI1MjI4ODE3OS5jb3MuYXAtZ3Vhbmd6aG91Lm15cWNsb3VkLmNvbS8yMDE4L2ltZzJrdm0=)（pve端）  
[DS3617xs-6.2-23739](https://roo.ooo/go/aHR0cHM6Ly9hcmNoaXZlLnN5bm9sb2d5LmNvbS9kb3dubG9hZC9EU00vcmVsZWFzZS82LjIvMjM3MzkvRFNNX0RTMzYxN3hzXzIzNzM5LnBhdA==)（群晖系统）

⑧  安装群晖。

```shell
# 创建虚拟机， 硬盘选 SATA， 网卡选 Intel E1000
# 将 img2kvm 和引导文件 nas.img 上传到 /root 文件
chmod +x img2kvm
./img2kvm nas.img 101 vm-101-disk-1
# 打开群晖Synology Assistant进行搜索
# 手动安装 DS3617xs-6.2-23739 
```

# 参考文章

1. [Proxmox VE下安装黑群晖DSM 6.2](http://roo.ooo/o/pve.html)
2. [基于ProXmoX VE的虚拟化家庭服务器（篇三）—黑裙6.2安装，硬盘直通](https://post.smzdm.com/p/a25r8mo2/)
3. [Linux 硬盘分区、分区、删除分区、格式化、挂载、卸载](https://www.cnblogs.com/visec479/p/4072754.html)
4. [VLOG丨PVE(Proxmox VE)下网卡是如何设置直通的](https://www.vediotalk.com/?p=2781)

