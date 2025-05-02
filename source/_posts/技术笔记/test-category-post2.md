---
title: test-category-post2
categories:
  - 技术笔记
tags:
  - 笔记
cover: false
top_img: false
category: 技术笔记
date: 2025-05-02 19:03:02
---

## 简介

这是一个测试文章，演示如何在分类目录结构下引用图片。

## 正文

### 已确认可以显示的图片引用方式

直接使用img标签（已验证可行）：

<img src="1.jpg" alt="测试图片1">

### 更多HTML标签引用方式测试

#### 1. 带宽高的img标签

<img src="1.jpg" alt="测试图片1" width="200" height="auto">

#### 2. 使用figure标签包裹

<figure>
  <img src="1.jpg" alt="测试图片1">
  <figcaption>图片1的说明文字</figcaption>
</figure>

#### 3. 添加样式的img标签

<img src="1.jpg" alt="测试图片1" style="border: 2px solid blue; padding: 5px;">

#### 4. 使用HTML5 picture标签

<picture>
  <source srcset="1.jpg" media="(min-width: 800px)">
  <img src="1.jpg" alt="测试图片1">
</picture>

### 引用public目录下的静态资源

<img src="/img/avatar.jpg" alt="全局头像">

### 其他图片引用尝试

#### 1. 相对路径引用（简单形式）

![测试图片1](1.jpg)

#### 2. 使用绝对路径

![测试图片1](/2025/05/02/技术笔记/test-category-post2/1.jpg)

#### 3. 使用Hexo资源文件夹方式

{% asset_img 1.jpg 测试图片1 %}

#### 4. 使用完整URL

![测试图片1](http://localhost:4001/2025/05/02/技术笔记/test-category-post2/1.jpg)

#### 5. 使用缩略URL路径

![测试图片1](/技术笔记/test-category-post2/1.jpg)

#### 6. 直接引用生成后的路径

<img src="/2025/05/02/test-category-post2/1.jpg" alt="测试图片1">

### 图片引用说明

在分类目录结构下，图片路径如下：

```
source/
  └── _posts/
       └── 技术笔记/              # 分类目录
            ├── test-category-post2.md   # 文章文件
            └── test-category-post2/     # 文章图片目录
                 └── 1.jpg               # 图片文件
```

目前已经确认以下方式可以正确显示图片：
1. 使用HTML的img标签：`<img src="1.jpg" alt="测试图片1">`

<!-- 
此文件显示在：http://localhost:4001/2025/05/02/技术笔记/test-category-post2/
生成的图片路径应该是：/2025/05/02/test-category-post2/1.jpg
-->
