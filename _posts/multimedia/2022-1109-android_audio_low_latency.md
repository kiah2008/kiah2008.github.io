Android High performance audio

# 音频延迟

延迟是指信号在系统中传输所需的时间。下面是常见类型的音频应用相关延迟时间：

- **音频输出延迟时间**是指从应用生成音频样本到样本通过耳机插孔或内置扬声器播放之间经历的时间。
- **音频输入延迟时间**是指设备音频输入装置（例如，麦克风）接收到音频信号到这些音频数据可供应用使用所经历的时间。
- **往返延迟时间**是指输入延迟时间、应用处理时间和输出延迟时间的总和。
- **触摸延迟时间**是指从用户触摸屏幕到应用接收到触摸事件之间经历的时间。
- **预热延迟时间**是指数据第一次在缓冲区加入队列后启动音频管道所需的时间。





![image-20221109223308450](assets/image-20221109223308450.png)

Android Audio Pipeline

# Android Latency

Best Android devices currently on the market can go as low as 20 ms for round-trip latency.

`*Round-trip latency is the sum of input latency, app processing time, and output latency.*`

This 20ms latency is called a PRO latency, there is also a LOW latency which guarantee 45ms latency and you can check at runtime if the currently used device supports one of these two features.

```kotlin
val hasLowLatencyFeature: Boolean =
        packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY)

val hasProFeature: Boolean =
        packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO)
```



Lastly, before we take a look at the high performance audio options, a bare minimum of digital audio terminology:

**PCM** — Pulse-code modulation is a standard method in computer science to convert an analog signal to its digital representation. During PCM, continuous analog signal is regularly captured and converted into small audio samples.

**Sampling rate** —A speed at which individual samples are created. Usually it is 44,1 or 48 kHz. This means that PCM produces 44 100 or 48 000 samples per second from an analog signal.

**Sample size** — or a **bit depth** is a maximal amplitude of a sample represented in bits. For example an 8 bit depth, which can represent only 256 levels (2⁸) of an amplitude would have a much lower audio quality and resolution than a standard 16 bit depth which can hold 65536 (2¹⁶) levels of an amplitude.

**Channel** — Can be either mono (1 channel) or stereo (2 channels).

# SoundPool

The SoundPool class can be used to create a collection of samples, from existing resources, that are pre-loaded into memory. This collection can then be played with low latency since there is no CPU load and decompressing during playback.

Apart from basic operations, SoundPool provides several nice-to-have features such as:

- Setting a maximum number of streams that can be played at a time from a single SoundPool
- Prioritisation of playback streams
- Playback rate customisation ranging from 0.5 to 2.0
- Pausing and resuming playback

SoundPool is a convenient tool if you need to play and manage short, often repeated sounds that already exists in your APK or in the filesystem. I would typically use SoundPool to play low-latency UI or game sounds.

# **AudioTrack/AudioRecord**

AudioTrack and AudioRecord are the lowest level APIs you can access while still using Java or Kotlin. AudioTrack is used for audio playback and AudioRecord equivalently for recording audio. They were both added early in Android API level 3 and provide convenient way to work with raw audio data.

I will focus rather on AudioTrack since this article is mainly about audio playback, but feel free to explore AudioRecord also.

AudioTrack can operate under two modes:

- Static
- Streaming

Static mode is better for short sounds that need to played often and with minimal latency, similar to SoundPool. But compared to SoundPool, you can modify or enhance the raw audio data.

In streaming mode you can play sounds that are either too large to fit into memory, because of the length or characteristics of the audio to be played, or that are received or generated on the fly.

I think that AudioTrack is a perfect introductory API to start working with raw audio on Android. Having all the high performance features available, but remaining still in the Java layer..

# OpenSL ES

[OpenSL ES](https://www.khronos.org/opensles/) is a cross-platform, hardware-accelerated audio API tuned for embedded systems, such as mobile devices. Its Android specific implementation comes as a part of the Android NDK, but you need to be aware that there are some limitations compared to standard OpenSL ES specification and maybe optimise existing code a little bit if you are not writing it from scratch.

This API is not meant to be used to write pure C/C++ application, it is more like a one way API, because up-calls to code running in the Android runtime are not expected. But it is a full-featured API which can be used to facilitate the implementation of shared libraries, e.g with an iOS team.

But there is a small catch. According to the documentation, sole use of OpenSL ES on Android does not guarantee performance improvement compared to standard platform solutions. Why is that?

Although OpenSL ES can be used from Android API level 9, significant improvements for audio output latency were added later in Android API level 17 (Android 4.2) and these are only device-specific. Which means you have to check at runtime if the device supports low latency. Not ideal, but the number of low latency devices is growing steadily and to this day there is already a large number of devices on the market already supporting low latency.

So, OpenSL ES might be good for you if you need to share code between platforms, or you are already familiar with it.

# AAudio

[AAudio](https://developer.android.com/ndk/guides/audio/aaudio/aaudio) is a new Android C API introduced in the Android Oreo. It is a pure Android native API designed for high-performance audio applications that require low latency. Something that Android was missing for a long time.

You can write or read from AAudio *audio streams* in your application, and AAudio take care that the passed data moves between your application and audio inputs or outputs on your Android device.

A stream is defined by the following components:

- Audio device
- Sharing mode.
- Audio Format

*Audio device* can be either source or sink for a continuous stream of digital audio data. Don’t confuse this terminology with a real device like a phone or watch, that is running your application.

*Sharing mode* can be EXCLUSIVE or SHARED where exclusive means, that stream has exclusive access to its audio device. Whereas SHARED means that AAudio mixes all the streams assigned to the same device.

*Audio format* is a term for all the standard attributes used in digital audio, that a stream can have. Like sample rate, sample format and samples per frame.

By default *audio stream* has a default performance mode which balances latency and power savings. You can further improve low latency by setting AAUDIO_PERFORMANCE_MODE_LOW_LATENCY mode, which is useful for applications that are very interactive such as musical instruments.

I really liked to try out AAudio, but since the AAudio was introduced in Android Oreo and is not backwards compatible, I believe I wouldn’t be able to use it in a production application. Luckily, there is a solution.

# Oboe

[Oboe](https://github.com/google/oboe) is a new native library by Google that solves the problem with backwards compatibility of AAudio. It works with API 16 and above, which means it’s compatible witch over 99% of Android devices. Internally it uses AAudio on API 27 and above, but falling back to OpenSL ES on older APIs.

This simplified API is something Android had been lacking for a long time and I believe it will become a new native audio standard on Android.

Oboe provides similar features as single AAudio API, such as audio streams, sharing modes and performance modes, so if you are already familiar with AAudio, transition to Oboe should be straightforward.



![image-20221109231537612](assets/image-20221109231537612.png)



![image-20221109233313780](assets/image-20221109233313780.png)





> [oboe](https://github.com/google/oboe)
>
> [Android high performace audio](https://github.com/googlearchive/android-audio-high-performance)
>
> 