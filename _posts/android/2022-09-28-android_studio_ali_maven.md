---
layout: post
title: android studio换用更换国内maven库
categories: [android]
description: android studio更换ali maven库
keywords: android studio, maven, ali
dashang: true
topmost: false
tags: [android studio]
date:  2022-09-28 23:00:00 +0900
---

因为国内特殊的网络环境, 在使用android studio的时候,如果依赖库使用默认google maven地址同步就会很慢.
本文简单记录android studio更换maven的方法

<!-- more -->

在项目的根目录的build.gradle在所有google maven前面添加ali的maven地址.

```gradle
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {

  repositories {
    // add ali maven
    maven {
      url 'http://maven.aliyun.com/nexus/content/groups/public/'
      allowInsecureProtocol true
    }
    maven {
      url 'http://maven.aliyun.com/nexus/content/repositories/jcenter'
      allowInsecureProtocol true
    }
    maven {
      url 'http://maven.aliyun.com/nexus/content/repositories/google'
      allowInsecureProtocol true
    }
    maven {
      url 'http://maven.aliyun.com/nexus/content/repositories/gradle-plugin'
      allowInsecureProtocol true
    }

    google()
    mavenCentral()
  }
  dependencies {
    classpath 'com.android.tools.build:gradle:7.2.2'
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    // NOTE: Do not place your application dependencies here; they belong
    // in the individual module build.gradle files
  }
}

allprojects {
  repositories {
    maven {
      url 'http://maven.aliyun.com/nexus/content/groups/public/'
      allowInsecureProtocol true
    }
    maven {
      url 'http://maven.aliyun.com/nexus/content/repositories/jcenter'
      allowInsecureProtocol true
    }
    maven {
      url 'http://maven.aliyun.com/nexus/content/repositories/google'
      allowInsecureProtocol true
    }
    maven {
      url 'http://maven.aliyun.com/nexus/content/repositories/gradle-plugin'
      allowInsecureProtocol true
    }

    google()
    mavenCentral()
  }
}

task clean(type: Delete) {
  delete rootProject.buildDir
}
```