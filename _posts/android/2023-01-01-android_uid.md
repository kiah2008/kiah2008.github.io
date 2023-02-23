---
layout: post
title: Android UID理解
categories: [android]
tags: [uid, share uid]
description: Android UID理解
keywords: android uid
dashang: true
topmost: false
mermaid: false
date:  2023-01-01 21:00:00 +0900
---
Android 查看各个 app 的 UID 及 sharedUserId 的使用

<!-- more -->

* TOC
{:toc}
## 一、UID 的概念及查看方式

### 概念

UID：一般理解为 User Identifier 。 UID 在 Linux 中就是用户的 ID （还有 Group ID），表明是哪个用户运行了这个程序，主要用于权限的管理（参考Linux的访问控制机制， DAC&MAC）；在android中有所不同，Android 中每个程序都有一个 UID 。默认情况下，Android 会给每个程序分配一个普通级别互不相同的 UID，如果用互相访问，只能是 UID 相同才行，这就使得共享数据具有一定安全性，每个软件之间是不能随意获得数据的，而同一个 application 只有一个 UID ，所以 application 下的 Activity 之间不存在访问权限的问题。

Android 的应用的 UID 是从 10000 开始，可以在 Process.java 中查看到 **FIRST_APPLICATION_UID** 和 **LAST_APPLICATION_UID** ：

```
// android.os.Process

/**
 * Defines the start of a range of UIDs (and GIDs), going from this
 * number to {@link #LAST_APPLICATION_UID} that are reserved for assigning
 * to applications.
 */
public static final int FIRST_APPLICATION_UID = 10000;

/**
 * Last of application-specific UIDs starting at
 * {@link #FIRST_APPLICATION_UID}.
 */
public static final int LAST_APPLICATION_UID = 19999;
```

由于 UID 是应用安装时确认的，下面我们看一下 UID 的生成逻辑:

```
// com.android.server.pm.Settings

// Returns -1 if we could not find an available UserId to assign
private int newUserIdLPw(Object obj) {
    // Let's be stupidly inefficient for now...
    final int N = mUserIds.size();
    for (int i = mFirstAvailableUid; i < N; i++) {
        if (mUserIds.get(i) == null) {
            mUserIds.set(i, obj);
            return Process.FIRST_APPLICATION_UID + i;
        }
    }

    // None left?
    if (N > (Process.LAST_APPLICATION_UID-Process.FIRST_APPLICATION_UID)) {
        return -1;
    }

    mUserIds.add(obj);
    return Process.FIRST_APPLICATION_UID + N;
}
```

既然我们知道了 UID 的生成逻辑，那么如何查看一个 app 的 UID 呢？

### 查看方式

#### 1.通过 shell 查看

终端输入 adb shell 然后输入 ps ，可以看到如下图所示的进程列表（为了方便展示，省略了很多）：

```
USER     PID   PPID  VSIZE  RSS     WCHAN    PC        NAME
root      1     0     9240   668   c01b950c 0806daa0 S /init
root      2     0     0      0     c013aac6 00000000 S kthreadd
root      3     2     0      0     c0128fe4 00000000 S ksoftirqd/0
								.
								.
								.
root      63    1     11964  1380  c01d9a68 b76c1435 S /system/bin/lmkd
system    64    1     10120  720   c0401967 b7760196 S /system/bin/servicemanager
drm       72    1     28296  4456  ffffffff b7701196 S /system/bin/drmserver
media     73    1     106416 18424 ffffffff b75c0196 S /system/bin/mediaserver
install   74    1     10136  744   c04dc88e b7685eb6 S /system/bin/installd
keystore  75    1     14108  1980  c0401967 b7615196 S /system/bin/keystore
media_rw  77    1     16020  740   ffffffff b76bfeb6 S /system/bin/sdcard
wifi      544   1     14864  2924  c01b950c b7558bb5 S /system/bin/wpa_supplicant
radio     632   76    1535440 40916 ffffffff b7560435 S com.android.phone
dhcp      791   1     10048  972   c01b950c b770e0c0 S /system/bin/dhcpcd
system    994   76    1521900 28416 ffffffff b7560435 S com.android.tools
u0_a45    1016  76    1553492 54048 ffffffff b7560435 S com.tencent.mtt.x86:service
u0_a45    1118  76    1548416 53588 ffffffff b7560435 S com.tencent.mtt.x86
```

可以看到进程列表中有很多类型的 USER ，其中 u0_axxx 代表着应用程序的用户，且每个应用程序的 u0_axxx 都不一样，由于应用程序的 UID 是从 10000 开始的，**所以 u0_a 后面的数字加上 10000 所得的值就是 UID 了，例如最后一行 QQ 浏览器的 UID 就是 10045** 。

#### 2.通过 app 获得所有已安装应用的 UID

```
    PackageManager packageManager = context.getPackageManager();
    List<PackageInfo> packageInfoList = packageManager.getInstalledPackages(PackageManager.GET_PERMISSIONS);
    for (PackageInfo info : packageInfoList) {
        Log.d(TAG, "app:" + info.applicationInfo.loadLabel(packageManager).toString()
                + " uid:" + info.applicationInfo.uid
                + " className:" + info.applicationInfo.className
        );
    }
```

当我们在使用binder调用的时候， 被调用方可以使用binder获取调用方的uid，进而实现对调用方的权限鉴别。

JAVA:

```java
int pid = Binder.getCallingPid();
int uid = Binder.getCallingUid();
String callingApp = mContext.getPackageManager().getNameForUid(uid);
```

C/C++:

```c++
static int getprocname(pid_t pid, char *buf, size_t len) {
    char filename[20];
    FILE *f;

    sprintf(filename, "/proc/%d/cmdline", pid);
    f = fopen(filename, "r");
    if (!f) { *buf = '\0'; return 1; }
    if (!fgets(buf, len, f)) { *buf = '\0'; return 2; }
    fclose(f);
    return 0;
}
```



#### 3.通过应用 PID ，查看对应 app 的 UID

PID 是进程 ID，每一个不同的程序都能有一个 UID（share uid) ，但是一个应用里面可以有多个 PID. Android使用程序的包名根UID建立映射关系， 来实现基于DAC的访问控制。

```
终端中输入 adb shell ，然后输入 cat /proc/<pid>/status 
```

#### 4.通过 packages.xml ，查看需要查询的 app 的 UID

```
// 这个命令会输出很多信息，需要再次筛选
终端中输入 adb shell，然后输入cat /data/system/packages.xml
// 例如查看 QQ 浏览器的信息：
// cat /data/system/packages.xml|grep tenc
```

从中我们可以找到 QQ 浏览器 的信息：

```
 // userId 为 10045 ，所以 方法1 的猜测时对的
 <package name="com.tencent.mtt.x86" codePath="/data/app/com.tencent.mtt.x86-1" 
	nativeLibraryPath="/data/app/com.tencent.mtt.x86-1/lib" primaryCpuAbi="x86" 
	flags="1588804" ft="160077eb2c0" it="160077eb6c8" ut="160077eb6c8" version="611740" 
	userId="10045">
......
```

## 二、sharedUserId 的使用

```objectivec
Android给每个APK进程分配一个单独的空间,manifest中的userid就是对应一个分配的Linux用户ID，
并且为它创建一个沙箱，以防止影响其他应用程序（或者其他应用程序影响它）。
用户ID 在应用程序安装到设备中时被分配，并且在这个设备中保持它的永久性。
通常，不同的APK会具有不同的userId，因此运行时属于不同的进程中，而不同进程中的资源是不共享的，
在保障了程序运行的稳定。然后在有些时候，我们自己开发了多个APK并且需要他们之间互相共享资源，
那么就需要通过设置shareUserId来实现这一目的。
通过Shared User id,拥有同一个User id的多个APK可以配置成运行在同一个进程中.所以默认就是可以互相访问任意数据. 也可以配置成运行成不同的进程, 同时可以访问其他APK的数据目录下的数据库和文件.就像访问本程序的数据一样。
```

## share uid 配置

在需要共享资源的项目的每个AndroidMainfest.xml中添加shareuserId的标签。
android:sharedUserId="com.example"
id名自由设置，但必须保证每个项目都使用了相同的sharedUserId。一个mainfest只能有一个Shareuserid标签。

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.shareusertesta"
    android:versionCode="1"
    android:versionName="1.0" 
    android:sharedUserId="com.example">
```

## 不同APP的(/data/data/app包名/文件)的共享

每个安装的程序都会根据自己的包名在手机文件系统的/data/data/app包名/建立一个文件夹（需要su权限才能看见），用于存储程序相关的数据。
在代码中，我们通过context操作一些IO资源时，相关文件都在此路径的相应文件夹中。比如默认不设置外部路径的文件、DB等等。
正常情况下，不同的apk无法互相访问对应的app文件夹。但通过设置相同的shareUserId后，就可以互相访问了。

```java

//程序A：
public class MainActivityA extends Activity {
    TextView textView;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        textView = (TextView)findViewById(R.id.textView1);
        WriteSettings(this, "123");
    }

    public void WriteSettings(Context context, String data) {
        FileOutputStream fOut = null;
        OutputStreamWriter osw = null;
        try {
            //默认建立在data/data/xxx/file/ 
            fOut = this.openFileOutput("settings.dat", MODE_PRIVATE);            
            osw = new OutputStreamWriter(fOut);
            osw.write(data);
            osw.flush();
            Toast.makeText(context, "Settings saved", Toast.LENGTH_SHORT)
                    .show();
        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(context, "Settings not saved", Toast.LENGTH_SHORT)
                    .show();
        } finally {
            try {
                osw.close();
                fOut.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

//程序B：
public class MainActivityB extends Activity {
    TextView textView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        textView = (TextView) this.findViewById(R.id.textView1);
        
        try {
            //获取程序A的context
            Context ctx = this.createPackageContext(
                    "com.example.shareusertesta", Context.CONTEXT_IGNORE_SECURITY);
            String msg = ReadSettings(ctxDealFile);
            Toast.makeText(this, "DealFile2 Settings read" + msg,
                    Toast.LENGTH_SHORT).show();
            WriteSettings(ctx, "deal file2 write");
        } catch (NameNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public String ReadSettings(Context context) {
        FileInputStream fIn = null;
        InputStreamReader isr = null;
        char[] inputBuffer = new char[255];
        String data = null;
        try {
            //此处调用并没有区别，但context此时是从程序A里面获取的
            fIn = context.openFileInput("settings.dat");
            isr = new InputStreamReader(fIn);
            isr.read(inputBuffer);
            data = new String(inputBuffer);
            textView.setText(data);
            Toast.makeText(context, "Settings read", Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(context, "Settings not read", Toast.LENGTH_SHORT)
                    .show();
        } finally {
            try {
                isr.close();
                fIn.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return data;
    }

    public void WriteSettings(Context context, String data) {
        FileOutputStream fOut = null;
        OutputStreamWriter osw = null;
        try {
            fOut = context.openFileOutput("settings.dat", MODE_PRIVATE);
            //此处调用并没有区别，但context此时是从程序A里面获取的
            osw = new OutputStreamWriter(fOut);
            osw.write(data);
            osw.flush();
            Toast.makeText(context, "Settings saved", Toast.LENGTH_SHORT)
                    .show();

        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(context, "Settings not saved", Toast.LENGTH_SHORT)
                    .show();

        } finally {
            try {
                osw.close();
                fOut.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
```

如果A和B的mainfest中设置了相同的shareuserId，那么B的read函数就能正确读取A写入的内容。否则，B无法获取该文件IO。
通过这种方式，两个程序之间不需要代码层级的引用。之间的约束是，B需要知道A的file下面存在“settings.dat”这个文件以及B需要知道A的package的name。

## Resources和SharedPreferences的共享

通过shareuserId共享，我们可获取到程序A的context。因此，我们就可以通过context来获取程序A对应的各种资源。
比较常用的就是Raw资源的获取，如一些软件的apk皮肤包就是采用了这种技术，将主程序和皮肤资源包分在两个apk中。
获取Resources很简单，在程序A和B的mainfest中设置好相同的shareuserId后，通过createPackageContext获取context即可。
之后就和原来的方式一样，通过getResources函数获取各种资源，只是此时的context环境是目标APP的context环境。

```cpp
//在B中获取A的各种资源
Context friendContext = this.createPackageContext( "com.example.shareusertesta", Context.CONTEXT_IGNORE_SECURITY);
Resources res = friendContext.getResources();
int xId = res.getIdentifier("xxx", "drawable", "com.example.shareusertesta"); //R.string.xxx 
int yId = res.getIdentifier("yyy", "string", "com.example.shareusertesta"); //R.Drawable.yyy
res.getString(xId);
res.getDrawable(yId);
```

## 访问安全性(签名)
上文中通过测试，验证了同key下设置相同shareuserid后可共享资源，否则失败。
但还有两种情况尚未讨论。一是假设A和C用两个不同的签名，但设置相同的shareuserid，那么能否共享资源。
二是假设A用签名后的apk安装，C用usb直连调试（即debug key）,两者设置相同的shareuserid，那么能否共享资源。
经过测试，不论是USB调试还是新签名APK都安装不上。
再进一步测试后发现，能否安装取决于之前手机中是否已经存在对应该shareduserId的应用。
如有，则需要判断签名key是否相同，如不同则无法安装。也就是说，如果你删除a和b的应用先装c，此时c的安装正常，
而原来a和b的安装就失败了（a、b同key，c不同key，三者userId相同）。

