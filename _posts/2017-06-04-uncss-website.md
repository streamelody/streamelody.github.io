---
title: 快速扒取网页样式的思路
date: 2017/06/04 15:19:36
categories: 
- 博客
- 笔记
tags: 
- r网页
- uncss
---

之前用过火狐的`Firebug`和`CSS Usage`，可是最新版本火狐不支持。

现在用另外一种方法也很方便。

<!--more-->

1. 首先 F12 调试，删除所有不需要的源码。


2. 得到 HTML 源码。


3. 经过这个网站 [uncss](https://uncss-online.com/) 处理之后，得到纯净的 CSS 样式。


4. 重新修改 CSS 样式中的路径，按照需求，相对路径改为绝对路径。

# 参考文章
1. [使用uncss去除无用的CSS](http://www.webhek.com/post/uncss.html)