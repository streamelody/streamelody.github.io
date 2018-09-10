---
title: Z3免root精简列表
date: 2016/03/05 23:01:37
categories: 
- 其他
tags: 
- 索尼
---

### 步骤
> 下载[Z3Z3C精简adb.zip](http://pan.baidu.com/s/1jHQkc0e)  
> 连接手机，**打开USB调试**，运行以下链接的**入口.bat**  
> 输入adb shell  
> 按需要精简的程序，输入如下命令

### 精简指令
【1】 移除 小窗口（**需要重启手机才能移除**）
{% highlight ruby %}
pm block com.sony.smallapp.managerservice
pm block com.sony.smallapp.appframework
pm block com.sony.smallapp.launcher
pm block com.sony.smallapp.app.widget
{% endhighlight %}
<!--more-->
【2】 移除 更新中心
{% highlight ruby %}
pm block com.sonyericsson.updatecenter
{% endhighlight %}

【3】 移除 备份和恢复
{% highlight ruby %}
pm block com.sonymobile.synchub
{% endhighlight %}

【4】 移除 索尼精选
{% highlight ruby %}
pm block com.sonymobile.sonyselect
{% endhighlight %}

【5】 移除 Xperia乐享汇
{% highlight ruby %}
pm block com.sonyericsson.xhs
pm block com.sonymobile.xperialounge.services
{% endhighlight %}

【6】 移除 谷歌图书
{% highlight ruby %}
pm block com.google.android.apps.books
{% endhighlight %}

【7】 移除 云端硬盘
{% highlight ruby %}
pm block com.google.android.apps.docs
{% endhighlight %}

【8】 移除 谷歌新闻和天气
{% highlight ruby %}
pm block com.google.android.apps.genie.geniewidget
{% endhighlight %}

【9】 移除 谷歌的Gmail
{% highlight ruby %}
pm block com.google.android.gm
{% endhighlight %}

【10】 移除 Gmail读者服务
{% highlight ruby %}
pm block com.sonymobile.gmailreaderservice
{% endhighlight %}

【11】 移除 环聊
{% highlight ruby %}
pm block com.google.android.talk
{% endhighlight %}

【12】 移除 谷歌报亭
{% highlight ruby %}
pm block com.google.android.apps.magazines
{% endhighlight %}

【13】 移除 谷歌地图
{% highlight ruby %}
pm block com.google.android.apps.maps
{% endhighlight %}

【14】 移除 谷歌游戏
{% highlight ruby %}
pm block com.google.android.play.games
{% endhighlight %}

【15】 移除 谷歌+
{% highlight ruby %}
pm block com.google.android.apps.plus
{% endhighlight %}

【16】 移除 Lifelog
{% highlight ruby %}
pm block com.sonymobile.lifelog
{% endhighlight %}

【17】 移除 影片创作工具
{% highlight ruby %}
pm block com.sonymobile.moviecreator.rmm
{% endhighlight %}

【18】 移除 What’s New
{% highlight ruby %}
pm block com.sonymobile.advancedwidget.entrance
{% endhighlight %}

【19】 移除 谷歌电影
{% highlight ruby %}
pm block com.google.android.videos
{% endhighlight %}

【20】 移除 youtube
{% highlight ruby %}
pm block com.google.android.youtube
{% endhighlight %}

【21】 移除谷歌搜索框
{% highlight ruby %}
pm block com.google.android.googlequicksearchbox
{% endhighlight %}

【22】 移除 支持
{% highlight ruby %}
pm block com.sonymobile.helpapp7
{% endhighlight %}

### 恢复指令
如果需要恢复，将以上语句中的`block`改成`unblock`。  
【1】 恢复 what’s new
{% highlight ruby %}
pm unblock com.sonymobile.advancedwidget.entrance
{% endhighlight %}

【2】 恢复 小窗口 （**需要重启手机才能消失**）
{% highlight ruby %}
pm unblock com.sony.smallapp.launcher
pm unblock com.sony.smallapp.app.widget
{% endhighlight %}

![Z3免root精简]({{ site.url }}/assets/blogImg/z3_simplified_01.png)

### 参考文章
* [Z3/Z3 COMPACT 无ROOT精简，已测试，基本涵括全部该精简的程序](http://bbs.gfan.com/android-7729338-1-1.html)
* [Z3/Z3C最详细的精简列表，手写了4个小时，我自己都感动了](http://bbs.gfan.com/android-7744517-1-1.html)
