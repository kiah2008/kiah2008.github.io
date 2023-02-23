---
layout: page
title: kiah's blog
description: 哈哈，你找到了我的文章基因库
keywords: blog
comments: false
permalink: /blog
---


<section class="container posts-content">
<!-- calculate every year's article count and combine with comma sperated -->
{% assign count = 1 %}
{% for post in site.posts reversed %}
    {% assign year = post.date | date: '%Y' %}
    {% assign nyear = post.next.date | date: '%Y' %}
    {% if year != nyear %}
        {% assign count = count | append: ', ' %}
        {% assign counts = counts | append: count %}
        {% assign count = 1 %}
    {% else %}
        {% assign count = count | plus: 1 %}
    {% endif %}
{% endfor %}
<!-- split string into arrays -->
{% assign counts = counts | split: ', ' | reverse %}

{% assign i = 0 %}
{% assign thisyear = 1 %}

{% for post in site.posts %}
    {% assign year = post.date | date: '%Y' %}
    {% assign nyear = post.next.date | date: '%Y' %}
    <!-- new year -->
    {% if year != nyear %}
        {% if thisyear != 1 %}
            <!-- break this year -->
            </ol>
        {% endif %}
        <h3>{{ post.date | date: '%Y' }} ({{ counts[i] }})</h3>
        {% if thisyear != 0 %}
            {% assign thisyear = 0 %}
        {% endif %}
        <ol class="posts-list">
        {% assign i = i | plus: 1 %}
    {% endif %}
    {% if post.categories contains "blog" %}
        <li class="posts-list-item">
        <span class="posts-list-meta">{{ post.date | date:"%m-%d" }}-{{post.categories}}</span>
        <a class="posts-list-name" href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
        </li>
    {% endif %}
{% endfor %}
</ol>
</section>
<!-- /section.content -->
