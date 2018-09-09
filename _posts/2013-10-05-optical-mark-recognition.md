---
title: 一张乐谱图片怎样转为可以编辑的乐谱
date: 2013/10/05 08:47:30
categories: 
- 音乐
tags: 
- 乐谱
- OMR
---

### 说明
> 先把乐谱转成可以编辑的，然后就可以方便进行`修改`、`转调`、`拆分总谱`等操作。
<br/>
> 下面使用Avid Sibelius自带的`PhotoScore`来转换成可以编辑的乐谱。

### 1. 下载以下压缩包
<a href="http://pan.baidu.com/s/1FZA1z" target="_blank">下载链接</a>
<!--more-->

### 2. 安装PhotoScore
解压以上压缩包之后，得到以下文件。
![文件夹]({{ site.url }}/assets/blogImg/pic_prepare.png)
* 打开第一个文件夹，安装PhotoScore。
* 第二个文件夹是关于图片预处理操作的。

### 3. 使用PhotoScore识别乐谱图片
3.1. 图片预处理
> 图片预处理可以有效的提高乐谱图片的识别精度。
<br/>
> PhotoScore对.tiff格式支持最好。
<br/>
> `图片预处理的目的就是获得.tiff格式的图片`。
<br/>
> 具体过程详细参考以上压缩包的第二个文件夹。

<iframe width="86%" height="460" scrolling="auto" frameborder="no" border="0" marginwidth="0" marginheight="0" src="{{ site.url }}/assets/html5/pic_prepare/index.html"></iframe>

3.2. PhotoScore中校对
* 图片预处理完成后，打开PhotoScore。
* 然后将图片拖到软件的窗口中，PhotoScore会自动开始进行识别。 
* 一般识别的精度达不到100%，`识别后建议先在PhotoScore中修改`。

3.3. 在记谱软件中再次修改及排版
* 可以使用Avid Sibelius，这样另存为的时候选择第三项，然后用Sibelius打开。
![文件夹]({{ site.url }}/assets/blogImg/pscore_export.png)
* 也使用其他记谱软件如[Finale]({{ site.url }}/2013/09/finale-authorization/)、[Overture](http://yun.baidu.com/s/1eQ9YU4M)等，选择第五项，然后导入MusicXML，再次修改和排版。 
![文件夹]({{ site.url }}/assets/blogImg/pscore_xml.png)

### 备注
* 这样导出的MusicXML文件是1.0版本的，Overture是可以支持的。
* Overture可以使用这个绿色版本：[《告别转印，告别安装！单文件绿色修正版 Overture 闪亮登场！大家都来瞧瞧吧 (*^_^*)》   
                      ](http://bbs.popiano.org/forum.php?mod=viewthread&tid=264769)。
* 如果Overture在导入.MusicXML的时候出错，请参考[《Finale 2009 精简版 安装教程》]({{ site.url }}/2013/09/finale-authorization/)。
