---
title: 在Hexo博客中添加高质量Retina截图
date: 2015/09/13 15:31:01
categories: 
- 博客
tags: 
- hexo
- retina
---

### 说明
> 换用RMBP之后，系统自带的截图都是2x方式的。  
> 这样截图添加到博客中就会显得过大，与博文非常不协调。

1. 试过`QQ for Mac`的截图功能，标准(1x)的截图并不清晰。  
![QQ标准质量截图]({{ site.url }}/assets/blogImg/MacQQ_ScreenShot_normal.png)

2. 那么设置高清质量后截图，再使用[TinyPNG](https://tinypng.com/)将截图压缩。  
<img src="{{ site.url }}/assets/blogImg/tinypng.png" width="658" alt="TinyPNG截图"/>
<!--more-->

3. MarkDown中使用img标签添加高清(2x)截图。
{% highlight html %}
<img src="截图地址" width="50%" alt="alt属性"/>
{% endhighlight %}  
<img src="{{ site.url }}/assets/blogImg/MacQQ_ScreenShot_high.png" width="409" alt="QQ高清质量截图"/>

### 备注
* 可以下载试用单文件版[QQ_for_Mac_ScreenCapture.zip。]({{ site.url }}/assets/attachment/QQ_for_Mac_ScreenCapture.zip)
* 部署之后仍然显示原图，在主题_config.yml设置`fancybox: false`即可。
