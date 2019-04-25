---
title: 使用 KeePass + WebDav 管理密码
date: 2018/11/24 13:29:25
categories: 
- 编程
- 随笔
tags: 
- 密码
- KeePass
- WebDav
---

# Ubuntu 搭建 WebDAV 服务器

```shell
# 安装 Apache2
apt-get update
apt-get install apache2

# 激活 WebDAV 模块
a2enmod dav_fs

# 建立目录并授予权限
mkdir -p /var/www/web/downloads
chmod 777 /var/www/web/downloads
chown www-data /var/www/web

# 更改 WebDAV 服务端口号为 6666
vi /etc/apache2/ports.conf
#将 "Listen 80" 中的 "80" 改为 6666

# 备份及编辑 Apache 配置文件
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.old

vi /etc/apache2/sites-available/000-default.conf

# 以下为 000-default.conf 配置文件内容
<VirtualHost *:6666>

ServerAdmin webmaster@localhost
DocumentRoot /var/www/html

<Directory /var/www/web/>
Options Indexes MultiViews
AllowOverride None
Order allow,deny
allow from all
</Directory>

Alias /webdav /var/www/web

<Location /webdav>
DAV On
AuthType Basic
AuthName "webdav"
AuthUserFile /var/www/passwd.dav
Require valid-user
</Location>

</VirtualHost>

# 建立使用 WebDAV 的账号和密码
htpasswd -c /var/www/passwd.dav [username]

# 修改 passwd.dav 权限，只有 root 和 www-data 群组成员可访问
chown root:www-data /var/www/passwd.dav
chmod 640 /var/www/passwd.dav

# 重启 Apache2 服务
/etc/init.d/apache2 restart

# 访问格式
http://ip地址:6666/webdav
```

<!--more-->

# Mac 上使用 KeepassXC

① 安装`KeepassXC`。

```shell
brew cask install keepassxc
```

② 启用 KeepassXC 浏览器集成。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_keepass/mac_keepass_chrome.png)

③ 安装 Chrome 浏览器插件 [KeePassXC-Browser](https://chrome.google.com/webstore/detail/keepassxc-browser/oboonakemofpalcgghocfoadofidjkkk/related?hl=en)，`Connect`。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_keepass/mac_keepass_chrome_002.png)

④ `⌘ + K`连接 WebDAV 服务器。

⑤ KeepassXC 创建数据库的时候，直接放在 WebDAV 上即可。

# Android 上 使用 Keepass2Android

① 安装 [Keepass2Android](https://play.google.com/store/apps/details?id=keepass2android.keepass2android)。

② 下载插件 [kp2a.plugin.AutoFill](https://github.com/PhilippC/kp2a_accservice_autofill/releases/) 并在`系统设置` > `辅助功能` > `KP2A AutoFillPlugin` 开启。

③ 在 Keepass2Android `设置` > `插件` > `AutoFill-Plugin(Accessibility Service)`开启。

# iOS 上使用 MiniKeePass

① 安装 [MiniKeePass](https://itunes.apple.com/cn/app/minikeepass/id451661808)。

② 注意 MiniKeePass 只支持 1.x 或者 2.x 版本的数据库文件。

③ 所以 Mac 上使用最新版 KeepassXC  创建数据库之后，iOS 就访问不了了。

# 参考文章

- [Debian/Ubuntu系统在Apache2上配置WebDAV实现文件传输](https://www.anyewuji.com/67)