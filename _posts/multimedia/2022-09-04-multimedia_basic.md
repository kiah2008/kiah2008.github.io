---
layout: post
title: 音视频入门
categories: [multimedia]
tags: [audio, video]
description: 音视频入门
keywords: 音视频入门
dashang: true
topmost: false
mermaid: false
date:  2022-09-04 23:00:00 +0800
---

# 视频播放器原理
<!-- more -->
视音频技术主要包含以下几点：封装技术，视频压缩编码技术以及音频压缩编码技术。如果考虑到网络传输的话，还包括流媒体协议技术。视频播放器播放一个互联网上的视频文件，需要经过以下几个步骤：解协议，解封装，[解码](https://so.csdn.net/so/search?q=解码&spm=1001.2101.3001.7020)视音频，视音频同步。如果播放本地文件则不需要解协议，为以下几个步骤：解封装，解码视音频，视音频同步。他们的过程如图所示。



![img](/images/multimedia/SouthEast.jpeg)

- 解协议的作用，就是将流媒体协议的数据，解析为标准的相应的封装格式数据。视音频在网络上传播的时候，常常采用各种流媒体协议，例如HTTP，RTMP，或是MMS等等。这些协议在传输视音频数据的同时，也会传输一些信令数据。这些信令数据包括对播放的控制（播放，暂停，停止），或者对网络状态的描述等。解协议的过程中会去除掉信令数据而只保留视音频数据。例如，采用RTMP协议传输的数据，经过解协议操作后，输出FLV格式的数据。

- 解封装的作用，就是将输入的封装格式的数据，分离成为音频流压缩编码数据和视频流压缩编码数据。封装格式种类很多，例如MP4，MKV，RMVB，TS，FLV，AVI等等，它的作用就是将已经压缩编码的视频数据和音频数据按照一定的格式放到一起。例如，FLV格式的数据，经过解封装操作后，输出H.264编码的视频码流和AAC编码的音频码流。

- 解码的作用，就是将视频/音频压缩编码数据，解码成为非压缩的视频/音频原始数据。音频的压缩编码标准包含AAC，MP3，AC-3等等，视频的压缩编码标准则包含H.264，MPEG2，VC-1等等。解码是整个系统中最重要也是最复杂的一个环节。通过解码，压缩编码的视频数据输出成为非压缩的颜色数据，例如YUV420P，RGB等等；压缩编码的音频数据输出成为非压缩的音频抽样数据，例如PCM数据。

- 视音频同步的作用，就是根据解封装模块处理过程中获取到的参数信息，同步解码出来的视频和音频数据，并将视频音频数据送至系统的显卡和声卡播放出来。



## 协议

| 名称     | 推出机构       | 传输层协议 | 客户端   | 目前使用领域    |
| -------- | -------------- | ---------- | -------- | --------------- |
| RTSP+RTP | IETF           | TCP+UDP    | VLC, WMP | IPTV            |
| RTMP     | Adobe Inc.     | TCP        | Flash    | 互联网直播      |
| RTMFP    | Adobe Inc.     | UDP        | Flash    | 互联网直播      |
| MMS      | Microsoft Inc. | TCP/UDP    | WMP      | 互联网直播+点播 |
| HTTP     | WWW+IETF       | TCP        | Flash    | 互联网点播      |

RTSP+RTP经常用于IPTV领域。因为其采用UDP传输视音频，支持组播，效率较高。但其缺点是网络不好的情况下可能会丢包，影响视频观看质量。因而围绕IPTV的视频质量的研究还是挺多的。

RTSP规范可参考：[RTSP协议学习笔记](https://blog.csdn.net/leixiaohua1020/article/details/11955341)

RTSP+RTP系统中衡量服务质量可参考：[网络视频传输的服务质量（QoS）](https://blog.csdn.net/leixiaohua1020/article/details/11883393)

上海IPTV码流分析结果可参考：IPTV视频码流分析

因为互联网网络环境的不稳定性，RTSP+RTP较少用于互联网视音频传输。互联网视频服务通常采用TCP作为其流媒体的传输层协议，因而像RTMP，MMS，HTTP这类的协议广泛用于互联网视音频服务之中。这类协议不会发生丢包，因而保证了视频的质量，但是传输的效率会相对低一些。


## FFPlay流程

![img](/images/multimedia/Center.jpeg)



# 视频参数对比

流媒体系统对比：

http://en.wikipedia.org/wiki/Comparison_of_streaming_media_systems

封装格式对比：

http://en.wikipedia.org/wiki/Comparison_of_container_formats

视频编码器对比：

http://en.wikipedia.org/wiki/Comparison_of_video_codecs

音频编码格式对比：

http://en.wikipedia.org/wiki/Comparison_of_audio_formats

视频播放器对比：

http://en.wikipedia.org/wiki/Comparison_of_video_player_software



# 音视频常用测试材料

[**Simplest mediadata test**](https://github.com/leixiaohua1020/simplest_mediadata_test/tree/master/simplest_mediadata_test)

本项目包含如下几种视音频数据解析示例：
 (1)像素数据处理程序。包含RGB和YUV像素格式处理的函数。
 (2)音频采样数据处理程序。包含PCM音频采样格式处理的函数。
 (3)H.264码流分析程序。可以分离并解析NALU。
 (4)AAC码流分析程序。可以分离并解析ADTS帧。
 (5)FLV封装格式分析程序。可以将FLV中的MP3音频码流分离出来。
 (6)UDP-RTP协议分析程序。可以将分析UDP/RTP/MPEG-TS数据包。



QoS（Qualityof Service）服务质量，是网络的一种安全机制, 是用来解决网络延迟和阻塞等问题的一种技术。在正常情况下，如果网络只用于特定的无时间限制的应用系统，并不需要QoS，比如Web应用，或E-mail设置等。但是对关键应用和多媒体应用就十分必要。当网络过载或拥塞时，QoS 能确保重要业务量不受延迟或丢弃，同时保证网络的高效运行。

ITU将服务质量定义为决定用户对服务的满意程度的一组服务性能指标。从另一角度来说，QoS参数也是流媒体媒体传输的性能指标。主要的QoS参数有如下几项：传输带宽，传输时延和抖动，丢包率。

1.传输带宽
传输带宽也指的是数据传输的速率。对于流媒体的播放，影响最大的属性就是传输带宽。如果带宽过低，使得数据传输下载的速度小于视频流播放的数率，那么在视频的播放将会经常出现停顿和缓冲，极大的影响了客户观看的流畅性；而为了保证视频观看的流畅性，在低带宽的条件下，只能选择低品质、低码流的视频进行传输，这样又会影响到客户的光看效果。所以，一个良好的传输带宽环境是客户活动高品质的流媒体体验的重要保证。

2.传输时延和抖动
传输时延定义为从服务器端发送数据到接受端接收到该数据之间的时间差，它是用来描述网络时延的一个指标。时延抖动定义为网络传输延时的变化率。流媒体最重要一个特性的就是实时性强，所以流媒体通信需求更难于满足的是对通信系统的传输时延限制。时延限制主要是用在具有实时性要求的交互分布式实时流媒体应用中，如视频会议系统，为防止时延给交互式通信带来不便，建议的最大端到端的总时延不要超过150ms，否则交互双方会感到明显的时延，给双方的信息交流带来不便。端到端的时延可分为以下四个部分：

1．信息源的媒体采样、压缩编码和打包的时延；

2．传输时延；

3．接收端的排队和播放缓冲时延；

4．接收端的拆包、解码和输出时延。

![img](/images/multimedia/Center-16623018803475.jpeg)

抖动定义为网络传输延时的变化率。时延抖动对流媒体播放质量的影响非常大，一般会采用缓存排队的办法平滑数据报的抖动。但如果数据传输的抖动较大，则必须采用大的缓存，这将直接造成更大的时延，直接影响流媒体的体验效果。

3.丢包率
流媒体数据传输中的时延和抖动是可以通过缓存的办法减少影响，所以流媒体业务可以允许在一定范围内的时延和抖动。但丢包会对流媒体数，据播放质量造成极其重大的影响。丢包率会造成视频和音频质量严重恶化，小的丢包率会造成图像的失真和语音的间歇中断，过高的丢包率甚至可以导致业务的中断。网络设计的目标是丢包率为零，但显然不存在这样的理想网络。所以丢包的大小将直接决定流媒体业

![img](/images/multimedia/Center-16623018931268.jpeg)


# 封装格式
|名称|推出机构|流媒体|支持的视频编码|支持的音频编码|目前使用领域|
|--|--|--|--|--|--|
|AVI|Microsoft Inc.|不支持|几乎所有格式|几乎所有格式|BT下载影视||MP4|MPEG|支持|MPEG-2, MPEG-4, H.264, H.263等|AAC, MPEG-1 Layers I, II, III, AC-3等|互联网视频网站|
|TS|MPEG|支持|MPEG-1, MPEG-2, MPEG-4, H.264|MPEG-1 Layers I, II, III, AAC,|IPTV，数字电视|
|FLV|Adobe Inc.|支持|Sorenson, VP6, H.264|MP3, ADPCM, Linear PCM, AAC等|互联网视频网站|
|MKV|CoreCodec Inc.|支持|几乎所有格式|几乎所有格式|互联网视频网站|
|RMVB|Real Networks Inc.|支持|RealVideo 8, 9, 10|AAC, Cook Codec, RealAudio Lossless|BT下载影视|



编码学习-H264&AAC

[视音频编解码学习工程：H.264分析器](http://blog.csdn.net/leixiaohua1020/article/details/17933821)

[视音频编解码学习工程：AAC格式分析器](http://blog.csdn.net/leixiaohua1020/article/details/18155549)









> [视音频编解码技术零基础学习方法](https://blog.csdn.net/leixiaohua1020/article/details/18893769)
>
> [视频参数（流媒体系统，封装格式，视频编码，音频编码，播放器）对比](https://blog.csdn.net/leixiaohua1020/article/details/11842919)
>
> 