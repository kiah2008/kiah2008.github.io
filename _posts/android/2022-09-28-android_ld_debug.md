---
layout: post
title: android linker调试技巧
categories: [android]
description: android so not found
keywords: android, ld, linker
dashang: true
topmost: false
tags: [linker]
date:  2022-09-28 21:16:00 +0900
---

在开发Android native库的时候, 时不时会遇到运行过程中因为库加载失败导致运行异常.这种情况下,就需要知道linker是如何查找动态库的.

<!-- more -->

一般遇到上面问题, 可能原因有几种.
1. selinux安全限制;
2. 加载了不允许使用的库
3. 库路径错误问题

对于第一种情况, 可以临时禁用selinux确认
```
adb shell enforce 0
adb get enforece
```
对于第二种, 实际上可以归属到第三种. Android处于安全考虑,限制了普通应用去使用一些系统核心库,这个实际上可以透过查看库的依赖链确认是否是因为使用了禁用的动态库导致.针对这种情况, 可以采取的方法:
- 考虑添加白名单,将对应库开放给普通应用使用(可能性比较小)
- 打包一份备份到自己的apk jni库中, 不过这种容易产生依赖扩散(需要打包一连串的系统库)
- 替换掉系统库,绕过对其依赖

对于第三种情况, 就可以开启linker的debug log来分析.

# linker自带的log格式如下

LD_LOG(kLogDlopen,
       "... dlopen successful: realpath=\"%s\", soname=\"%s\", handle=%p",
       si->get_realpath(), si->get_soname(), handle);
# linker的源码路径
/bionic/linker/
# linker的编译
直接 mm /bionic/linker/即可,编译完成后把linker和linker64 推到system/bin,再chmod 777 即可，可能要进recovery模式去修改。

# 开启linker的log
 setprop debug.ld.app.com.android.browser dlopen,dlerror 表示开启chrome的log
 setprop debug.ld.all dlopen,dlerror 表示开启所有应用的log
