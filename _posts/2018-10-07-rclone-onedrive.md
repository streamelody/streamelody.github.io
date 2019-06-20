---
title: 使用 rclone 挂载 OneDrive
date: 2018/10/07 10:28:12
categories: 
- 博客
- 笔记
tags: 
- rclone
- OneDrive
---

# 申请 OneDrive 1T 邮箱

点击 [开始免费使用 Office 365](https://www.microsoft.com/zh-cn/education/products/office/default.aspx)，然后输入学校的邮箱，接着填写相关信息即可。

查看大小 `OneDrive 设置`>`其他设置`>`存储标准`。

# 使用 rclone 挂载

```shell
# 客户端授权
rclone authorize "onedrive"
# 在打开的网页里输入相关信息，会在终端显示 {"access_token":"xxxx"}

# 配置 rclone，选择 OneDrive
rclone config
# client_id> 留空 
# client_secret>  留空 
# Choose OneDrive account type? 选 business
# Use auto config? 选 n
# result> 输入上述步骤得到的 {"access_token":"xxxx"}
```

<!--more-->

# 使用 WebDAV 挂载

```shell
# 首先登陆 OneDrive，将自己的地址转换为以下格式。
# 原本的地址
https://xxxxxxxcn-my.sharepoint.com/personal/rootmaster_xxxx_xxx_cn/_layouts/15/onedrive.aspx
# 可以作为 WebDAV 挂载的地址
https://xxxxxxxcn-my.sharepoint.com/personal/rootmaster_xxxx_xxx_cn/Documents

# 配置 rclone，选择 Webdav
rclone config
# url> 填写以上可以作为 WebDAV 挂载的地址
# Choose a number from below, or type in your own value
# 选择  3 / Sharepoint
# 然后输入 email 账号和密码
# bearer_token> 默认留空
```

# 参考文章

1. [在Debian/Ubuntu上使用rclone挂载OneDrive网盘](https://www.moerats.com/archives/491/)
2. [以WebDav方式挂载OneDrive](http://www.pianshen.com/article/6363174521/)
3. [ rclone - rsync for cloud storage - WebDav](https://rclone.org/webdav/)