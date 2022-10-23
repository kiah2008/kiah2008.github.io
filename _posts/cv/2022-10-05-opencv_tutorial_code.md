---
layout: post
title: opencv例程学习
categories: [cv]
tags: [opencv, sample]
description: video stitch学习
keywords: opencv, tutorial
dashang: true
topmost: false
mermaid: false
date:  2022-10-05 10:00:00 +0900
---

opencv教程讲解
<!-- more -->
```
└─tutorial_code
    ├─calib3d                           # 相机标定模块
    │  ├─camera_calibration             ## This is a camera calibration sample. 单目相机校准
    │  │      camera_calibration.cpp    
    │  │      in_VID5.xml
    │  │      out_camera_data.yml
    │  │      VID5.xml
    │  │      
    │  └─real_time_pose_estimation      ## 实时位姿估计（检测+创建3D纹理模型）
    │      │  CMakeLists.txt            ## 项目有两个:
    │      │                            ## example_tutorial_pnp_detection: 这个程序展示了如何检测给定的物体的3D纹理模型。
    │      ├─Data                       ## example_tutorial_pnp_registration: 这个程序展示了如何创建你的3D纹理模型。
    │      │      box.mp4               ## detection: This program shows how to detect an object given its 3D textured model. You can choose to
    │      │      box.ply               ## You can choose to use a recorded video or the webcam.
    │      │      cookies_ORB.yml       ## registration: This program shows how to create your 3D textured model.
    │      │      resized_IMG_3875.JPG  ## https://answers.opencv.org/question/204942/opencv-real_time_pose_estimation-not-working/?answer=204984#post-id-204984
    │      │      
    │      └─src
    │              CsvReader.cpp
    │              CsvReader.h
    │              CsvWriter.cpp
    │              CsvWriter.h
    │              main_detection.cpp
    │              main_registration.cpp
    │              Mesh.cpp
    │              Mesh.h
    │              Model.cpp
    │              Model.h
    │              ModelRegistration.cpp
    │              ModelRegistration.h
    │              PnPProblem.cpp
    │              PnPProblem.h
    │              RobustMatcher.cpp
    │              RobustMatcher.h
    │              Utils.cpp
    │              Utils.h
    │              
    ├─compatibility                     # 兼容性测试模块
    │      compatibility_test.cpp
    │      
    ├─core                              # opencv 核心功能模块（重要）
    │  ├─AddingImages                   ## Simple linear blender ( dst = alpha*src1 + beta*src2 )
    │  │      AddingImages.cpp          ## 简单的线性混合器
    │  │      
    │  ├─discrete_fourier_transform     ## This program demonstrated the use of the discrete Fourier transform (DFT). 离散傅里叶变换（时频转换）
    │  │      discrete_fourier_transform.cpp    ## The dft of an image is taken and it's power spectrum is displayed.
    │  │      
    │  ├─file_input_output              ## shows the usage of the OpenCV serialization functionality. 显示 opencv 序列化功能的使用。
    │  │      file_input_output.cpp     ## The output file may be either XML (xml) or YAML (yml/yaml).
    │  │      
    │  ├─how_to_scan_images             ## This program shows how to scan image objects in OpenCV (cv::Mat). 如何使用 cv::Mat 扫描图像
    │  │      how_to_scan_images.cpp
    │  │      
    │  ├─how_to_use_OpenCV_parallel_for_    ## parallel_for_才是parallel loop，opencv 并行运算
    │  │      how_to_use_OpenCV_parallel_for_.cpp
    │  │      
    │  ├─mat_mask_operations            ## This program shows how to filter images with mask: the write it yourself and the filter2d way. 使用掩膜过滤图像
    │  │      mat_mask_operations.cpp
    │  │      
    │  ├─mat_operations                 ## opencv 的 矩阵基础操作 
    │  │      mat_operations.cpp
    │  │      
    │  └─mat_the_basic_image_container      ## This program shows how to create matrices(cv::Mat) in OpenCV and its serial out capabilities. That is, cv::Mat M(...); M.create and cout 
    │         mat_the_basic_image_container.cpp     ## Shows how output can be formatted to OpenCV, python, numpy, csv and C styles.    图像容器
    │          
    ├─features2D                        # 2D特征模块
    │  │  AKAZE_match.cpp               ## accerlated-KAZE features KAZE 加速特征
    │  │  
    │  ├─AKAZE_tracking                 ## AKAZE 追踪
    │  │      planar_tracking.cpp       ## 平面追踪
    │  │      stats.h
    │  │      utils.h
    │  │      
    │  ├─feature_description            ## 特征点描述 Step 1: Detect the keypoints using SURF Detector, compute the descriptors,
    │  │      SURF_matching_Demo.cpp    ## Step 2: Matching descriptor vectors with a brute force matcher
    │  │      
    │  ├─feature_detection              ## 特征点检测 SURF（speed up robust features）
    │  │      SURF_detection_Demo.cpp   ## Step 1: Detect the keypoints using SURF Detector
    │  │      
    │  ├─feature_flann_matcher          ## flann (fast library for nearest neighbors) 快速最近邻搜索包 Step 1: Detect the keypoints using SURF Detector, compute the descriptors
    │  │      SURF_FLANN_matching_Demo.cpp  ## Step 2: Matching descriptor vectors with a FLANN based matcher
    │  │      
    │  ├─feature_homography             ## feature homography 单应性特征（照片1 * 单应性矩阵 = 照片2），Step 1: Detect the keypoints using SURF Detector, compute the descriptors
    │  │      SURF_FLANN_matching_homography_Demo.cpp   ## Step 2: Matching descriptor vectors with a FLANN based matcher
    │  │      
    │  └─Homography                     ## 单应性
    │          decompose_homography.cpp     ## 分解单应性，Decompose homography matrix computed from the camera displacement:
    │          homography_from_camera_displacement.cpp  ## 由摄像机位移得到的单应性
    │          panorama_stitching_rotating_camera.cpp   ## 全景拼接旋转照相机，basic panorama stitching from a rotating camera.
    │          perspective_correction.cpp   ## 透视矫正
    │          pose_from_homography.cpp     ## pose from homography with coplanar points，由平面点的单应性构成的姿态
    │          
    ├─gapi                              # "Graph API" 图像应用程序接口（？）
    │  └─porting_anisotropic_image_segmentation  ## You will learn how port an existing algorithm to G-API
    │          porting_anisotropic_image_segmentation_gapi.cpp
    │          porting_anisotropic_image_segmentation_gapi_fluid.cpp
    │          
    ├─gpu                               # GPU 模块
    │  ├─gpu-basics-similarity          ## 无
    │  │      gpu-basics-similarity.cpp
    │  │      
    │  └─gpu-thrust-interop             ## 无
    │          CMakeLists.txt
    │          main.cu
    │          Thrust_interop.hpp
    │          
    ├─HighGUI                           # opencv GUI 模块
    │      AddingImagesTrackbar.cpp     ## Simple linear blender 简单的线性搅拌器
    │      BasicLinearTransformsTrackbar.cpp    ## Simple program to change contrast and brightness
    │      
    ├─Histograms_Matching               # 直方图匹配
    │      calcBackProject_Demo1.cpp    ## Sample code for backproject function usage
    │      calcBackProject_Demo2.cpp    ## Sample code for backproject function usage ( a bit more elaborated )
    │      calcHist_Demo.cpp            ## Demo code to use the function calcHist
    │      compareHist_Demo.cpp         ## Sample code to use the function compareHist
    │      EqualizeHist_Demo.cpp        ## 。。。
    │      MatchTemplate_Demo.cpp       ## 。。。
    │      
    ├─imgcodecs                         #
    │  └─GDAL_IO
    │          gdal-image.cpp           ## Load GIS data into OpenCV Containers using the Geospatial Data Abstraction Library
    │          
    ├─ImgProc                           # 图像处理模块
    │  │  BasicLinearTransforms.cpp     ## Simple program to change contrast and brightness
    │  │  Morphology_1.cpp              ## Erosion and Dilation sample code
    │  │  Morphology_2.cpp              ## Advanced morphology Transformations sample code
    │  │  Threshold.cpp                 ## Sample code that shows how to use the diverse threshold options offered by OpenCV
    │  │  Threshold_inRange.cpp         ## Trackbars to set thresholds for HSV values
    │  │  
    │  ├─anisotropic_image_segmentation # 各向异性图像分割模块
    │  │      anisotropic_image_segmentation.cpp    ## 各向异性图像分割
    │  │      
    │  ├─basic_drawing                  # 基础画图模块
    │  │      Drawing_1.cpp             ## Simple geometric drawing
    │  │      Drawing_2.cpp             ## Simple sample code
    │  │      
    │  ├─changing_contrast_brightness_image # 改变明亮对比度模块
    │  │      changing_contrast_brightness_image.cpp    ## Brightness and contrast adjustments
    │  │      
    │  ├─HitMiss                        # 未知
    │  │      HitMiss.cpp               ## 可运行，未知
    │  │      
    │  ├─morph_lines_detection          # 形态学线条检测器
    │  │      Morphology_3.cpp          ## Use morphology transformations for extracting horizontal and vertical lines sample code，使用形态学变换提取水平垂直线条
    │  │      
    │  ├─motion_deblur_filter           # 运动模糊的过滤器
    │  │      motion_deblur_filter.cpp  ## You will learn how to recover an image with motion blur distortion using a Wiener filter. 运动模糊扭曲的图像使用 wiener 过滤器修复
    │  │      
    │  ├─out_of_focus_deblur_filter     # 解模糊滤波器
    │  │      out_of_focus_deblur_filter.cpp    ## You will learn how to recover an out-of-focus image by Wiener filter
    │  │      
    │  ├─periodic_noise_removing_filter # 周期性噪声去除滤波器
    │  │      periodic_noise_removing_filter.cpp    ## You will learn how to remove periodic noise in the Fourier domain
    │  │      
    │  ├─Pyramids                       # 金字塔
    │  │      Pyramids.cpp              ## Sample code of image pyramids (pyrDown and pyrUp)，上采样，下采样
    │  │      
    │  └─Smoothing                      # 平滑
    │          Smoothing.cpp            # Sample code for simple filters，平滑
    │          
    ├─ImgTrans                          # image transformation 图像转换模块
    │      CannyDetector_Demo.cpp       ## Sample code showing how to detect edges using the Canny Detector。使用 canny 检测器
    │      copyMakeBorder_demo.cpp      ## Forms a border around an image. 在图相周围形成边界
    │      filter2D_demo.cpp            ##  Sample code that shows how to implement your own linear filters by using filter2D function. 使用 filter2D 函数应用自定义线性过滤器
    │      Geometric_Transforms_Demo.cpp    ## Demo code for Geometric Transforms，几何变换
    │      houghcircles.cpp             ## This program demonstrates circle finding with the Hough transform，霍夫变换找圆
    │      HoughCircle_Demo.cpp         ## Demo code for Hough Transform，霍夫变换示例程序
    │      houghlines.cpp               ## This program demonstrates line finding with the Hough transform. 霍夫变换找直线
    │      HoughLines_Demo.cpp          ## Demo code for Hough Transform. 霍夫变换示例程序
    │      imageSegmentation.cpp        ## Sample code showing how to segment overlapping objects using Laplacian filtering, in addition to Watershed and Distance Transformation。除了分水岭和距离变换外，使用拉普拉斯滤波器分割重叠目标。
    │      Laplace_Demo.cpp             ## Sample code showing how to detect edges using the Laplace operator。拉普拉斯算子检测边缘
    │      Remap_Demo.cpp               ## Demo code for Remap。重映射示例程序
    │      Sobel_Demo.cpp               ## Sample code uses Sobel or Scharr OpenCV functions for edge detection
    │      
    ├─introduction                      # 介绍模块
    │  ├─display_image                  ## 显示图相    
    │  │      display_image.cpp         ## 显示图相
    │  │        
    │  ├─documentation                  # 文档模块
    │  │      documentation.cpp         ## 主函数
    │  │      
    │  └─windows_visual_studio_opencv   ## display_image ImageToLoadAndDisplay，显示图相
    │          introduction_windows_vs.cpp  ## 同上
    │          
    ├─ml                                # 机器学习模块
    │  ├─introduction_to_pca            ## principal component analysis 介绍
    │  │      introduction_to_pca.cpp   ## This program demonstrates how to use OpenCV PCA to extract the orientation of an object. 使用 主成分分析(Principal Component Analysis)，提取目标物体的方向
    │  │      
    │  ├─introduction_to_svm            # support vector machine 支持向量积介绍
    │  │      introduction_to_svm.cpp   ## 同上
    │  │        
    │  └─non_linear_svms                # 非线性支持向量机
    │          non_linear_svms.cpp      # This program shows Support Vector Machines for Non-Linearly Separable Data. 非线性可分数据使用支持向量机
    │          
    ├─objectDetection                   # 目标物体检测
    │      objectDetection.cpp          ## This program demonstrates using the cv::CascadeClassifier class to detect objects (Face + eyes) in a video stream. 使用 cv 的级联分类器 检测目标物体（脸+眼）
    │      
    ├─photo                             # 照片
    │  ├─decolorization                 ## 消色模块
    │  │      decolor.cpp               ## This tutorial demonstrates how to use OpenCV Decolorization Module. 展示如何使用 cv 的消色模块
    │  │      
    │  ├─hdr_imaging                    # 高动态范围成像（high dynamic range）
    │  │      hdr_imaging.cpp           ## 使用 opencv 进行高动态范围成像
    │  │      
    │  ├─non_photorealistic_rendering   # 非真实感绘制技术
    │  │      npr_demo.cpp              ## This tutorial demonstrates how to use OpenCV Non-Photorealistic Rendering Module.
    │  │      
    │  └─seamless_cloning               # 无缝克隆模块
    │          cloning_demo.cpp         ## This tutorial demonstrates how to use OpenCV seamless cloning module without GUI. 无缝克隆，无界面
    │          cloning_gui.cpp          ## This tutorial demonstrates how to use OpenCV seamless cloning module. 无缝克隆，有界面
    │          
    ├─ShapeDescriptors                  # 形状描述器模块
    │      findContours_demo.cpp        ## Demo code to find contours in an image. 在图相中找出轮廓示例
    │      generalContours_demo1.cpp    ## Demo code to find contours in an image. 同上
    │      generalContours_demo2.cpp    ## Demo code to obtain ellipses and rotated rectangles that contain detected contours. 获取包含检测到的轮廓的椭圆和旋转矩形的演示代码。
    │      hull_demo.cpp                ## Demo code to find contours in an image. 在图相中国找出轮廓
    │      moments_demo.cpp             ## Demo code to calculate moments. 计算动量的示例
    │      pointPolygonTest_demo.cpp    ## 点-多边形测试示例
    │      
    ├─snippets                          # 片段代码模块
    │      core_mat_checkVector.cpp     ## It demonstrates the usage of cv::Mat::checkVector. 检查这个Mat是否为Vector，用来确认传入的数据格式是否正确。
    │      core_merge.cpp               ## It demonstrates the usage of cv::merge. It shows how to merge 3 single channel matrices into a 3-channel matrix. 融合3-单通道矩阵形成3-通道矩阵
    │      core_reduce.cpp              ## It demonstrates the usage of cv::reduce. It shows how to compute the row sum, column sum, row average, column average, row minimum, column minimum, row maximum and column maximum of a cv::Mat. 计算行列和，均值，最小，最大
    │      core_split.cpp               ## It demonstrates the usage of cv::split. It shows how to split a 3-channel matrix into a 3 single channel matrices. 3通道矩阵拆分成3-单通道矩阵
    │      core_various.cpp             ## 不知道干啥的
    │      imgcodecs_imwrite.cpp        ## 图相编解码器 图相写操作
    │      imgproc_applyColorMap.cpp    ## 图相处理 应用色图
    │      imgproc_calcHist.cpp         ## 图相处理 计算直方图
    │      imgproc_drawContours.cpp     ## 图相处理 绘制轮廓
    │      imgproc_HoughLinesCircles.cpp    ## 图相处理 霍夫直线圆
    │      imgproc_HoughLinesP.cpp      ## 图相处理 霍夫直线
    │      imgproc_HoughLinesPointSet.cpp   ## 图相处理 霍夫直线点集
    │      
    ├─TrackingMotion                    # 运动跟踪模块
    │      cornerDetector_Demo.cpp      ## Demo code for detecting corners using OpenCV built-in functions. 使用 cv 内置函数检测角点
    │      cornerHarris_Demo.cpp        ## Demo code for detecting corners using Harris-Stephens method. 使用 哈里斯斯蒂芬斯 方法 检测角点
    │      cornerSubPix_Demo.cpp        ## Demo code for refining corner locations. 精炼角落位置
    │      goodFeaturesToTrack_Demo.cpp ## Demo code for detecting corners using Shi-Tomasi method. shi-tomasi 方法检测角点
    │      
    ├─video                             # 视频模块
    │      bg_sub.cpp                   ## Background subtraction tutorial sample code
    │      
    ├─videoio                           # 视频输入输出模块
    │  ├─video-input-psnr-ssim          ## 峰值信噪比（Peak Signal to Noise Ratio），结构相似度(Structural Similarity Index Measure)
    │  │      video-input-psnr-ssim.cpp ## This program shows how to read a video file with OpenCV. 使用 cv 读取视频，计算信噪比相似度
    │  │      
    │  └─video-write                    # 视频写入
    │          video-write.cpp          ## This program shows how to write video files. 视频写入
    │          
    └─xfeatures2D                       # xfeatures2D 模块
            LATCH_match.cpp             ## LATCH: Learned Arrangements of Three Patch Codes 学习了三个补丁码的排列
```
