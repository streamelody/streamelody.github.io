---
title: Mac 下 NordVPN 国内外访问分流
date: 2018/03/17 08:13:21
categories: 
- 博客
- 随笔
tags: 
- mac
- VPN
---

> 官方 NordVPN 没有提供该功能，可以通过 Viscosity 搭配 chnroutes 来实现。
> 另外 macOS Mojave 上添加路由表，必须以 root 方式执行，所以只能手动添加或者移除路由表。

① 安装`Viscosity`客户端。

② 下载 NordVPN 的配置文件 [ovpn_tblk.zip](https://downloads.nordcdn.com/configs/archives/servers/ovpn_tblk.zip)。

③ 下载 [chnroutes.py](https://github.com/jimmyxu/chnroutes)，执行以下命令，生成`ip-up`和`ip-down`两个文件。

```shell
python chnroutes.py -p mac
```

<!--more-->

④ 在官方 NordVPN 客户端上，测试好能够连上的节点。如下图，`Australia #154`节点可用。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_nordvpn/mac_nordvpn_001.png)

⑤ 另外 NordVPN 按照如下设置，可以提高连接的成功率。
![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_nordvpn/mac_nordvpn_002.png)
⑥ 解压配置文件 `ovpn_tblk.zip`，找到`Australia #154`节点对应的配置文件`au154.nordvpn.com.tcp.ovpn`，在`<ca>`之前增加以下配置，然后点击安装。

```shell
dhcp-option DNS 223.5.5.5
```

⑦ 在终端执行以下命令添加路由表。

```shell
sudo ./ip-up
```

⑧ 再使用`Viscosity`连接 VPN，可以实现国内外网站分流。

⑨ 不需要分流的时候，使用以下命令移除路由表即可。

```shell
sudo ./ip-down
```

# 参考资料

1. [Tunnelblick instructions](https://nordvpn.com/zh/tutorials/x-mac-os-x/openvpn/)
2. [jimmyxu/chnroutes](https://github.com/jimmyxu/chnroutes)
3. [chnroutes - Usage.wiki](https://code.google.com/archive/p/chnroutes/wikis/Usage.wiki)
4. [chnroutes配合vpn实现智能科学上网](https://www.icharm.me/chnroutes%E9%85%8D%E5%90%88vpn%E5%AE%9E%E7%8E%B0%E6%99%BA%E8%83%BD%E7%A7%91%E5%AD%A6%E4%B8%8A%E7%BD%91.html)
5. [为Mac OS设置国内外地址不同的访问路由](https://xbin999.com/2014/12/29/mac-os-she-zhi-bu-tong-de-lu-you/)
6. [Mac（OSX）使用VPN小技巧——国内外访问分流](https://dctxf.com/post/Mac%EF%BC%88OSX%EF%BC%89%E4%BD%BF%E7%94%A8VPN%E5%B0%8F%E6%8A%80%E5%B7%A7%E2%80%94%E2%80%94%E5%9B%BD%E5%86%85%E5%A4%96%E8%AE%BF%E9%97%AE%E5%88%86%E6%B5%81.html)