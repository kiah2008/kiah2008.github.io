---
layout: post
title: 对Jekyll的页面进行修改的实用技巧
categories: misc
tags: [jekyll, css]
description: 介绍jekyll的一些简单技巧,实现个人页面博客的定制.
dashang: true
date:  2022-09-20 08:00:00 +0900
keywords: jekyll, creative, git pages
---

介绍jekyll的一些简单技巧,实现个人页面博客的定制.
<!-- more -->

# Jekyll介绍

Jekyll 是一个静态博客生成器,  它吸引我的主要有几点:

1. 一个简单的静态页面生成器，不需要数据库和自己部署VPS，一切都放到Github上，免费好用
2. 完美的融合了 Markdown 和 CSS, 既可以享受 Markdown 的极简编写，又可以根据自己的喜好自定义 Markdown 的样式细节, 比如斑马线的表格、代码块圆角细节、图片自动根据页面宽度自动缩放等
3. 专注于内容, 一旦我定义好主题细节后, 我只用按照 Markdown 的语法编写文章 git push 就可以了, 一切又回到我最喜欢的极简风格
4. 本地实时预览, 一条 jekyll serve 的命令即可实时预览博客最终的展示效果和细节
5. 最后一点最重要, 不需要简陋的网站编辑器, 我可以直接在 Emacs 编辑文章的内容, 一切都是那么顺手

## 安装方法

```shell
sudo pacman -S jekyll
yay -S ruby-jekyll-feed
```



# CSS进行定制风格

## 让所有图片都自动缩放成页面的宽度

我们的拍照和截图大部分都是各种尺寸的，放到博客中，难免会产生宽度不一致的情况，非常的丑陋。 在Jekyll中，要让所有图片根据页面的宽度自动缩放却非常简单。 首先，在你的 Jekyll 页面样式中加入:

```
li>img,
p>img {
    margin: 0 auto;
    display: block;
    max-width: 90%;
    margin-top: 5px;
    margin-bottom: 5px;
    margin-left: 2em;
    margin-right: 2em;
    border-radius: 5px;
}
```

## 表格居中显示

Markdown 的表格一般都是左对齐显示，不是很优雅，怎么放中间呢？ 在样式中加入：

```
table {
    border-collapse: collapse;
    border-spacing: 0;
    border: 1px solid #AAA;

    margin-left: auto;
    margin-right: auto;
}
```

margin-left 和 margin-right 都设置成 auto 即可达到居中显示的目的，是不是比那些商业的 Markdown 网站更灵活?

## 表格斑马线

默认表格行多的时候，很难数清楚，加入淡淡的斑马线， 好看又实用：

```
tbody tr:nth-child(even) {
    background-color: #F5F5F5;
}
```

## 代码块圆角

Markdown默认的代码区域是一个冲突感的直角，如果能够稍稍的做点圆角， 就会降低代码区域的视觉冲突，人眼查看更加自然舒服。

方法很简单，浏览器折腾一下，把下面样式写到CSS文件中即可：

```
div.highlight,
pre.highlight {
    border-radius: 5px;
}
```

看到优雅的圆角了吗？就像上面这块代码区域的视觉效果

# Jekyll 写作环境

上面只是一些小细节展示，你只需要研究一些 CSS 技巧，静态页面也可以设计的非常现代。

当然，Jeyll 对于我来说，更宝贵的让我进入了一种新的专注状态：

用最小的代价兼顾编辑效率和视觉细节的同时，给我创造了一种非常专注的写作环境, 流畅，舒适
