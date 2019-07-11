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

# 编辑 /etc/pve/qemu-server/101.conf 配置
# 以下是 DSM 的配置
boot: cdn
bootdisk: sata1
cores: 1
ide2: none,media=cdrom
memory: 1024
name: DSM6.2
net0: e1000=D6:84:70:DE:48:DE,bridge=vmbr0,firewall=1
numa: 0
ostype: l26
sata0: local-lvm:vm-101-disk-1,size=32G
sata1: local-lvm:vm-101-disk-2,size=52M
sata2: /dev/disk/by-id/ata-TOSHIBA_DT01ABA300V_Z813HRSAS,size=2930266584K
sata3: /dev/disk/by-id/ata-ST500DM002-1BD142_S2A5WF81,size=488386584K
scsihw: virtio-scsi-pci
smbios1: uuid=726f2893-bc9e-40f1-b742-fddbe3f6412f
sockets: 1
vmgenid: 6c552bbe-2235-4c06-845e-92766087e6e0

# 打开群晖Synology Assistant进行搜索
# 手动安装 DS3617xs-6.2-23739 

# 安装完成之后，DMS 控制面板 > 终端机和 SNMP，打开 SSH。
# 以 SSH 登录到 DMS
# 设置禁用更新
127.0.0.1	global.download.synology.com
127.0.0.1	update.synology.com
127.0.0.1	autoupdate.synology.com
127.0.0.1	autoupdate.synology.cn
```

# VMware 格式 DSM 迁移到 PVE

```shell
# 以此镜像为例，这是一个 VMware 的虚拟硬盘
# 链接：https://pan.baidu.com/s/1rjUQgoeKsSi4qyJCv7yTEQ 提取码：65kk 解压密码: doraemon
# 解压后得到 ds3617xs_dsm62.vmdk 和 synoboot.vmdk，上传到 ProxMox 目录下

# 再找到 img2kvm，同样上传到 ProxMox 目录下

# SSH 登陆到 ProxMox，将 vmdk 转为 raw  
qemu-img convert synoboot.vmdk synoboot.raw 
qemu-img convert ds3617xs_dsm62.vmdk ds3617xs_dsm62.raw 

# ProxMox 创建一个虚拟机，比如 VM ID 为 105
# 使用 img2kvm 创建将 raw 转换为虚拟机磁盘
./img2kvm synoboot.raw 105 vm-105-disk-1
./img2kvm ds3617xs_dsm62.raw 105 vm-105-disk-2

# 然后在 ProxMox 中添加这两个磁盘，然后设置启动顺序就可以了

# 最后补充，可以使用 qemu-img 代替 img2kvm 完成 VMware 磁盘的转换，然后导入即可
qemu-img convert -f raw -O qcow2 synoboot.raw vm-105-disk-1.qcow2
qemu-img convert -f raw -O qcow2 ds3617xs_dsm62.raw vm-105-disk-2.qcow2

qm importdisk 105 vm-105-disk-1.qcow2 local
qm importdisk 105 vm-105-disk-2.qcow2 local
```

# 参考文章

1. [Proxmox VE下安装黑群晖DSM 6.2](http://roo.ooo/o/pve.html)
2. [基于ProXmoX VE的虚拟化家庭服务器（篇三）—黑裙6.2安装，硬盘直通](https://post.smzdm.com/p/a25r8mo2/)
3. [Linux 硬盘分区、分区、删除分区、格式化、挂载、卸载](https://www.cnblogs.com/visec479/p/4072754.html)
4. [VLOG丨PVE(Proxmox VE)下网卡是如何设置直通的](https://www.vediotalk.com/?p=2781)
5. [VMware黑群解决挂载NFS后PhotoStation和VideoStation无法索引的问题](https://www.nas2x.com/threads/vmwarenfsphotostationvideostation.578/)
6. [Migrate VMware guest to ProxMox guest](https://www.youtube.com/watch?v=wmbwNT0gul0)
7. [ProXmoX下使用QM命令部署黑群晖DSM6.1.7](http://www.hopol.cn/2018/06/1266/)  
8. [当 Synology NAS 运行服务或更新软件时连接到什么网站？](https://originwww.synology.com/zh-cn/knowledgebase/DSM/tutorial/Service_Application/What_websites_does_Synology_NAS_connect_to_when_running_services_or_updating_software)  
