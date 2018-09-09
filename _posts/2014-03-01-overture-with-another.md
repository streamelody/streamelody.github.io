---
title: ove乐谱与其他格式乐谱间的互相转换
date: 2014/03/01 18:04:10
categories: 
- 音乐
tags: 
- 乐谱
---

### 说明
- 首先这两者互相转换是基于.MusicXML的，所以要先将其转为.MusicXML。
- 然后才能进行导入和排版。

### 1. ove转其他
* 使用以下的小工具[ove2xml。](http://yun.baidu.com/s/1jG3tUuE)
<!--more-->
<img src="{{ site.url }}/assets/blogImg/ove_to_xml.png" width="397" alt="ove to xml"/>
* 将ove乐谱拖到该窗口中，按`快捷键F5`就可以将ove乐谱转为.MusicXML。

### 2. 其他转ove（Overture仅支持.MusicXML 1.0格式）
* 对于其他格式的乐谱，先另存为.MusicXML格式。
* 然后打开[Overture](http://yun.baidu.com/s/1eQ9YU4M)，单击“文件”→“导入”。
* 选择得到的.MusicXml文件，这样就可以得到ove格式的乐谱了。
<img src="{{ site.url }}/assets/blogImg/import_oveture.png" width="638" alt="Overture导入.MusicXML"/>

## 备注
* Overture可以使用这个绿色版本：[《告别转印，告别安装！单文件绿色修正版 Overture 闪亮登场！大家都来瞧瞧吧 (*^_^*)》](http://bbs.popiano.org/forum.php?mod=viewthread&tid=264769)。
* 如果Overture在导入.MusicXML的时候出错，请参考[《Finale 2009 精简版 安装教程》]({{ site.url }}/2013/10/finale-authorization/)。
* 针对PDF格式参考[《PDF乐谱转为可以编辑的乐谱》]({{ site.url }}/2013/10/pdf-score-recognition/)。
* 针对图片格式参考[《一张乐谱图片怎样转为可以编辑的乐谱》]({{ site.url }}/2013/10/optical-mark-recognition/)。
