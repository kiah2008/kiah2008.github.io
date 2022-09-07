---
layout: page
title: 我的常用链接
description: 我的常用链接
keywords: 学习链接
comments: false
menu: 链接
permalink: /links/
---

> 收集常用链接, 少玩游戏,多看Blog;

<ul>
{% for link in site.data.links %}
  {% if link.src == 'life' %}
  <li><a href="{{ link.url }}" target="_blank">{{ link.name}}</a></li>
  {% endif %}
{% endfor %}
</ul>

> 技术链接

<ul>
{% for link in site.data.links %}
  {% if link.src == 'technical' %}
  <li><a href="{{ link.url }}" target="_blank">{{ link.name}}</a></li>
  {% endif %}
{% endfor %}
</ul>
