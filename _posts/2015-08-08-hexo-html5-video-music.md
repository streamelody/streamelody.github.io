---
title: 在Hexo博客中添加HTML5视频和音频
date: 2015/08/08 13:16:06
categories: 
- 博客
tags: 
- hexo
- html5
---

### 添加HTML5视频方法
~~~css
<video src="视频外链地址.mp4" type="video/mp4" controls="controls"  width="61.8%" height="61.8%">
</video>
~~~

###  视频外链测试
<!--more-->
<video src="http://us.sinaimg.cn/002mmeX6jx06ZcQ8xPJu05040100islh0k01.mp4" type="video/mp4" controls="controls"  width="61.8%" height="61.8%">
</video>

### 添加HTML5音乐播放器（已经失效）
~~~css
<iframe src="http://musicbox.coding.io/m163player/MusicID" frameborder="0" scrolling="0" width="430" height="200" allowtransparency></iframe>
~~~
*`MusicID`替换为网易云音乐的ID，也就是浏览器地址栏那个数字。
*比如：<http://music.163.com/#/song?id=276663>，需要填写的ID是`276663`。

### HTML5 版网易云音乐外链
<iframe src="http://musicbox.coding.io/m163player/276663" frameborder="0" scrolling="0" width="430" height="200" allowtransparency></iframe>

### 参考文章
[HTML5 版网易云音乐外链播放器](http://miantiao.me/a-html5-netease-music-player.html)
[HTML5 网页音乐播放器](https://github.com/ccbikai/musicplayer)
