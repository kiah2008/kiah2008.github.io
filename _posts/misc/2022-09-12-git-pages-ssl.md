---
layout: post
title: 对Jekyll+github pages进行优化
categories: misc
tags: [jekyll]
description: Jekyll和github pages搭建个人博客, 进行自定义域名, SSL和网站加速.
dashang: true
date:  2022-09-12 08:00:00 +0900
keywords: jekyll, github, pages
---

Jekyll和github pages搭建个人博客, 进行自定义域名, SSL和网站加速.
<!-- more -->

# 绑定域名

## Github repo配置

在对应repo的Settings的Pages,选择Custom domain, 并填写具体的域名地址(name.github.io).
如需要添加顶级域名,只需要添加WWW和@的CNAME.

- A 域名关联到一个IPv4地址
- CNAME 域名关联到另外一个域名

![git pages 配置]({{ site.baseurl }}/images/misc/1662783868819.png)

# 网站加速

建议将对应的公共js使用cdn源，进行网络下载加速。
```
BootCDN – http://www.bootcdn.cn/
CDNBee – https://cdnbee.com/
新浪云计算公共库 – http://lib.sinaapp.com/
百度静态资源公共库 – http://cdn.code.baidu.com/
奇虎360前端静态资源库（新版） – https://cdn.baomitu.com/
极客族公共加速服务 – https://cdn.geekzu.org/cached.html
又拍云常用JS库CDN服务 – http://jscdn.upai.com/
七牛静态资源CDN服务 – https://www.staticfile.org/
360网站卫士CDN前端公共库 – http://libs.useso.com/
CDNJS.NET – http://cdnjs.net/
```

目前博客使用的CDN加速

```
open_cdn:
  jquery: https://apps.bdimg.com/libs/jquery/2.1.4/jquery.min.js
  jquery_ui: https://libs.baidu.com/jqueryui/1.8.22/jquery-ui.min.js
  pusuanzi: https://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js
  mermaid: https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js
  simple_jekyll_search: https://cdn.bootcdn.net/ajax/libs/simple-jekyll-search/1.9.2/simple-jekyll-search.min.js
  geopattern: https://cdn.bootcdn.net/ajax/libs/geopattern/1.2.3/js/geopattern.min.js
  flowchart: https://cdn.bootcdn.net/ajax/libs/flowchart/1.17.1/flowchart.min.js
```

