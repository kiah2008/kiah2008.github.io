---
layout: post
title: video stitching学习
categories: [cv]
tags: [opencv, video_stitching]
description: video stitch学习
keywords: opencv, video stitching
dashang: true
topmost: false
mermaid: false
date:  2022-10-09 23:00:00 +0900
---

主要是基于opencv, 学习下图像融合,并延伸到视频融合.

<!-- more -->

# Sync opencv repo

当前opencv最新版本为[4.6.0](https://github.com/opencv/opencv/releases/tag/4.6.0)

```shell
$ git clone https://github.com/opencv/opencv.git -b 4.6.0
```

## 

# Build Opencv with Windows

使用wsl是不错的选择.

# Build Opencv with Android

## compile with ndk

## VS Code + NDK

修改cmake tools kit json, 添加android clang编译器

```
[
  {
    "name": "Android-Clang",
    "environmentVariables": {
      "ANDROID_NDK": "path/to/Android/Sdk/ndk/"
    },
    "compilers": {
      "C": "path/to/Android/Sdk/ndk/toolchains/llvm/prebuilt/windows-x86_64/bin/clang.exe",
      "CXX": "path/to/Android/Sdk/ndk/toolchains/llvm/prebuilt/windows-x86_64/bin/clang++.exe"
    }
  },
  ,
  {
    "name": "Visual Studio Community 2022 Release - amd64",
    "visualStudio": "9b8c874c",
    "visualStudioArchitecture": "x64",
    "preferredGenerator": {
      "name": "Visual Studio 17 2022",
      "platform": "x64",
      "toolset": "host=x64"
    }
  }
]
```

添加workspace的settings json

//.vscode/settings.json

```
{
    "cmake.configureArgs": [
        "-DCMAKE_TOOLCHAIN_FILE=${env:ANDROID_NDK}/build/cmake/android.toolchain.cmake",
        "-DANDROID_SDK=${env:ANDROID_NDK}/../..",
        "-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a",
        "-DANDROID_ABI=arm64-v8a",
        "-DCMAKE_SYSTEM_VERSION=28",
        "-DANDROID_PLATFORM=android-28",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DBUILD_DOCS=OFF",
        "-DBUILD_PERF_TESTS=OFF",
        "-DBUILD_TESTS=OFF",
        "-DBUILD_opencv_python=OFF",
        "-DBUILD_opencv_js=OFF",
        "-DBUILD_ANDROID_PROJECTS=OFF",
        "-DBUILD_ANDROID_EXAMPLES=OFF",
        "-DBUILD_JAVA=OFF"
    ]
}
```

for mingw
```
{
    "cmake.configureArgs": [
        "-DBUILD_PERF_TESTS=OFF",
        "-DBUILD_TESTS=OFF",
        "-DBUILD_opencv_python=OFF",
        "-DBUILD_opencv_js=OFF",
        "-DWITH_CUDA=ON",
        "-DWITH_FFMPEG=ON",
        "-DOPENCV_FFMPEG_USE_FIND_PACKAGE=ON",
        "-DOPENCV_FFMPEG_SKIP_BUILD_CHECK=OFF",
        "-DOPENCV_EXTRA_MODULES_PATH=/home/kiah/worktmp/opencv_contrib/modules/"
    ],
    "cmake.generator": "MinGW Makefiles",
    "files.associations": {
        "iosfwd": "cpp"
    }
}
```

启动cmake configure\build
```
[cmake] -- 
[cmake] --   GUI:                           GTK2
[cmake] --     GTK+:                        YES (ver 2.24.33)
[cmake] --       GThread :                  YES (ver 2.72.1)
[cmake] --       GtkGlExt:                  NO
[cmake] --     VTK support:                 NO
[cmake] -- 
[cmake] --   Media I/O: 
[cmake] --     ZLib:                        /usr/lib/x86_64-linux-gnu/libz.so (ver 1.2.11)
[cmake] --     JPEG:                        /usr/lib/x86_64-linux-gnu/libjpeg.so (ver 80)
[cmake] --     WEBP:                        build (ver encoder: 0x020f)
[cmake] --     PNG:                         /usr/lib/x86_64-linux-gnu/libpng.so (ver 1.6.37)
[cmake] --     TIFF:                        /usr/lib/x86_64-linux-gnu/libtiff.so (ver 42 / 4.3.0)
[cmake] --     JPEG 2000:                   build (ver 2.4.0)
[cmake] --     OpenEXR:                     build (ver 2.3.0)
[cmake] --     HDR:                         YES
[cmake] --     SUNRASTER:                   YES
[cmake] --     PXM:                         YES
[cmake] --     PFM:                         YES
[cmake] -- 
[cmake] --   Video I/O:
[cmake] --     DC1394:                      NO
[cmake] --     FFMPEG:                      YES (find_package)
[cmake] --       avcodec:                   YES (58.134.100)
[cmake] --       avformat:                  YES (58.76.100)
[cmake] --       avutil:                    YES (56.70.100)
[cmake] --       swscale:                   YES (5.9.100)
[cmake] --       avresample:                NO
[cmake] --     GStreamer:                   NO
[cmake] --     v4l/v4l2:                    YES (linux/videodev2.h)
[cmake] -- 
[cmake] --   Parallel framework:            pthreads
[cmake] -- 
[cmake] --   Trace:                         YES (with Intel ITT)
[cmake] -- 
[cmake] --   Other third-party libraries:
[cmake] --     Intel IPP:                   2020.0.0 Gold [2020.0.0]
[cmake] --            at:                   /home/kiah/worktmp/opencv/build/3rdparty/ippicv/ippicv_lnx/icv
[cmake] --     Intel IPP IW:                sources (2020.0.0)
[cmake] --               at:                /home/kiah/worktmp/opencv/build/3rdparty/ippicv/ippicv_lnx/iw
[cmake] --     VA:                          NO
[cmake] --     Lapack:                      NO
[cmake] --     Eigen:                       NO
[cmake] --     Custom HAL:                  NO
[cmake] --     Protobuf:                    build (3.19.1)
[cmake] -- 
[cmake] --   NVIDIA CUDA:                   YES (ver 11.8, CUFFT CUBLAS)
[cmake] --     NVIDIA GPU arch:             35 37 50 52 60 61 70 75 80 86
[cmake] --     NVIDIA PTX archs:
[cmake] -- 
[cmake] --   cuDNN:                         NO
[cmake] -- 
[cmake] --   OpenCL:                        YES (no extra features)
[cmake] --     Include path:                /home/kiah/worktmp/opencv/3rdparty/include/opencl/1.2
[cmake] --     Link libraries:              Dynamic load
[cmake] -- 
[cmake] --   Python (for build):            /usr/bin/python3
[cmake] -- 
[cmake] --   Java:                          
[cmake] --     ant:                         NO
[cmake] --     JNI:                         NO
[cmake] --     Java wrappers:               NO
[cmake] --     Java tests:                  NO
[cmake] -- 
[cmake] --   Install to:                    /usr/local
```

## FFMPEG

使用apt 安装ffmpeg相关库

`sudo apt-get install libavdevice-dev`

```
[cmake] --   Video I/O:
[cmake] --     DC1394:                      NO
[cmake] --     FFMPEG:                      YES (find_package)
[cmake] --       avcodec:                   YES (58.134.100)
[cmake] --       avformat:                  YES (58.76.100)
[cmake] --       avutil:                    YES (56.70.100)
[cmake] --       swscale:                   YES (5.9.100)
[cmake] --       avresample:                NO
[cmake] --     GStreamer:                   NO
```

查询ffmpeg相关库信息

```shell
$ dpkg -l libswresample-dev
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                    Version                  Architecture Description
+++-=======================-========================-============-=========================================================================
ii  libswresample-dev:amd64 7:4.4.2-0ubuntu0.22.04.1 amd64        FFmpeg library for audio resampling, rematrixing etc. - development files

$ dpkg -L libswresample-dev
/.
/usr
/usr/include
/usr/include/x86_64-linux-gnu
/usr/include/x86_64-linux-gnu/libswresample
/usr/include/x86_64-linux-gnu/libswresample/swresample.h
/usr/include/x86_64-linux-gnu/libswresample/version.h
/usr/lib
/usr/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu/libswresample.a
/usr/lib/x86_64-linux-gnu/pkgconfig
/usr/lib/x86_64-linux-gnu/pkgconfig/libswresample.pc
/usr/share
/usr/share/doc
/usr/share/doc/libswresample-dev
/usr/share/doc/libswresample-dev/copyright
/usr/lib/x86_64-linux-gnu/libswresample.so
/usr/share/doc/libswresample-dev/changelog.Debian.gz
```

# CUDA

主要是安装nvidia drivers， cuda toolkit以及sdk

`nvidia-smi`确认是否成功安装




## NDK only

使用r21e版本为例,其它参考.

```shell
$ export ANDROID_NDK=/path/to/ndk
$ export ANDROID_SDK_ROOT=/path/to/android-sdk
$ export ANDROID_NATIVE_API_LEVEL=28
$ export STRIP=/path/to/ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip
```
创建build目录, 并在build 目录执行
```shell
$ cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/ndk/build/cmake/android.toolchain.cmake -DANDROID_TOOLCHAIN=clang++ -DANDROID_ABI=arm64-v8a -D CMAKE_BUILD_TYPE=Release -D ANDROID_NATIVE_API_LEVEL=28 -D WITH_CUDA=OFF -D WITH_MATLAB=OFF -D BUILD_ANDROID_EXAMPLES=OFF -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D ANDROID_STL=c++_shared -D BUILD_SHARED_LIBS=ON -D BUILD_opencv_objdetect=OFF -D BUILD_opencv_video=OFF -D BUILD_opencv_videoio=OFF -D BUILD_opencv_features2d=OFF -D BUILD_opencv_flann=OFF -D BUILD_opencv_highgui=ON -D BUILD_opencv_ml=ON -D BUILD_opencv_photo=OFF -D BUILD_opencv_python=OFF -D BUILD_opencv_shape=OFF -D BUILD_opencv_stitching=OFF -D BUILD_opencv_superres=OFF -D BUILD_opencv_ts=OFF -D BUILD_opencv_videostab=OFF -DBUILD_ANDROID_PROJECTS=OFF ..
```

> -G ninja

进行编译

```shell
$ make -j [nproc]
```

或者是使用ninja

```shell
$ninja -j [nproc]
```

# Opencv image stitch

![StitchingPipeline.jpg](/images/cv/StitchingPipeline.jpg)

> https://docs.opencv.org/4.x/d1/d46/group__stitching.html
