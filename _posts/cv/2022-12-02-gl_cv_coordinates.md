---
layout: post
title: opengl&opencv坐标系讲解
categories: [cv]
tags: [opengles, opencv]
description: Opengl es&opencv 
keywords: opengl es, opengl, opencv
dashang: true
topmost: false
mermaid: false
date:  2022-12-01 07:00:00 +0800
---

在图形图像开发过程中，经常会用到opencv和opengl，有时候还是会搞混坐标系，导致画面上下反转。本文记录下gl和cv的坐标差异，是不是可以温习下。

<!-- more -->

* TOC
{:toc}
## 坐标系统

**OpenGL使用的是右手笛卡尔坐标系统，Z正轴垂直屏幕向外，X正轴从左到右，Y正轴从下到上。**

![img](/images/cv/gl_cv_coordinates/e75334dc62ec78b1.png)

右手定则：以右手握住z轴，当右手的四指从正向x轴以π/2角度转向正向y轴时，大拇指的指向就是z轴的正向。[左手定则同理]



**世界坐标系**：在现实世界中，所有的物体都具有三维特征，但计算机本身只能处理数字，显示二维的图形，将三维物体及二维数据联系在一起的唯一纽带就是坐标。为了使被显示的三维物体数字化，要在被显示的物体所在的空间中定义一个坐标系。这个坐标系的长度单位和坐标轴的方向要适合对被显示物体的描述，这个坐标系称为世界坐标系。**世界坐标系是始终固定不变的。**



**世界坐标系以屏幕中心为原点(0, 0, 0)，在OpenGL中用来描述场景的坐标。比如使用这个坐标系来描述物体及光源的位置。世界坐标系，是不会被改变的。**

**局部坐标系**：OpenGL还定义了局部坐标系的概念，所谓局部坐标系，也就是坐标系以物体的中心为坐标原点，物体的旋转或平移等操作都是围绕局部坐标系进行的，这 时，当物体模型进行旋转或平移等操作时，局部坐标系也执行相应的旋转或平移操作。需要注意的是，如果对物体模型进行缩放操作，则局部坐标系也要进行相应的 缩放，如果缩放比例在案各坐标轴上不同，那么再经过旋转操作后，局部坐标轴之间可能不再相互垂直。无论是在世界坐标系中进行转换还是在局部坐标系中进行转 换，程序代码是相同的，只是不同的坐标系考虑的转换方式不同罢了。



**视坐标系：以视点为原点，以视线方向为Z轴正方向的坐标系**。OpenGL会将世界坐标系先变换到视坐标系，然后进行裁剪，只有在视见体之内的场景才会进入下一个阶段进行处理。



**屏幕坐标系**：计算机对数字化的显示物体作了加工处理后，要在图形显示器上显示，这就要在图形显示器屏幕上定义一个二维直角坐标系，这个坐标系称为屏幕坐标系。**这个坐标系坐标轴的方向通常取成平行于屏幕的边缘，坐标原点取在左下角，长度单位常取成一个象素。**



## Opencv 坐标系

![img](/images/cv/gl_cv_coordinates/webp.webp)

opencv 的原点位于屏幕的左上方，所以访问的时候要注意跟OpenGL的坐标系进行区分.

1） 该坐标系在诸如结构体Mat,Rect,Point中都是适用的

```c++
cols == width == Point.x;
rows == height == Point.y;
```

2）在使用image.at(i,j)来访问像素点的时候， i 应该为Mat的行号， j为Mat的列好， 区别与图片坐标系中的坐标。

```c++
Mat::at(Point(x,y)) == Mat::at(y,x);
```



# 参考
http://www.songho.ca/opengl/gl_projectionmatrix.html

|------OpenCV------|
|[EasyPR4Android  车牌识别](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fimistyrain%2FEasyPR4Android)|
|[Android—基于opencv人脸检测app制作](https://www.jianshu.com/p/0116b8488aaa)|
|[Android—yolov3目标检测移植](https://www.jianshu.com/p/0cc66e9cc7d0)|
|[ViseFace ~ 20180417](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fxiaoyaoyou1212%2FViseFace)|
|[利用OpenCV实现简笔画效果](https://www.jianshu.com/p/e7ce28756227)|
|[FaceCamera ~ 20190822](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fimqingyue%2FFaceCamera)|
|------OpenGL------|
|[Android平台OpenGL SE Camera滤镜实现~20181123](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fandev009%2FAndroidShaderDemo)|
|[Android openGl开发详解(二)-相机预览](https://links.jianshu.com/go?to=https%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzIxMTg5NjQyMA%3D%3D%26mid%3D2247484334%26idx%3D1%26sn%3D8fd10993b8f87b941332d6abe7f2ffc2%26chksm%3D974f12a5a0389bb3d0e1144ccc7296f3374d86ee5f7f220c70dfa64b650384e8dbd80cd3968d%26mpshare%3D1%26scene%3D23%26srcid%3D0524AAOn8uUT2BB18hiQ7MW5%23rd)|
|[Android基于Shader的图像处理(10)-仿抖音毛刺特效](https://www.jianshu.com/p/3cb9a38de1b6)|
|[Android OpenGL ES 9.2 位置滤镜](https://www.jianshu.com/p/87ccc9bfa362)|
|[Pano360 360度/VR视频播放库~20180225](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2FMartin20150405%2FPano360)|
|[OpenGL Android课程一：入门](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fpost%2F5c473be16fb9a049ed3133f4)|
|[FboCamera ~ 20181023](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2FChyengJason%2FFboCamera)|
|[多媒体之GL-ES战记第一集--勇者集结](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fpost%2F5c382b926fb9a049f23cf8cc)|
|[OpenGL坐标变换](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fentry%2F59e3678df265da43127ff3bb)|
|[OpenGLES添加水印](https://www.jianshu.com/p/97c4e95df7b0)|
|[OpenGL未来视觉-MagicCamera3实用开源库](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fpost%2F5c283c7a518825235a055ffa)|
|[OpenGL 矩阵变换（讲的太好了~！）](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Flyx2007825%2Farticle%2Fdetails%2F8792475)|
|[OpenGL Android课程五：介绍混合（Blending）](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fpost%2F5c6b7bcaf265da2dd37c1188)|
|[AndroidOpenGLTutorial ~ 20181205](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fglumes%2FAndroidOpenGLTutorial)|
|[OpenGL未来视觉4-Native层滤镜添加](https://www.jianshu.com/p/e09ffb975a9d)|
|[OpenGL使用GLSurfaceView预览视频](https://www.jianshu.com/p/912f2622b815)|
|[OpenGL ES 高级进阶：坐标系及矩阵变换](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fpost%2F5cfe6accf265da1bc94ee33b)|
|[opengles4android ~ 20190408](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fbyhook%2Fopengles4android)|
|[《OpenGL从入门到放弃08》相机预览，这样讲就好理解了](https://www.jianshu.com/p/7db9710aacad)|
|[BubbleTextureView自定义气泡形状opengl实现 ~ 20180802](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fzolad%2FBubbleTextureView)|
|[【Android 音视频开发打怪升级：OpenGL渲染视频画面篇】一、初步了解OpenGL ES](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fpost%2F6844903975267860494)|
|[Android OpenGL ES 8.FrameBuffer离屏渲染](https://www.jianshu.com/p/487916d9c9cf)|
|[Android平台上使用MediaCodec, Opengl对视频进行处理](https://www.jianshu.com/p/cbebba28b12c)|
|[The Open Collection of GLTransitions](https://links.jianshu.com/go?to=https%3A%2F%2Fgl-transitions.com%2F)|
|[gl-transitions ~ 20200328](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fgl-transitions%2Fgl-transitions)|
|[NDK_OpenGLES_3_0 ~ 20200820](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fgithubhaohao%2FNDK_OpenGLES_3_0)|
|[FilterRenderer ~ 20180825](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fzolad%2FFilterRenderer)|
|[OpenGL 实现视频编辑中的转场效果](https://links.jianshu.com/go?to=https%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzA4MjU1MDk3Ng%3D%3D%26mid%3D2451526751%26idx%3D1%26sn%3D54153e4db03eed44552dded0ba6f0fdf%26chksm%3D886ffdf0bf1874e65e0f1ff44b1f43fabba9f161cce5aed8582c14540578f2783de6387f1cb7%26mpshare%3D1%26scene%3D23%26srcid%3D0616AMlawQTDjqodrpjdQvpO%26sharer_sharetime%3D1592350223150%26sharer_shareid%3D1b225f47ce438dd68f3eb647f1b69eb5%23rd)|
|[Category:Core API reference](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.khronos.org%2Fopengl%2Fwiki%2FCategory%3ACore_API_reference)|

