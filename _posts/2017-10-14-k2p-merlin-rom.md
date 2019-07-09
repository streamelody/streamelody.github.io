---
title: K2P B1 V21.4.16.239 刷梅林
date: 2017/10/14 10:15:24
categories: 
- 博客
- 笔记
tags: 
- k2p
- 梅林
---

# 刷入官改 k2p_bcm_v17.bin

```shell
# 计算机设置为固定 IP：192.168.2.2
# 计算机接路由器 LAN，按住复位键开电，按10秒左右松开
# 访问 http://192.168.2.1，确认可以打开 CFE 的 miniweb

# 开启系统自带 tftp 服务器，重启一次。
# 打开 tftpd，将固件解压后放入 tftpd 同一目录
# tftpd 中选择 192.168.2.2 的网卡

# 在计算机浏览器上输入
http://192.168.2.1/do.htm?cmd=flash+-noheader+192.168.2.2:k2p_bcm_v17.bin+flash0.trx
# 上传固件完成之后，至少等待 5 分钟，断电复位

# 重新将 IP 设置为自动 IP
```

<!--more-->

# 备份编程器固件以及 8 个分区

```shell
# 启动系统自带的 telnet
# K2P 高级设置中，打开 ssh 和 telnet 
# telnet 登陆 K2P
telnet 192.168.2.1
# 生成编程器固件
cat /dev/mtd0 /dev/mtd1 /dev/mtd3 /dev/mtd4 /dev/mtd5 /dev/mtd6 /dev/mtd7 > /tmp/all.bin 
# 查看生成的固件大小是否为 16777216 字节
ls -l /tmp/all.bin
# 挂载到 web 上
mount --bind /tmp/all.bin /www/web-static/fonts/icofont.eot
# 浏览器下载编程器固件
http://192.168.2.1/web-static/fonts/icofont.eot
# 下载后将 icofont.eot 改名为 all.bin 
# 确认固件大小为 16777216 字节

# 依次备份 mtd0-mtd7 这 8 个分区
# 生成分区备份文件
dd if=/dev/mtd0 of=/tmp/mtd0
# 挂载到 web 上
mount --bind /tmp/mtd0 /www/web-static/fonts/icofont.eot 
# 下载后改名 mtd0.bin
http://192.168.2.1/web-static/fonts/icofont.eot
```

# 刷入梅林 K2P_Merlin_V12.trx

```shell
# 前面几步与刷入官改相似
# 在计算机浏览器上输入
http://192.168.2.1/do.htm?cmd=flash+-noheader+192.168.2.2:K2P_Merlin_V12.trx+flash0.trx
# 上传固件完成之后，至少等待 5 分钟，断电复位
# 重新将 IP 设置为自动 IP

# 恢复出厂设置，固件的缺省地址变更为 http://192.168.1.1
http://192.168.2.1/do.htm?cmd=nvram+erase

# 在 web 的“系统管理”-“系统设置”页面打开 ssh
# ssh 登陆
ssh -p 22 admin@192.168.1.1
# 设置 WAN 口地址
nvram set wan0_hwaddr=FC:7C:02:9E:9F:35
# 设置 LAN 口地址
nvram set lan_hwaddr=FC:7C:02:9E:9F:36
nvram set et0macaddr=FC:7C:02:9E:9F:36
# 设置 2.4G 地址
nvram set wl_hwaddr=FC:7C:02:9E:9F:37
nvram set wl0_hwaddr=FC:7C:02:9E:9F:37
nvram set 0:macaddr=FC:7C:02:9E:9F:37
# 设置 5G 地址
nvram set wl1_hwaddr=FC:7C:02:9E:9F:38
nvram set sb/1/macaddr=FC:7C:02:9E:9F:38

# 保存上述设置
nvram commit
```

# 参考文章

1. [[k2p] 斐讯K2P金色博通版本开启telnet、固件备份、恢复的方法](https://www.right.com.cn/forum/thread-254919-1-1.html)

2. [K2P B1版本刷梅林固件](https://blog.tms.im/2017/11/03/phicomm-k2p-b1)