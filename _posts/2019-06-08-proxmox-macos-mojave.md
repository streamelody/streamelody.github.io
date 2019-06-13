---
title: ProxMox 5.4 安装 macOS Mojave
date: 2019/06/08 08:51:33
categories: 
- 博客
- 笔记
tags: 
- ProxMox
- mojave
- nfs
---

# 说明

```shell
# 参考最新的文章，制作安装镜像时不需要从 App Store 下载 macOS Mojave 了。
# OSK authentication key 是一个固定值
ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc

# 目前只能使用 Penryn 这个 CPU 启动，不支持虚拟化。
# 虚拟化软件无法运行：VMware Fusion、Parellels Desktop、Docker for Mac等均无法运行。

# 目前将所有硬盘直通到 macOS Mojave 中，然后开启 NFS 共享和 SMB 共享。
# 然后 ProxMox 其他的虚拟机则通过 NFS 或 SMB 共享访问硬盘中的内容。
```

# 配置 ProxMox

```shell
# SSH 登陆到 ProMox
# 避免 macOS 循环启动
echo 1 > /sys/module/kvm/parameters/ignore_msrs
echo "options kvm ignore_msrs=Y" >> /etc/modprobe.d/kvm.conf && update-initramfs -k all -u
# 配置 OVMF 库，然后才能启动 macOS
wget https://github.com/thenickdude/pve-edk2-firmware/releases/download/1.20190312-1-macos/pve-edk2-firmware_1.20190312-1_all.deb
dpkg -i pve-edk2-firmware_1.20190312-1_all.deb
# 阻止被 apt upgrade 替换
apt-mark hold pve-edk2-firmware
```

<!--more-->

# 准备 Clover 和 macOS 安装镜像

```shell
# clover r4920 下载地址
# 下载完成后，解压得到 clover-r4920.iso 
https://github.com/thenickdude/OSX-KVM/releases/download/clover-r4920/clover-r4920.iso.zip

# 获取 macOS 网络安装镜像
# 下载这个 python 脚本
https://raw.githubusercontent.com/thenickdude/OSX-KVM/master/fetch-macOS.py
# 执行脚本，获得 400M 左右的 BaseSystem.dmg
python fetch-macOS.py
# 将 dmg 转换为 iso，得到 Mojave-installer.iso
hdiutil convert BaseSystem.dmg -format RdWr -o Mojave-installer.iso
mv Mojave-installer.iso.img Mojave-installer.iso

# 将 clover-r4920.iso 和 Mojave-installer.iso 上传到 ProxMox
```

# 创建虚拟机	

```shell
# 可以按照参考文章创建
# 然后修改配置文件
/etc/pve/qemu-server/vm_id.conf

# vm_id.conf 配置文件（vm id 为 107），已经配置 +vmx 启用嵌套虚拟化
args: -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" -smbios type=2 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+pcid,+ssse3,+sse4.2,+vmx,+popcnt,+avx,+aes,+xsave,+xsaveopt,check -device usb-kbd,bus=ehci.0,port=2
balloon: 0
bios: ovmf
bootdisk: ide2
cores: 4
cpu: Penryn
efidisk0: local-lvm:vm-107-disk-1,size=128K
ide0: local:iso/Mojave-installer.iso,cache=unsafe
ide2: local:iso/clover-r4920.iso,cache=unsafe
machine: q35
memory: 8192
name: macOS
net0: vmxnet3=4E:AD:DD:42:BB:0D,bridge=vmbr0,firewall=1
numa: 0
ostype: other
sata0: local-lvm:vm-107-disk-0,cache=unsafe,size=64G
smbios1: uuid=42c1af5f-347c-4abd-a33c-bf9b817182ef
sockets: 1
vga: vmware
```

# 安装 macOS Mojave

```shell
# 启动虚拟机，ESC 进入 BIOS 修改分辨率，这步是为了避免花屏
# 依次选择 Select Device Manager - Select OVMF platform configuration - Change Preferred 修改为 1920x1080，Commit Changes and Exit - Reset

# 然后进入 Clover 进行安装即可

# 因为这里是网络安装，需要联网才能正常进行，安装时间根据个人网速而定
```

# 将 Clover 安装到硬盘

```shell
# 在 macOS 打开终端
# 查看驱动器
diskutil list

# 以下是结果
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *268.4 MB   disk0
   1:                        EFI EFI                     101.4 MB   disk0s1
   2:           Linux Filesystem                         163.9 MB   disk0s2

/dev/disk1 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *2.1 GB     disk1
   1:                  Apple_HFS macOS Base System       2.0 GB     disk1s1

/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *68.7 GB    disk2
   1:                        EFI EFI                     209.7 MB   disk2s1
   2:                 Apple_APFS Container disk3         68.5 GB    disk2s2

/dev/disk3 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +68.5 GB    disk3
                                 Physical Store disk2s2
   1:                APFS Volume macOS                   13.0 GB    disk3s1
   2:                APFS Volume Preboot                 46.1 MB    disk3s2
   3:                APFS Volume Recovery                506.8 MB   disk3s3
   4:                APFS Volume VM                      20.5 KB    disk3s4
  
# 显然有两个 EFI 分区
# 分别是 disk0s1，对应 clover-r4920.iso 光盘中的分区
# 另一个是 disk2s1，对应硬盘中的 EFI 分区
# 现在我们将 clover EFI 分区内容复制到硬盘 EFI 分区即可
# 不要照抄，要按照上面的分析来写
sudo dd if=/dev/disk0s1 of=/dev/disk2s1

# 关闭 macOS Mojave
# 在 ProxMox “硬件”界面，分离 clover-r4920.iso 和 Mojave-installer.iso
# 在 ProxMox “选项”界面，修改“引导顺序”为硬盘启动
```

# 配置开机自启

```shell
# 每次开机需要设置分辨率，然后才能正常显示
# 可以启动一次之后，然后重置就没问题了，通过以下脚本实现

# 配置开机自启
vim /etc/init.d/run

# 以下是配置文件
#!/bin/sh

### BEGIN INIT INFO
# Provides: run
# Required-Start: $network $remote_fs $local_fs
# Required-Stop: $network $remote_fs $local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: run qm 107
# Description: run qm 107
### END INIT INFO

qm stop 107
sleep 5
qm start 107
sleep 20
qm reset 107

exit 0

# 赋予执行权限
chmod +x /etc/init.d/run 

# 配置开机自启
update-rc.d run defaults
```

# USB 直通

```shell
# 需要将 USB 先插入 USB 口
# 在 ProxMox “监视器”选项卡中输入 info usbhost 来获取连接到 ProxMox 的 USB 设备
  Bus 2, Addr 2, Port 2, Speed 5000 Mb/s
    Class 00: USB device 0930:6545, DataTraveler 3.0
  Bus 1, Addr 4, Port 1, Speed 480 Mb/s
    Class 00: USB device 0781:5567, Cruzer Blade
  Bus 1, Addr 3, Port 6, Speed 1.5 Mb/s
    Class 00: USB device 1a2c:2124, USB Keyboard
  Bus 1, Addr 2, Port 5, Speed 1.5 Mb/s
    Class 00: USB device 093a:2510, USB Optical Mouse
    
# SSH 登陆 ProxMox
qm set YOUR-VM-ID-HERE -usb1 host=0930:6545
qm set YOUR-VM-ID-HERE -usb2 host=0781:5567   
qm set YOUR-VM-ID-HERE -usb3 host=1a2c:2124
qm set YOUR-VM-ID-HERE -usb4 host=093a:2510

# 想要看到 USB 直通效果，需要在 ProxMox 界面重启虚拟机。
```

# 硬盘直通

```shell
# disk_type[n] 和虚拟机硬件不能冲突
# /dev/disk/by-id/<type>-$brand-$model_$serial_number 为磁盘ID的具体路径和名称。
qm set <vm_id> --<disk_type>[n] /dev/disk/by-id/<type>-$brand-$model_$serial_number

# 实际代码
qm set 107 --sata1 /dev/disk/by-id/ata-TOSHIBA_DT01ABA300V_Z813HRSAS
qm set 107 --sata2 /dev/disk/by-id/ata-ST500DM002-1BD142_S2A5WF81

# 可以在 ProxMox "硬件"界面查看是否添加上
```

# Mac 开启 NFS 共享服务

```shell
# 编辑配置文件
sudo vim /etc/exports 
# 以下为配置文件，前者为 NFS 目录
# -mapall 的值，可以终端通过 id 获取
/Volumes/Downloads -mapall=501

# 重启 nfsd 服务
sudo nfsd restart

# 查看 nfsd 服务状态
sudo nfsd status

# 查看挂载状态
showmount -e

# macOS 可以通过 Command+K 连接服务器，然后连接上 NFS 共享目录
nfs://192.168.2.109/Volumes/Downloads
```

# ProxMox 添加 NFS 作为备份目录

```shell
# 数据中心 > 存储 > 添加 > NFS
# 填写 NFS 地址 192.168.0.109
# 设置好目录和内容，挂载目录为 /mnt/pve/nfs

# 然后备份时，存储位置选 NFS 位置即可
```

# 其他配置

```shell
# 使用 clover configurator 配置开机不用回车就可以启动

# 注入白苹果三码

# 睡眠管理，貌似无法鼠标或键盘唤醒
# 但是可以打开文件共享，屏幕共享，这样默认就不会休眠了

# 最终 xxx.conf 配置文件
args: -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" -smbios type=2 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+pcid,+ssse3,+sse4.2,+popcnt,+aes,+xsave,+xsaveopt,check -device usb-kbd,bus=ehci.0,port=2
balloon: 0
bios: ovmf
boot: cdn
bootdisk: sata0
cores: 4
cpu: Penryn
efidisk0: local-lvm:vm-107-disk-1,size=128K
machine: q35
memory: 8192
name: macOS
net0: vmxnet3=4E:AD:DD:42:BB:0D,bridge=vmbr0,firewall=1
numa: 0
ostype: other
sata0: local-lvm:vm-107-disk-0,cache=unsafe,size=64G
sata1: /dev/disk/by-id/ata-TOSHIBA_DT01ABA300V_Z813HRSAS,size=2930266584K
sata2: /dev/disk/by-id/ata-ST500DM002-1BD142_S2A5WF81,size=488386584K
smbios1: uuid=42c1af5f-347c-4abd-a33c-bf9b817182ef
sockets: 1
vga: vmware
```

# 参考文章

1. [Installing macOS Mojave 10.14 on Proxmox 5.4](https://www.nicksherlock.com/2018/06/installing-macos-mojave-on-proxmox/)
2. [在 Proxmox 5.4 上安装 macOS High Sierra/Mojave](https://tsanie.us/2019/05/29/Installing-macOS-High-Sierra-Mojave-on-Proxmox-5-4/)
3. [AMD Ryzen黑苹果新姿势：借助KVM实现CPU变频、随意升级](https://www.itmanbu.com/ryzen-hackintosh-using-kvm-proxmox.html)
4. [clover注入白苹果三码实现imessage正常使用](https://www.jianshu.com/p/81adba521a64)
5. [添加物理磁盘到VM中](http://www.kwx.me/index.php/archives/282/)
6. [How to create an NFS share on MAC OS X](https://community.spiceworks.com/how_to/61136-how-to-create-an-nfs-share-on-mac-os-x-snow-leopard-and-mount-automatically-during-startup-from-another-mac)
7. [NFS: Mac OS X (server) and Mac OS X (clients)实现思路](https://blog.51cto.com/nanfeibobo/1743068)
8. [Mac中配置NFS server]([https://lizhiyong2000.github.io/2019/03/30/mac%E4%B8%AD%E9%85%8D%E7%BD%AEnfs-server/](https://lizhiyong2000.github.io/2019/03/30/mac中配置nfs-server/))
9. [如何在Proxmox VE中设置NFS服务器和配置NFS存储](https://www.howtoing.com/how-to-configure-nfs-storage-in-proxmox-ve)
10. [让Proxmox VE支持嵌套虚拟化](https://blog.51cto.com/kusorz/1925172)
11. [Linux实现开机自动运行普通用户脚本](https://blog.51cto.com/13691477/2113933)