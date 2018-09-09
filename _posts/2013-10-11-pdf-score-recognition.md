---
title: PDF乐谱转为可以编辑的乐谱
date: 2013/10/11 13:46:55
categories: 
- 音乐
tags: 
- 乐谱
- OMR
---

### 说明
* PDF乐谱可以分成两种，`图片版`和`由记谱软件导出来的PDF版`。 
* 以下有以下两种对应方法可以实现乐谱`数字化（OMR）`，即转换成可以编辑的乐谱。   

### 1. 针对图片版PDF乐谱，首先将pdf转换为图片。
推荐参考以下文章将PDF转为图片。 
[《PDF Image Extraction Wizard 6.11 - 完美的PDF图片提取工具》](http://www.portablesoft.org/pdf-image-extraction-wizard/)  
<!--more-->
<img src="{{ site.url }}/assets/blogImg/PDF_Image_Extraction.png" width="50%" alt="PDF Image Extraction Wizard 6.11"/>
然后参考[《一张乐谱图片怎样转为可以编辑的乐谱》]({{ site.url }}/2013/10/optical-mark-recognition/)进行乐谱数字化。   

### 2. 针对由记谱软件导出来的PDF乐谱。 
这就需要[PDFtoMusic](http://pan.baidu.com/s/1eRnZkga)， 可以直接将PDF转化为.MusicXML。 
* 先按照说明安装并且注册。 
<img src="{{ site.url }}/assets/blogImg/PDF_Image_Extraction.png" width="311" alt="PDFtoMusic"/>
* 然后打开PDFtoMusic Pro，找到需要处理的PDF乐谱，打开。 
* 经过软件识别后，可以导出.MusicXML。
