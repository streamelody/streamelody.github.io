---
title: macOS Mojave 恢复 iTunes 12.6.5
date: 2018/09/27 23:52:02
categories: 
- mac
- 博客
tags: 
- iTunes
- 旧版
---

1. 重启系统， 按住 `command+R` 进入恢复模式， 打开终端，使用以下命令关闭 SIP。

```shell
csrutil disable
```

2. 使用  [AppDelete](http://www.reggieashworth.com/appdelete) 删除原来的 iTunes。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/12/mojave_install_itunes_12.6.5_01.png" style="zoom:50%;" />
<!--more-->

3. 下载 [iTunes12.6.5.dmg](https://support.apple.com/zh-cn/HT208079)。

4. 使用 [Pacifist](https://www.charlessoft.com/) 打开 `iTunes12.6.5.dmg`，找到 `iTunes.app`，安装。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/12/mojave_install_itunes_12.6.5_02.png" style="zoom:50%;" />

5. 然后按住 `option` 键打开 iTunes，随后点击`选择资料库`选项，选择一个 iTunes 资料库。
<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/12/mojave_install_itunes_12.6.5_03.png" width="530" style="zoom:50%;" />

6. 重启系统， 按住 `command+R` 进入恢复模式， 打开终端，使用以下命令关闭 SIP。

```shell
csrutil enable
```

7. 至此， Mojave 的 iTunes 就是12.6.5的了。

<img src="https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2023/01/27/12/mojave_install_itunes_12.6.5_04.png" style="zoom:50%;" />

### 参考文章

1. [iTunes 12.6.5 not working in Mojave](https://forums.macrumors.com/threads/itunes-12-6-5-not-working-in-mojave.2142646/page-2)
2. [How to Disable System Integrity Protection (rootless) in Mac OS X](http://osxdaily.com/2015/10/05/disable-rootless-system-integrity-protection-mac-os-x/)