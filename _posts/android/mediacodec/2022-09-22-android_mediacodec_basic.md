---
layout: post
title: Android MediaCodec开发详解
categories: [android]
description: 详细介绍Android MediaCodec音视频编解码
keywords: android, mediacodec
dashang: true
topmost: false
tags: [mediacodec, android]
date:  2022-09-22 8:16:00 +0800
---
[MediaCodec](https://developer.android.com/reference/android/media/MediaCodec)是Android的原生视频编码/解码 API。要在 Android 设备上使用硬件加速进行编码/解码，必须使用 MediaCodec。
<!-- more -->

# **MediaCodec**

从API 16开始，Android提供了Mediacodec类以便开发者更加灵活的处理音视频的编解码，与MediaPlayer/VideoView等**high-level APIs**相比，MediaCodec是**low-level APIs**，因此它提供了更加完善、灵活、丰富的接口，开发者可以实现更加灵活的功能。废话即止，开始学习之旅~~

**public final class MediaCodec extends Object**

**Java.lang.Object**

　　**→ android.media.MediaCodec**

　　MediaCodec类可用于访问Android底层的多媒体编解码器，例如，编码器/解码器组件。它是Android底层多媒体支持基础架构的一部分（通常与MediaExtractor, MediaSync, MediaMuxer, MediaCrypto, MediaDrm, Image, Surface, 以及AudioTrack一起使用）。

![img](/images/android/mediacodec/979092-20210819142813293-1006410283.png)

　　从广义上讲，编解码器就是处理输入数据来产生输出数据。MediaCode采用异步方式处理数据，并且使用了一组输入输出缓存（input and output buffers）。简单来讲，你请求或接收到一个空的输入缓存（input buffer），向其中填充满数据并将它传递给编解码器处理。编解码器处理完这些数据并将处理结果输出至一个空的输出缓存（output buffer）中。最终，你请求或接收到一个填充了结果数据的输出缓存（output buffer），使用完其中的数据，并将其释放给编解码器再次使用。

##  数据类型（Data Types）

　　编解码器可以处理三种类型的数据：压缩数据（即为经过H254. H265. 等编码的视频数据或AAC等编码的音频数据）、原始音频数据、原始视频数据。三种类型的数据均可以利用ByteBuffers进行处理，但是对于原始视频数据应提供一个Surface以提高编解码器的性能。Surface直接使用本地视频数据缓存（native video buffers），而没有映射或复制数据到ByteBuffers，因此，这种方式会更加高效。在使用Surface的时候，通常不能直接访问原始视频数据，但是可以使用ImageReader类来访问非安全的解码（原始）视频帧。这仍然比使用ByteBuffers更加高效，因为一些本地缓存（native buffer）可以被映射到 direct ByteBuffers。当使用ByteBuffer模式，你可以利用Image类和getInput/OutputImage(int)方法来访问到原始视频数据帧。

### 　　压缩缓存（Compressed Buffers）

　　输入缓存（对于解码器）和输出缓存（对编码器）中包含由多媒体格式类型决定的压缩数据。对于视频类型是单个压缩的视频帧。对于音频数据通常是单个可访问单元(一个编码的音频片段，通常包含几毫秒的遵循特定格式类型的音频数据)，但这种要求也不是十分严格，一个缓存内可能包含多个可访问的音频单元。在这两种情况下，缓存不会在任意的字节边界上开始或结束，而是在帧或可访问单元的边界上开始或结束。

### 　　原始音频缓存（Raw Audio Buffers）

　　原始的音频数据缓存包含完整的PCM（脉冲编码调制）音频数据帧，这是每一个通道按照通道顺序的一个样本。每一个样本是一个按照本机字节顺序的16位带符号整数（16-bit signed integer in native byte order）。

```
 1 short[] getSamplesForChannel(MediaCodec codec, int bufferId, int channelIx) {
 2 　　ByteBuffer outputBuffer = codec.getOutputBuffer(bufferId);
 3 　　MediaFormat format = codec.getOutputFormat(bufferId);
 4 　　ShortBuffer samples = outputBuffer.order(ByteOrder.nativeOrder()).asShortBuffer();
 5 　　int numChannels = formet.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
 6 　　if (channelIx < 0 || channelIx >= numChannels) {
 7 　　　　return null;
 8 　　}
 9 　　short[] res = new short[samples.remaining() / numChannels];
10 　　for (int i = 0; i < res.length; ++i) {
11 　　　　res[i] = samples.get(i * numChannels + channelIx);
12 　　}
13 　　return res;
14 }
```

### 　　原始视频缓存（Raw Video Buffers）

　　在ByteBuffer模式下，视频缓存（video buffers）根据它们的颜色格式（color format）进行展现。你可以通过调用getCodecInfo().getCapabilitiesForType(…).colorFormats方法获得编解码器支持的颜色格式数组。视频编解码器可以支持三种类型的颜色格式：

- **本地原始视频格式（native raw video format）**：这种格式通过COLOR_FormatSurface标记，并可以与输入或输出Surface一起使用。
- **灵活的YUV缓存（flexible YUV buffers）**(例如：COLOR_FormatYUV420Flexible)：利用一个输入或输出Surface，或在在ByteBuffer模式下，可以通过调用getInput/OutputImage(int)方法使用这些格式。
- **其他，特定的格式（other, specific formats）**：通常只在ByteBuffer模式下被支持。有些颜色格式是特定供应商指定的。其他的一些被定义在 MediaCodecInfo.CodecCapabilities中。这些颜色格式同 flexible format相似，你仍然可以使用 getInput/OutputImage(int)方法。

　　从Android 5.1（LOLLIPOP_MR1）开始，所有的视频编解码器都支持灵活的YUV4:2:0缓存（flexible YUV 4:2:0 buffers）。

## 状态（States）

 　在编解码器的生命周期内有三种理论状态：**停止态-Stopped**、**执行态-Executing**、**释放态-Released**，停止状态（Stopped）包括了三种子状态：未初始化（Uninitialized）、配置（Configured）、错误（Error）。执行状态（Executing）在概念上会经历三种子状态：刷新（Flushed）、运行（Running）、流结束（End-of-Stream）。

![img](/images/android/mediacodec/979092-20210819142813257-1137279100.png)

- 当你使用任意一种工厂方法（factory methods）创建了一个编解码器，此时编解码器处于未初始化状态（Uninitialized）。首先，你需要使用configure(…)方法对编解码器进行配置，这将使编解码器转为配置状态（Configured）。然后调用start()方法使其转入执行状态（Executing）。在这种状态下你可以通过上述的缓存队列操作处理数据。
- 执行状态（Executing）包含三个子状态： 刷新（Flushed）、运行（ Running） 以及流结束（End-of-Stream）。在调用start()方法后编解码器立即进入刷新子状态（Flushed），此时编解码器会拥有所有的缓存。一旦第一个输入缓存（input buffer）被移出队列，编解码器就转入运行子状态（Running），编解码器的大部分生命周期会在此状态下度过。当你将一个带有**end-of-stream** 标记的输入缓存入队列时，编解码器将转入流结束子状态（End-of-Stream）。在这种状态下，编解码器不再接收新的输入缓存，但它仍然产生输出缓存（output buffers）直到**end-of- stream**标记到达输出端。你可以在执行状态（Executing）下的任何时候通过调用flush()方法使编解码器重新返回到刷新子状态（Flushed）。
- 通过调用stop()方法使编解码器返回到未初始化状态（Uninitialized），此时这个编解码器可以再次重新配置 。当你使用完编解码器后，你必须调用release()方法释放其资源。
- 在极少情况下编解码器会遇到错误并进入错误状态（Error）。这个错误可能是在队列操作时返回一个错误的值或者有时候产生了一个异常导致的。通过调用 reset()方法使编解码器再次可用。你可以在任何状态调用reset()方法使编解码器返回到未初始化状态（Uninitialized）。否则，调用 release()方法进入最终的Released状态。

## 创建（Creation）

　　根据指定的MediaFormat使用MediaCodecList创建一个MediaCodec实例。在解码文件或数据流时，你可以通过调用MediaExtractor.getTrackFormat方法获得所期望的格式（media format）。并调用MediaFormat.setFeatureEnabled方法注入任何你想要添加的特定属性，然后调用MediaCodecList.findDecoderForFormat方法获得可以处理指定的媒体格式的编解码器的名字。最后，通过调用createByCodecName(String)方法创建一个编解码器。

　　**注意**：在Android 5.0 （LOLLIPOP）上，传递给MediaCodecList.findDecoder/EncoderForFormat的格式不能包含帧率-frame rate。通过调用format.setString(MediaFormat.KEY_FRAME_RATE, null)方法清除任何存在于当前格式中的帧率。

　　你也可以根据MIME类型利用createDecoder/EncoderByType(String)方法创建一个你期望的编解码器。然而，这种方式不能够给编解码器加入指定特性，而且创建的编解码器有可能不能处理你所期望的媒体格式。

　　**创建安全的解码器（Creating secure decoders）**

　　在Android 4.4（KITKAT_WATCH）及之前版本，安全的编解码器（secure codecs）没有被列在MediaCodecList中，但是仍然可以在系统中使用。安全编解码器只能够通过名字进行实例化，其名字是在常规编解码器的名字后附加.secure标识（所有安全编解码器的名字都必须以.secure结尾），调用createByCodecName(String)方法创建安全编解码器时，如果系统中不存在指定名字的编解码器就会抛出IOException异常。

　　从Android 5.0(LOLLIPOP）及之后版本，你可以在媒体格式中使用FEATURE_SecurePlayback属性来创建一个安全编解码器。

## 初始化（Initialization）

　　在创建了编解码器后，如果你想异步地处理数据，可以通过调用setCallback方法设置一个回调方法。然后，使用指定的媒体格式配置编解码器。这时你可以为视频原始数据产生者（例如视频解码器）指定输出Surface。此时你也可以为secure 编解码器设置解密参数（详见MediaCrypto） 。最后，因为编解码器可以工作于多种模式，你必须指定是该编码器是作为一个解码器（decoder）还是编码器（encoder）运行。

　　从API LOLLIPOP起，你可以在Configured 状态下查询输入和输出格式的结果。在开始编解码前你可以通过这个结果来验证配置的结果，例如，颜色格式。

　　如果你想将原始视频数据（raw video data）送视频消费者处理（将原始视频数据作为输入的编解码器，例如视频编码器），你可以在配置好视频消费者编解码器（encoder）后调用createInputSurface方法创建一个目的surface来存放输入数据，如此，调用视频生产者（decoder）的setInputSurface(Surface)方法将前面创建的目的Surface配置给视频生产者作为输出缓存位置。

　　**Codec-specific数据**

　　有些格式，特别是ACC音频和MPEG4、H.264和H.265视频格式要求实际数据以若干个包含配置数据或编解码器指定数据的缓存为前缀。当处理这种压缩格式的数据时，这些数据必须在调用start()方法后且在处理任何帧数据之前提交给编解码器。这些数据必须在调用queueInputBuffer方法时使用BUFFER_FLAG_CODEC_CONFIG进行标记。

　　Codec-specific数据也可以被包含在传递给configure方法的格式信息（MediaFormat）中，在ByteBuffer条目中以"csd-0", "csd-1"等key标记。这些keys一直包含在通过MediaExtractor获得的Audio Track or Video Track的MediaFormat中。一旦调用start()方法，MediaFormat中的Codec-specific数据会自动提交给编解码器；你**不能**显示的提交这些数据。如果MediaFormat中不包含编解码器指定的数据，你可以根据格式要求，按照正确的顺序使用指定数目的缓存来提交codec-specific数据。在H264 AVC编码格式下，你也可以连接所有的codec-specific数据并作为一个单独的codec-config buffer提交。

　　Android 使用下列的codec-specific data buffers。对于适当的MediaMuxer轨道配置，这些也要在轨道格式中进行设置。每一个参数集以及被标记为（*）的codec-specific-data段必须以"\x00\x00\x00\x01"字符开头。

![img](/images/android/mediacodec/979092-20160705174319499-795768318.png)

**注意：**当编解码器被立即刷新或start之后不久刷新，并且在任何输出buffer或输出格式变化被返回前需要特别地小心，因为编解码器的codec specific data可能会在flush过程中丢失。为保证编解码器的正常运行，你必须在刷新后使用标记为BUFFER_FLAG_CODEC_CONFIGbuffers的buffers再次提交这些数据。

　　 编码器（或者产生压缩数据的编解码器）将会在有效的输出缓存之前产生和返回编解码器指定的数据，这些数据会以codec-config flag进行标记。包含codec-specific-data的Buffers没有有意义的时间戳。 

## 数据处理（Data Processing）

 　每一个编解码器都包含一组输入和输出缓存（input and output buffers），这些缓存在API调用中通过buffer-id进行引用。当成功调用start()方法后客户端将不会“拥有”输入或输出buffers。在同步模式下，通过调用dequeueInput/OutputBuffer(…) 方法从编解码器获得（取得所有权）一个输入或输出buffer。在异步模式下，你可以通过MediaCodec.Callback.onInput/OutputBufferAvailable(…)的回调方法自动地获得可用的buffers。

　　在获得一个输入buffe后，向其中填充数据，并利用queueInputBuffer方法将其提交给编解码器，若使用解密，则利用queueSecureInputBuffer方法提交。不要提交多个具有相同时间戳的输入buffers（除非它是也被同样标记的codec-specific data）。

　　在异步模式下通过onOutputBufferAvailable方法的回调或者在同步模式下响应dequeuOutputBuffer的调用，编解码器返回一个只读的output buffer。在这个output buffer被处理后，调用一个releaseOutputBuffer方法将这个buffer返回给编解码器。

　　当你不需要立即向编解码器重新提交或释放buffers时，保持对输入或输出buffers的所有权可使编解码器停止工作，当然这些行为依赖于设备情况。**特别地，编解码器可能延迟产生输出buffers直到输出的buffers被释放或重新提交。**因此，尽可能短时间地持有可用的buffers。

　　根据API版本情况，你有三种处理相关数据的方式：

![img](/images/android/mediacodec/979092-20160706145621077-1647993881.png)

### 　　使用缓存的异步处理方式（Asynchronous Processing using Buffers）

　　 从Android 5.0（LOLLIPOP）开始，首选的方法是调用configure之前通过设置回调异步地处理数据。异步模式稍微改变了状态转换方式，因为你必须在调用flush()方法后再调用start()方法才能使编解码器的状态转换为Running子状态并开始接收输入buffers。同样，初始调用start方法将编解码器的状态直接变化为Running 子状态并通过回调方法开始传递可用的输入buufers。

![img](/images/android/mediacodec/979092-20160706162601999-1258547462.png)

　　异步模式下，编解码器典型的使用方法如下：

```
 1  MediaCodec codec = MediaCodec.createByCodecName(name);
 2  MediaFormat mOutputFormat; // member variable
 3  codec.setCallback(new MediaCodec.Callback() {
 4    @Override
 5    void onInputBufferAvailable(MediaCodec mc, int inputBufferId) {
 6      ByteBuffer inputBuffer = codec.getInputBuffer(inputBufferId);
 7      // fill inputBuffer with valid data
 8      …
 9      codec.queueInputBuffer(inputBufferId, …);
10    }
11 
12    @Override
13    void onOutputBufferAvailable(MediaCodec mc, int outputBufferId, …) {
14      ByteBuffer outputBuffer = codec.getOutputBuffer(outputBufferId);
15      MediaFormat bufferFormat = codec.getOutputFormat(outputBufferId); // option A
16      // bufferFormat is equivalent to mOutputFormat
17      // outputBuffer is ready to be processed or rendered.
18      …
19      codec.releaseOutputBuffer(outputBufferId, …);
20    }
21 
22    @Override
23    void onOutputFormatChanged(MediaCodec mc, MediaFormat format) {
24      // Subsequent data will conform to new format.
25      // Can ignore if using getOutputFormat(outputBufferId)
26      mOutputFormat = format; // option B
27    }
28 
29    @Override
30    void onError(…) {
31      …
32    }
33  });
34  codec.configure(format, …);
35  mOutputFormat = codec.getOutputFormat(); // option B
36  codec.start();
37  // wait for processing to complete
38  codec.stop();
39  codec.release();
```

### 　　使用缓存的同步处理方式（Synchronous Processing using Buffers）

　　从Android5.0（LOLLIPOP）开始，即使在同步模式下使用编解码器你应该通过getInput/OutputBuffer(int) 和/或 getInput/OutputImage(int) 方法检索输入和输出buffers。这允许通过框架进行某些优化，例如，在处理动态内容过程中。如果你调用getInput/OutputBuffers()方法这种优化是不可用的。

　　注意，不要同时混淆使用缓存和缓存数组的方法。特别地，仅仅在调用start()方法后或取出一个值为INFO_OUTPUT_FORMAT_CHANGED的输出buffer ID后你才可以直接调用getInput/OutputBuffers方法。

　　同步模式下MediaCodec的典型应用如下：

```
 1  MediaCodec codec = MediaCodec.createByCodecName(name);
 2  codec.configure(format, …);
 3  MediaFormat outputFormat = codec.getOutputFormat(); // option B
 4  codec.start();
 5  for (;;) {
 6    int inputBufferId = codec.dequeueInputBuffer(timeoutUs);
 7    if (inputBufferId >= 0) {
 8      ByteBuffer inputBuffer = codec.getInputBuffer(…);
 9      // fill inputBuffer with valid data
10      …
11      codec.queueInputBuffer(inputBufferId, …);
12    }
13    int outputBufferId = codec.dequeueOutputBuffer(…);
14    if (outputBufferId >= 0) {
15      ByteBuffer outputBuffer = codec.getOutputBuffer(outputBufferId);
16      MediaFormat bufferFormat = codec.getOutputFormat(outputBufferId); // option A
17      // bufferFormat is identical to outputFormat
18      // outputBuffer is ready to be processed or rendered.
19      …
20      codec.releaseOutputBuffer(outputBufferId, …);
21    } else if (outputBufferId == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
22      // Subsequent data will conform to new format.
23      // Can ignore if using getOutputFormat(outputBufferId)
24      outputFormat = codec.getOutputFormat(); // option B
25    }
26  }
27  codec.stop();
28  codec.release();
```

### 　　使用缓存数组的同步处理方式（Synchronous Processing using Buffer Arrays）-- (deprecated)

　　在Android 4.4（KITKAT_WATCH）及之前版本，一组输入或输出buffers使用ByteBuffer[]数组表示。在成功调用了start()方法后，通过调用getInput/OutputBuffers()方法检索buffer数组。在这些数组中使用buffer的ID-s（非负数）作为索引，如下面的演示示例中，注意数组大小和系统使用的输入和输出buffers的数量之间并没有固定的关系，尽管这个数组提供了上限边界。

```
 1  MediaCodec codec = MediaCodec.createByCodecName(name);
 2  codec.configure(format, …);
 3  codec.start();
 4  ByteBuffer[] inputBuffers = codec.getInputBuffers();
 5  ByteBuffer[] outputBuffers = codec.getOutputBuffers();
 6  for (;;) {
 7    int inputBufferId = codec.dequeueInputBuffer(…);
 8    if (inputBufferId >= 0) {
 9      // fill inputBuffers[inputBufferId] with valid data
10      …
11      codec.queueInputBuffer(inputBufferId, …);
12    }
13    int outputBufferId = codec.dequeueOutputBuffer(…);
14    if (outputBufferId >= 0) {
15      // outputBuffers[outputBufferId] is ready to be processed or rendered.
16      …
17      codec.releaseOutputBuffer(outputBufferId, …);
18    } else if (outputBufferId == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
19      outputBuffers = codec.getOutputBuffers();
20    } else if (outputBufferId == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
21      // Subsequent data will conform to new format.
22      MediaFormat format = codec.getOutputFormat();
23    }
24  }
25  codec.stop();
26  codec.release();
```

### 　　流结束处理（End-of-stream Handling）

　　当到达输入数据结尾时，你必须在调用queueInputBuffer方法中通过指定BUFFER_FLAG_END_OF_STREAM标记来通知编解码器。你可以在最后一个有效的输入buffer上做这些操作，或者提交一个额外的以end-of-stream标记的空的输入buffer。如果使用一个空的buffer，它的时间戳将被忽略。

　　编解码器将会继续返回输出buffers，直到它发出输出流结束的信号，这是通过指定dequeueOutputBuffer方法中MediaCodec.BufferInfo的end-of-stream标记来实现的，或者是通过回调方法onOutputBufferAvailable来返回end-of-stream标记。可以在最后一个有效的输出buffer中设置或者在最后一个有效的输出buffer后添加一个空的buffer来设置，这种空的buffer的时间戳应该被忽略。

　　当通知输入流结束后不要再提交额外的输入buffers，除非编解码器被刷新或停止或重启。

### 　　使用一个输出表面（Using an Output Surface）

　　使用一个输出Surface进行数据处理的方法与ByteBuffer模式几乎是相同的，然而，输出buffers不再可访问，而且被表示为null值。E.g.方法getOutputBuffer/Image(int)将返回null，方法getOutputBuffers()将返回仅包含null值的数组。

　　当使用一个输出Surface时，你能够选择是否渲染surface上的每一个输出buffer，你有三种选择：

- **不要渲染这个buffer（Do not render the buffer）**：通过调用releaseOutputBuffer(bufferId, false)。
- **使用默认的时间戳渲染这个buffer（Render the buffer with the default timestamp**）：调用releaseOutputBuffer(bufferId, true)。
- **使用指定的时间戳渲染这个buffer（Render the buffer with a specific timestamp）**：调用 releaseOutputBuffer(bufferId, timestamp)。

　　从Android6.0(M)开始，默认的时间戳是buffer的presentation timestamp（转换为纳秒）。在此前的版本中这是没有被定义的。

　　而且，从Android6.0(M)开始，你可以通过使用setOutputSurface方法动态地改变输出Surface。

### 　　使用一个输入表面（Using an Input Surface）

　　当使用输入Surface时，将没有可访问的输入buffers,因为这些buffers将会从输入surface自动地向编解码器传输。调用dequeueInputBuffer时将抛出一个IllegalStateException异常，调用getInputBuffers()将要返回一个**不能**写入的伪ByteBuffer[]数组。

　　调用**signalEndOfInputStream()**方法发送end-of-stream信号。调用这个方法后，输入surface将会立即停止向编解码器提交数据。

## 查询&自适应播放支持（Seeking & Adaptive Playback Support）

　　视频解码器（通常指处理压缩视频数据的编解码器）关于搜索-seek和格式转换（不管它们是否支持）表现不同，且被配置为adaptive playback。你可以通过调用CodecCapabilities.isFeatureSupported(String)方法来检查解码器是否支持adaptive playback 。支持Adaptive playback的解码器只有在编解码器被配置在Surface上解码时才被激活。

　　**流域界与关键帧（Stream Boundary and Key Frames）**

　　在调用start()或flush()方法后，输入数据在合适的流边界开始是非常重要的：其**第一帧必须是关键帧（key-frame）**。一个关键帧能够独立地完全解码（对于大多数编解码器它意味着I-frame），关键帧之后显示的帧不会引用关键帧之前的帧。

　　下面的表格针对不同的视频格式总结了合适的关键帧。

![img](/images/android/mediacodec/979092-20160707154342546-2108967677.png)

　　**对于不支持adaptive playback的解码器（包括解码到Surface上解码器）**

　　为了开始解码与先前提交的数据（也就是seek后）不相邻的数据你**必须**刷新解码器。由于所有输出buffers会在flush的一刻立即撤销，你可能希望在调用flush方法前等待这些buffers首先被标记为end-of-stream。在调用flush方法后输入数据在一个合适的流边界或关键帧开始是非常重要的。

　　**注意**：flush后提交的数据的格式不能改变；flush()方法不支持格式的不连续性；为此，一个完整的stop()-configure(...)-start()的过程是必要的。

　　**同时注意**：如果你调用start()方法后过快地刷新编解码器，通常，在收到第一个输出buffer或输出format变化前，你需要向这个编解码器再次提交codec-specific-data。具体查看codec-specific-data部分以获得更多信息。

　　**对于支持及被配置为adaptive playback的几码器**

　　为了开始解码与先前提交的数据（也就是seek后）不相邻的数据，你没有必要刷新解码器；然而，在间断后传入的数据必须开始于一个合适的流边界或关键帧。

　　针对一些视频格式-也就是H.264、H.265、VP8和VP9，也可以修改图片大小或者配置mid-stream。为了做到这些你必须将整个新codec-specific配置数据与关键帧一起打包到一个单独的buffer中（包括所有的开始数据），并将它作为一个**常规**的输入数据提交。

　　在picture-size被改变后以及任意具有新大小的帧返回之前，你可以从dequeueOutputBuffer方法或onOutputFormatChanged回调中得到 INFO_OUTPUT_FORMAT_CHANGED的返回值。

　　**注意**：就像使用codec-specific data时的情况，在你修改图片大小后立即调用fush()方法时需要非常小心。如果你没有接收到图片大小改变的确认信息，你需要重试修改图片大小的请求。

## 错误处理（Error handling）

　　工厂方法createByCodecName以及createDecoder/EncoderByType会在创建codec失败时抛出一个IOException，你必须捕获异常或声明向上传递异常。在编解码器不允许使用该方法的状态下调用时，MediaCodec方法将会抛出IllegalStateException异常；这种情况一般是由于API接口的不正确调用引起的。涉及secure buffers的方法可能会抛出一个MediaCodec.CryptoException异常，可以调用getErrorCode()方法获得更多的异常信息。

　　内部的编解码器错误将导致MediaCodec.CodecException，这可能是由于media内容错误、硬件错误、资源枯竭等原因所致，即使你已经正确的使用了API。当接收到一个CodecException时，可以调用isRecoverable()和isTransient()两个方法来决定建议的行为。

- **可恢复错误（recoverable errors）**：如果isRecoverable() 方法返回true,然后就可以调用stop(),configure(...),以及start()方法进行修复。
- **短暂错误（transient errors）**：如果isTransient()方法返回true,资源短时间内不可用，这个方法可能会在一段时间之后重试。
- **致命错误（fatal errors）**：如果isRecoverable()和isTransient()方法均返回fase，CodecException错误是致命的，此时就必须reset这个编解码器或调用released方法释放资源。

　　isRecoverable()和isTransient()方法不可能同时都返回true。

## 合法的API调用和API历史（Valid API Calls and API History）

　　下面的表格总结了MediaCodec中合法的API以及API历史版本。更多的API版本号详见Build.VERSION_CODES。

### 嵌套类（Nested classes）

| Nested classes--嵌套类（内部类） |                                                              |
| -------------------------------- | ------------------------------------------------------------ |
| class                            | `MediaCodec.BufferInfo` 每一个缓存区的元数据都包含有一个偏移量offset和大小size用于指示相关编解码器（输出）缓存中有效数据的范围。 |
| class                            | `MediaCodec.Callback`MediaCodec回调接口。                    |
| class                            | `MediaCodec.CodecException`当发生内部的编解码器错误是抛出。  |
| class                            | `MediaCodec.CryptoException`在入队列一个安全的输入缓存过程中发生加密错误时抛出。 |
| class                            | `MediaCodec.CryptoInfo`描述（至少部分地）加密的输入样本的结构的元数据。 |
| interface                        | `MediaCodec.OnFrameRenderedListener`当一个输出帧在输出surface上呈现时，监听器被调用。 |

常量（Constants）

| Constants--常量 |                                                              |
| --------------- | ------------------------------------------------------------ |
| int             | BUFFER_FLAG_CODEC_CONFIG这表示带有此标记的缓存包含编解码器初始化或编解码器特定的数据而不是多媒体数据media data。常量值：2（0x00000002） |
| int             | BUFFER_FLAG_END_OF_STREAM它表示流结束，该标志之后不会再有可用的buffer，除非接下来对Codec执行flush()方法。常量值：4（0x00000004） |
| int             | BUFFER_FLAG_KEY_FRAME这表示带有此标记的（编码的）缓存包含关键帧数据。常量值：1（0x00000001） |
| *int*           | *BUFFER_FLAG_SYNC_FRAME**这个常量在API level 21中弃用，使用BUFFER_FLAG_KEY_FRAME代替。**这表示带有此标记的（编码的）缓存包含关键帧数据。**常量值：1（0x00000001）* |
| int             | CONFIGURE_FLAG_ENCODE如果编解码器被用作编码器，传递这个标志。常量值：1（0x00000001） |
| int             | CRYPTO_MODE_AES_CBC常量值：2（0x00000002）                   |
| int             | CRYPTO_MODE_AES_CTR常量值：1（0x00000001）                   |
| int             | CRYPTO_MODE_UNENCRYPTED常量值：0（0x00000000）               |
| int             | INFO_OUTPUT_BUFFERS_CHANGED                                  |
| int             | INFO_OUTPUT_FORMAT_CHANGED                                   |
| int             | INFO_TRY_AGAIN_LATER                                         |
| String          | PARAMETER_KEY_REQUEST_SYNC_FRAME                             |
| String          | PARAMETER_KEY_SUSPEND                                        |
| String          | PARAMETER_KEY_VIDEO_BITRATE                                  |
| int             | VIDEO_SCALING_MODE_SCALE_TO_FIT                              |
| int             | VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING                |

###  

### 公有方法（Public methods）

**configure**

void configure ([MediaFormat](https://developer.android.com/reference/android/media/MediaFormat.html) format, [Surface](https://developer.android.com/reference/android/view/Surface.html) surface, [MediaCrypto](https://developer.android.com/reference/android/media/MediaCrypto.html) crypto, int flags)

配置一个组件。

| 参数说明 |                                                              |
| -------- | ------------------------------------------------------------ |
| format   | MediaFormat : 输入数据的格式（解码器）或期望的输出数据的格式（编码器）。format为null时等价于empty format. |
| surface  | Surface : 指定一个surface用于显示解码器的输出。如果codec没有产生raw video output（不是一个视频解码器），或者把codec配置为ByteBuffer输出模式时，surface值为null。 |
| crypto   | MediaCryto : 指定一个cryto对象实现媒体数据的安全解密，cryto为null时是non-secure codecs |
| flags    | int : 指定为CONFIGURE_FLAG_ENCODE时将该组件配置为编码器      |

| 抛出异常                    |                                                              |
| --------------------------- | ------------------------------------------------------------ |
| IllegalArgumentException    | surface已经释放（或非法），或format不可接受（e.g. 丢失了强制秘钥），或flags设置不合适(e.g. encoder时忽略了CONFIGURE_FLAG_ENCODE) |
| IllegalStateException       | 不在未初始化状态                                             |
| MediaCodec.CryptoException  | DRM错误                                                      |
| `MediaCodec.CodecException` | Codec错误                                                    |

**Start**

void start（）

成功地配置组件后，调用start方法。

如果codec在异步模式下被配置且处于flushed状态，为处理要求的的输入buffer，也需调用start方法。

| 抛出异常                  |                                                              |
| ------------------------- | ------------------------------------------------------------ |
| IllegalStateException     | 如果codec不处于configured状态或异步模式下的codec执行flush()方法后，调用start()方法抛出该异常 |
| MediaCodec.CodecException | codec错误。注意对于start时的一些codec error可能是由于后续方法调用引起的。 |

**dequeueInputBuffer**

int dequeueInputBuffer(long timeoutUs)

返回一个填充了有效数据的input buffer的索引，如果没有可用的buffer则返回-1.当timeoutUs==0时，该方法立即返回；当timeoutUs<0时，无限期地等待一个可用的input buffer;当timeoutUs>0时，至多等待timeoutUs微妙。

| 参数说明                  |                                                     |
| ------------------------- | --------------------------------------------------- |
| timeoutUs                 | long : 微妙单位，负值代表无限期。                   |
| 返回值                    |                                                     |
| int                       |                                                     |
| 抛出异常                  |                                                     |
| IllegalStateException     | 如果codec不在Executing状态，或者codec处于异步模式。 |
| MediaCodec.CodecException | codec错误                                           |

**queueInputBuffer（没完全理解）**

void queueInputbuffer(int index, int offset, int size, long presentationtimeUs, int flags)

给指定索引的input buffer填充数据后，将其提交给codec组件。一旦一个input buffer在codec中排队，它就不再可用直到通过getInputBuffer(int)重新获取，getInputBuffer(int)是对dequeueInputbuffer(long)的返回值或onInputBufferAvailable(MediaCodec, int)回调的响应。

许多解码器要求实际压缩数据流以“codec specific data”为先导，也就是用于初始化codec的设置数据，例如AVC视频情况时的PPS/SPS，或vorbis音频情况时的code tables。MediaExtractor类提供codec specific data作为返回的track format的一部分，在命名为csd-0,csd-1的条目中。

通过指定BUFFER_FLAG_CODEC_CONFIG，这些buffers可以在start()或flush()后直接提交。然而，如果你使用包含这些keys的MediaFormat配置codec，他们将在start后自动地提交。因此，不鼓励使用BUFFER_FLAG_CODEC_CONFIG，仅推荐高级用户使用。

为了指示输入数据的最后一块（或除非decoder flush否则不再有输入数据）需指定DUFFER_FLAG_END_OF_STREAM。

　　**注意：**android6.0（M）之前，presentationTimeUs不会传递到Surface output buffer 的帧的时间戳，这会导致帧的时间戳没有定义。使用releaseOutputBuffer(int, long)方法确保一个指定的时间戳被设置。同样地，尽管frame timestamp可以被destination surface用于同步渲染，必须注意presentationTimeUs正常化,以便不被误认为是一个系统时间。

| 参数说明                   |                                                              |
| -------------------------- | ------------------------------------------------------------ |
| index                      | int : 调用dequeueInputBuffer(long)方法返回的持有者所有的input buffer的索引。 |
| offset                     | int : input buffer中数据起始位置的字节偏移量。               |
| size                       | int : 有效输入数据的字节数。                                 |
| presentationTimeUs         | long : 这个buffer提交呈现的时间戳（微妙），它通常是指这个buffer应该提交或渲染的media time。当使用output surface时，将作为timestamp传递给frame（转换为纳秒后）。 |
| flags                      | int : BUFFER_FLAG_CODEC_CONFIG和BUFFER_FLAG_END_OF_STREAM的位掩码。当没有禁止时，大多数codecs不会在input buffer中使用BUFFER_FLAG_KEY_FRAME。 |
| 抛出异常                   |                                                              |
| IllegalStateException      | 如果没有在Executing状态                                      |
| MediaCodec.CodecException  | codec错误                                                    |
| MediaCodec.CryptoException | 如果cryto对象已经在configure（MediaFormat, Surface, MediaCryto, int）中指定。 |

**release**

void release()

释放codec实例使用的资源。释放任何开放的组件实例时调用该方法，而不是依赖于垃圾回收机制在以后某个时间完成资源的释放。

**reset**

void reset()

使codec返回到初始（未初始化）状态。如果发生了不可恢复的错误，调用该方法使codec复位到创建时的初始状态。

| 抛出异常                  |                                                |
| ------------------------- | ---------------------------------------------- |
| MediaCodec.CodecException | 如果codec发生了不可恢复的错误且codec不能reset. |
| IllegalStateException     | 如果codec处于released状态。                    |

**stop**

void stop()

完成解码/编码任务后，需注意的是codec任然处于活跃状态且准备重新start。为了确保其他client可以调用release()方法，且不仅仅只依赖于garbage collection为你完成这些工作。

| 抛出异常              |                             |
| --------------------- | --------------------------- |
| IllegalStateException | 如果codec处于Released状态。 |

**flush**

void flush()

冲洗组件的输入和输出端口。

返回时，所有之前通过调用dequeueInputBuffer方法和dequeueOutputBuffer方法或通过onInputBufferAvailable和onOutputBufferAvailable回调获得的索引会失效。所有的buffers都属于codec。

如果codec被配置为异步模式，flush后调用start()重新开始codec操作。编解码器不会请求输入缓冲区,直到这已经发生了。

如果codec配置为同步模式，配置时使用了一个input buffer时codec会自动重新开始，否则，当调用dequeueInputBuffer时重新开始。

| 抛出异常                  |                                |
| ------------------------- | ------------------------------ |
| IllegalStateException     | 如果codec没有处于Executing状态 |
| MediaCodec.CodecException | codec错误                      |

MediaFormat

Keys common to all audio/video formats, **all keys not marked optional are mandatory**:

| Name                            | Value Type | Description                                             |
| :------------------------------ | :--------- | :------------------------------------------------------ |
| `KEY_MIME`                      | String     | The type of the format.                                 |
| `KEY_CODECS_STRING`             | String     | optional, the RFC 6381 codecs string of the MediaFormat |
| `KEY_MAX_INPUT_SIZE`            | Integer    | optional, maximum size of a buffer of input data        |
| `KEY_PIXEL_ASPECT_RATIO_WIDTH`  | Integer    | optional, the pixel aspect ratio width                  |
| `KEY_PIXEL_ASPECT_RATIO_HEIGHT` | Integer    | optional, the pixel aspect ratio height                 |
| `KEY_BIT_RATE`                  | Integer    | **encoder-only**, desired bitrate in bits/second        |
| `KEY_DURATION`                  | long       | the duration of the content (in microseconds)           |

Video formats have the following keys:

| Name                              | Value Type         | Description                                                  |
| :-------------------------------- | :----------------- | :----------------------------------------------------------- |
| `KEY_WIDTH`                       | Integer            |                                                              |
| `KEY_HEIGHT`                      | Integer            |                                                              |
| `KEY_COLOR_FORMAT`                | Integer            | set by the user for encoders, readable in the output format of decoders |
| `KEY_FRAME_RATE`                  | Integer or Float   | required for **encoders**, optional for **decoders**         |
| `KEY_CAPTURE_RATE`                | Integer            |                                                              |
| `KEY_I_FRAME_INTERVAL`            | Integer (or Float) | **encoder-only**, time-interval between key frames. Float support added in `Build.VERSION_CODES.N_MR1` |
| `KEY_INTRA_REFRESH_PERIOD`        | Integer            | **encoder-only**, optional                                   |
| `KEY_LATENCY`                     | Integer            | **encoder-only**, optional                                   |
| `KEY_MAX_WIDTH`                   | Integer            | **decoder-only**, optional, max-resolution width             |
| `KEY_MAX_HEIGHT`                  | Integer            | **decoder-only**, optional, max-resolution height            |
| `KEY_REPEAT_PREVIOUS_FRAME_AFTER` | Long               | **encoder in surface-mode only**, optional                   |
| `KEY_PUSH_BLANK_BUFFERS_ON_STOP`  | Integer(1)         | **decoder rendering to a surface only**, optional            |
| `KEY_TEMPORAL_LAYERING`           | String             | **encoder only**, optional, temporal-layering schema         |

Specify both `KEY_MAX_WIDTH` and `KEY_MAX_HEIGHT` to enable adaptive playback (seamless resolution change) for a video decoder that supports it (`MediaCodecInfo.CodecCapabilities#FEATURE_AdaptivePlayback`). The values are used as hints for the codec: they are the maximum expected resolution to prepare for. Depending on codec support, preparing for larger maximum resolution may require more memory even if that resolution is never reached. These fields have no effect for codecs that do not support adaptive playback.

Audio formats have the following keys:

| Name                                 | Value Type | Description                                                  |
| :----------------------------------- | :--------- | :----------------------------------------------------------- |
| `KEY_CHANNEL_COUNT`                  | Integer    |                                                              |
| `KEY_SAMPLE_RATE`                    | Integer    |                                                              |
| `KEY_PCM_ENCODING`                   | Integer    | optional                                                     |
| `KEY_IS_ADTS`                        | Integer    | optional, if *decoding* AAC audio content, setting this key to 1 indicates that each audio frame is prefixed by the ADTS header. |
| `KEY_AAC_PROFILE`                    | Integer    | **encoder-only**, optional, if content is AAC audio, specifies the desired profile. |
| `KEY_AAC_SBR_MODE`                   | Integer    | **encoder-only**, optional, if content is AAC audio, specifies the desired SBR mode. |
| `KEY_AAC_DRC_TARGET_REFERENCE_LEVEL` | Integer    | **decoder-only**, optional, if content is AAC audio, specifies the target reference level. |
| `KEY_AAC_ENCODED_TARGET_LEVEL`       | Integer    | **decoder-only**, optional, if content is AAC audio, specifies the target reference level used at encoder. |
| `KEY_AAC_DRC_BOOST_FACTOR`           | Integer    | **decoder-only**, optional, if content is AAC audio, specifies the DRC boost factor. |
| `KEY_AAC_DRC_ATTENUATION_FACTOR`     | Integer    | **decoder-only**, optional, if content is AAC audio, specifies the DRC attenuation factor. |
| `KEY_AAC_DRC_HEAVY_COMPRESSION`      | Integer    | **decoder-only**, optional, if content is AAC audio, specifies whether to use heavy compression. |
| `KEY_AAC_MAX_OUTPUT_CHANNEL_COUNT`   | Integer    | **decoder-only**, optional, if content is AAC audio, specifies the maximum number of channels the decoder outputs. |
| `KEY_AAC_DRC_EFFECT_TYPE`            | Integer    | **decoder-only**, optional, if content is AAC audio, specifies the MPEG-D DRC effect type to use. |
| `KEY_AAC_DRC_OUTPUT_LOUDNESS`        | Integer    | **decoder-only**, optional, if content is AAC audio, returns the DRC output loudness. |
| `KEY_AAC_DRC_ALBUM_MODE`             | Integer    | **decoder-only**, optional, if content is AAC audio, specifies the whether MPEG-D DRC Album Mode is active or not. |
| `KEY_CHANNEL_MASK`                   | Integer    | optional, a mask of audio channel assignments                |
| `KEY_ENCODER_DELAY`                  | Integer    | optional, the number of frames to trim from the start of the decoded audio stream. |
| `KEY_ENCODER_PADDING`                | Integer    | optional, the number of frames to trim from the end of the decoded audio stream. |
| `KEY_FLAC_COMPRESSION_LEVEL`         | Integer    | **encoder-only**, optional, if content is FLAC audio, specifies the desired compression level. |
| `KEY_MPEGH_PROFILE_LEVEL_INDICATION` | Integer    | **decoder-only**, optional, if content is MPEG-H audio, specifies the profile and level of the stream. |
| `KEY_MPEGH_COMPATIBLE_SETS`          | ByteBuffer | **decoder-only**, optional, if content is MPEG-H audio, specifies the compatible sets (profile and level) of the stream. |
| `KEY_MPEGH_REFERENCE_CHANNEL_LAYOUT` | Integer    | **decoder-only**, optional, if content is MPEG-H audio, specifies the preferred reference channel layout of the stream. |

Subtitle formats have the following keys:

| `KEY_MIME`                   | String | The type of the format.                                 |
| ---------------------------- | ------ | ------------------------------------------------------- |
| `KEY_LANGUAGE`               | String | The language of the content.                            |
| `KEY_CAPTION_SERVICE_NUMBER` | int    | optional, the closed-caption service or channel number. |

Image formats have the following keys:

| `KEY_MIME`         | String  | The type of the format.                                      |
| ------------------ | ------- | ------------------------------------------------------------ |
| `KEY_WIDTH`        | Integer |                                                              |
| `KEY_HEIGHT`       | Integer |                                                              |
| `KEY_COLOR_FORMAT` | Integer | set by the user for encoders, readable in the output format of decoders |
| `KEY_TILE_WIDTH`   | Integer | required if the image has grid                               |
| `KEY_TILE_HEIGHT`  | Integer | required if the image has grid                               |
| `KEY_GRID_ROWS`    | Integer | required if the image has grid                               |
| `KEY_GRID_COLUMNS` | Integer | required if the image has grid                               |

###  常量（Constants）

| Constants--常量 |                                                              |
| --------------- | ------------------------------------------------------------ |
| int             | BUFFER_FLAG_CODEC_CONFIG这表示带有此标记的缓存包含编解码器初始化或编解码器特定的数据而不是多媒体数据media data。常量值：2（0x00000002） |
| int             | BUFFER_FLAG_END_OF_STREAM它表示流结束，该标志之后不会再有可用的buffer，除非接下来对Codec执行flush()方法。常量值：4（0x00000004） |
| int             | BUFFER_FLAG_KEY_FRAME这表示带有此标记的（编码的）缓存包含关键帧数据。常量值：1（0x00000001） |
| *int*           | *BUFFER_FLAG_SYNC_FRAME**这个常量在API level 21中弃用，使用BUFFER_FLAG_KEY_FRAME代替。**这表示带有此标记的（编码的）缓存包含关键帧数据。**常量值：1（0x00000001）* |
| int             | CONFIGURE_FLAG_ENCODE如果编解码器被用作编码器，传递这个标志。常量值：1（0x00000001） |
| int             | CRYPTO_MODE_AES_CBC常量值：2（0x00000002）                   |
| int             | CRYPTO_MODE_AES_CTR常量值：1（0x00000001）                   |
| int             | CRYPTO_MODE_UNENCRYPTED常量值：0（0x00000000）               |
| int             | INFO_OUTPUT_BUFFERS_CHANGED                                  |
| int             | INFO_OUTPUT_FORMAT_CHANGED                                   |
| int             | INFO_TRY_AGAIN_LATER                                         |
| String          | PARAMETER_KEY_REQUEST_SYNC_FRAME                             |
| String          | PARAMETER_KEY_SUSPEND                                        |
| String          | PARAMETER_KEY_VIDEO_BITRATE                                  |
| int             | VIDEO_SCALING_MODE_SCALE_TO_FIT                              |
| int             | VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING                |

> [AAC](https://blog.csdn.net/xh2009cn/article/details/104722183)
>
> [Mediacodec代码](https://blog.csdn.net/cheriyou_/article/details/92787998)
>
> [测试方法](https://medium.com/nttlabs/android-mediacodec-evaluation-23dee89fe1dd)