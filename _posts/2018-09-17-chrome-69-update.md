---
title: Chrome 69 恢复旧版风格
date: 2018/09/17 23:07:11
categories: 
- 文章
- 博客
tags: 
- Chrome
---

1. 标签栏恢复梯形风格
```shell
chrome://flags/#top-chrome-md
```
找到`UI Layout for the browser's top chrome`  
设置为`Normal`。  
![]({{ site.url }}/assets/blogImg/2018/chrome_69_update/chrome_69_update_01.png)
<!--more-->

2. 恢复新窗口的网页缩略图
```shell
chrome://flags/#ntp-custom-links
```
找到`New Tab Page Custom Links`  
设置为`Disable`。  
![]({{ site.url }}/assets/blogImg/2018/chrome_69_update/chrome_69_update_02.png)

3. 允许使用Flash
```shell
chrome://flags/#enable-ephemeral-flash-permission
```
找到`Enable Ephemeral Flash Permissions`  
设置为`Disable`。  
![]({{ site.url }}/assets/blogImg/2018/chrome_69_update/chrome_69_update_03.png)