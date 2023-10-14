---
layout: post
title: jekyll进行tag/category排序
categories: [web]
tags: [jekyll]
description: jekyll进行tag/category排序
keywords: jekyll, sort
dashang: true
topmost: false
mermaid: false
date:  2022-10-09 23:00:00 +0800
---

突然心血来潮,觉得需要美化下页面的tag和category.
<!-- more -->

目前分类和标签主要有两种呈现方式:
- 根据数量,进行字体放大,行程点阵云效果;
- 在名称后面添加文章数量

两个都想做一下, 就有了下面代码,
## Category Sort
```
{% assign first = site.categories.first %}
{% assign max = first[1].size %}
{% assign min = max %}
{% for category in site.categories offset:1 %}
  {% if category[1].size > max %}
    {% assign max = category[1].size %}
  {% elsif category[1].size < min %}
    {% assign min = category[1].size %}
  {% endif %}
{% endfor %}
{% assign diff = max | minus: min %}

{% if diff == 0 %}
  {% assign diff = 1 %}
{% endif %}

{% for category in site.categories  %}
  {% assign category_size = category[1].size %}
  {% assign category_name = category[0] %}
  {% if category_size < 10 %} {% comment %} Add a '0' to the size section if size < 10. {% endcomment %}
	{% assign categorylist = categorylist | append: "0"|append: category_size|append: ","|append: category_name |append: "@" %}
  {% else %}
  {% assign categorylist = categorylist | append: category_size|append: ","|append: category_name |append: "@" %}
  {% endif %}
{% endfor %}
{% assign sorted_categorylist = categorylist | split: "@" |sort|reverse %}
{% for sorted_category in sorted_categorylist %}
  {% assign sorted_category_array = sorted_category | split: "," %}
  {% if sorted_category_array[0].size == 2 %}
	{% assign sorted_category_size = sorted_category_array[0] | slice: 1 %}
  {% endif %}

  {% comment %} calculate font style by num. {% endcomment %}
  {% assign temp = sorted_category_size | minus: min | times: 36 | divided_by: diff %}
  {% assign base = temp | divided_by: 4 %}
  {% assign remain = temp | modulo: 4 %}
  {% if remain == 0 %}
    {% assign size = base | plus: 9 %}
  {% elsif remain == 1 or remain == 2 %}
    {% assign size = base | plus: 9 | append: '.5' %}
  {% else %}
    {% assign size = base | plus: 10 %}
  {% endif %}
  {% if remain == 0 or remain == 1 %}
    {% assign color = 9 | minus: base %}
  {% else %}
    {% assign color = 8 | minus: base %}
  {% endif %}
  <a href="{{ site.baseurl }}/categories/#{{ sorted_category_array[1] }}" style="font-size: {{ size }}pt; color: #{{ color }}{{ color }}{{ color }};">{{ sorted_category_array[1] }}({{ sorted_category_size }})</a>
  <br/>
{% endfor %}
```

## Tag Sort

```
{% for tag in site.tags  %}
  {% assign tag_size = tag[1].size %}
  {% assign tag_name = tag[0] %}
  {% if tag_size < 10 %} {% comment %} Add a '0' to the size section if size < 10. {% endcomment %}
	{% assign taglist = taglist | append: "0"|append: tag_size|append: ","|append: tag_name |append: "@" %}
  {% else %}
  {% assign taglist = taglist | append: tag_size|append: ","|append: tag_name |append: "@" %}
  {% endif %}
{% endfor %}
{% assign sorted_taglist = taglist | split: "@" |sort|reverse %}
{% for sorted_tag in sorted_taglist %}
  {% assign sorted_tag_array = sorted_tag | split: "," %}
  {% if sorted_tag_array[0].size == 2 %}
	{% assign sorted_tag_size = sorted_tag_array[0] | slice: 1 %}
  {% endif %}

  {% comment %} calculate font style by num. {% endcomment %}
  {% assign temp = sorted_tag_size | minus: min | times: 36 | divided_by: diff %}
  {% assign base = temp | divided_by: 4 %}
  {% assign remain = temp | modulo: 4 %}
  {% if remain == 0 %}
    {% assign size = base | plus: 9 %}
  {% elsif remain == 1 or remain == 2 %}
    {% assign size = base | plus: 9 | append: '.5' %}
  {% else %}
    {% assign size = base | plus: 10 %}
  {% endif %}
  {% if remain == 0 or remain == 1 %}
    {% assign color = 9 | minus: base %}
  {% else %}
    {% assign color = 8 | minus: base %}
  {% endif %}
  <a href="{{ site.baseurl }}/categories/#{{ sorted_tag_array[1] }}" style="font-size: {{ size }}pt; color: #{{ color }}{{ color }}{{ color }};">{{ sorted_tag_array[1] }}({{ sorted_tag_size }})</a>
{% endfor %}
```