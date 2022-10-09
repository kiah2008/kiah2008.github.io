---
layout: post
title: video stitch学习
categories: [cv]
tags: [opencv, video_stitch]
description: video stitch学习
keywords: opencv, video stitch
dashang: true
topmost: false
mermaid: false
date:  2022-10-09 23:00:00 +0900
---

主要是基于opencv, 学习下图像融合,并延伸到视频融合.

<!-- more -->



# Build Opencv with Windows

使用wsl是不错的选择



# Build Opencv with Android

当前opencv最新版本为[4.6.0](https://github.com/opencv/opencv/releases/tag/4.6.0)

```shell
$ git clone https://github.com/opencv/opencv.git -b 4.6.0
```

## compile with ndk

使用r21e版本为例,其它参考.

```shell
$ export ANDROID_NDK=/content/android-ndk-r21e
$ export ANDROID_SDK_ROOT=/usr/lib/android-sdk
$ export ANDROID_SDK_ROOT=/usr/lib/android-sdk
$ export ANDROID_NATIVE_API_LEVEL=24
$ export STRIP=/content/android-ndk-r21e/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip
```
创建build目录, 并在build 目录执行
```shell
$ cmake -DCMAKE_TOOLCHAIN_FILE=../android-ndk-r21e/build/cmake/android.toolchain.cmake -DANDROID_TOOLCHAIN=clang++ -DANDROID_ABI=arm64-v8a -D CMAKE_BUILD_TYPE=Release -D ANDROID_NATIVE_API_LEVEL=24 -D WITH_CUDA=OFF -D WITH_MATLAB=OFF -D BUILD_ANDROID_EXAMPLES=OFF -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D ANDROID_STL=c++_shared -D BUILD_SHARED_LIBS=ON -D BUILD_opencv_objdetect=OFF -D BUILD_opencv_video=OFF -D BUILD_opencv_videoio=OFF -D BUILD_opencv_features2d=OFF -D BUILD_opencv_flann=OFF -D BUILD_opencv_highgui=ON -D BUILD_opencv_ml=ON -D BUILD_opencv_photo=OFF -D BUILD_opencv_python=OFF -D BUILD_opencv_shape=OFF -D BUILD_opencv_stitching=OFF -D BUILD_opencv_superres=OFF -D BUILD_opencv_ts=OFF -D BUILD_opencv_videostab=OFF -DBUILD_ANDROID_PROJECTS=OFF ..
```

> -G ninja

进行编译

```shell
$ make -j [nproc]
```

或者是使用ninja

```shell
ninja
```



# opencv image stitch

![StitchingPipeline.jpg](assets/StitchingPipeline.jpg)

> https://docs.opencv.org/4.x/d1/d46/group__stitching.html
