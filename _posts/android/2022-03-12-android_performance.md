---
layout: post
title: Android性能调试方法
categories: [android]
tags: [performance]
description: 使用线程优先级, 调试android性能问题
keywords: performance, thread
dashang: true
topmost: false
mermaid: false
date:  2022-03-12 21:00:00 +0800
---

Android性能调试方法
<!-- more -->

# 持续性能
对于长时间运行的应用（例如，游戏、相机、RenderScript 和音频处理应用）来说，当设备达到极限温度且系统芯片 (SoC) 引擎受到限制时，性能便可能会出现急剧变化。当设备开始升温时，底层平台的功能会变得飘忽不定，这会限制应用开发者打造可长时间运行的高性能应用。

为解决此类限制，Android 7.0 引入了对持续性能的支持，让 OEM 能够为长时间运行的应用提供设备性能提示。应用开发者可根据这些提示来调整应用，以使设备能在长时间内保持可预测且稳定的性能水平。

架构
Android 应用可以请求平台进入持续性能模式，以使 Android 设备能在长时间内保持稳定的性能水平。
![SustainedPerformanceMode](https://source.android.com/devices/tech/images/power_sustained_perf.png)
```java
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
    getWindow().setSustainedPerformanceMode(true);
    }
    
// Obtain CPU cores which are reserved for the foreground app
  private int[] getExclusiveCores(){
      int exclusiveCores[] = {};

      mDeviceInfoText.append("Exclusive core ids: ");

      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
          mDeviceInfoText.append("Not supported. Only available on API " +
                  Build.VERSION_CODES.N + "+");
      } else {
          exclusiveCores = android.os.Process.getExclusiveCores();
          for (int i : exclusiveCores){
              mDeviceInfoText.append(i + " ");
          }
      }
      mDeviceInfoText.append("\n");

      return exclusiveCores;
  }
```
## 设置cpu 亲密性
```c
void setThreadAffinity() {

  pid_t current_thread_id = gettid();
  cpu_set_t cpu_set;
  CPU_ZERO(&cpu_set);

  // If the callback cpu ids aren't specified then bind to the current cpu
  if (callback_cpu_ids_.empty()) {
    int current_cpu_id = sched_getcpu();
    LOGV("Current CPU ID is %d", current_cpu_id);
    CPU_SET(current_cpu_id, &cpu_set);
  } else {

    for (size_t i = 0; i < callback_cpu_ids_.size(); i++) {
      int cpu_id = callback_cpu_ids_.at(i);
      LOGV("CPU ID %d added to cores set", cpu_id);
      CPU_SET(cpu_id, &cpu_set);
    }
  }

  int result = sched_setaffinity(current_thread_id, sizeof(cpu_set_t), &cpu_set);
  if (result == 0) {
    LOGV("Thread affinity set");
  } else {
    LOGW("Error setting thread affinity. Error no: %d", result);
  }

  is_thread_affinity_set_ = true;
}
```

## 设置线程优先级
java
```java
 android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO);
```
c
```c
#if defined(__ANDROID__)
int androidSetThreadPriority(pid_t tid, int pri)
{
    int rc = 0;
    int lasterr = 0;

    if (pri >= ANDROID_PRIORITY_BACKGROUND) {
        rc = set_sched_policy(tid, SP_BACKGROUND);
    } else if (getpriority(PRIO_PROCESS, tid) >= ANDROID_PRIORITY_BACKGROUND) {
        rc = set_sched_policy(tid, SP_FOREGROUND);
    }

    if (rc) {
        lasterr = errno;
    }

    if (setpriority(PRIO_PROCESS, tid, pri) < 0) {
        rc = INVALID_OPERATION;
    } else {
        errno = lasterr;
    }

    return rc;
}

int androidGetThreadPriority(pid_t tid) {
    return getpriority(PRIO_PROCESS, tid);
}

#endif

```
# android 功耗相关
避免android 挂起
```
#加锁
adb shell "echo temporary > /sys/power/wake_lock"
#除去锁
adb shell "echo temporary > /sys/power/wake_unlock"

```

# 控制 CPU 速率

活跃的 CPU 可以处于联机或脱机状态，改变其时钟速率和相关电压（也可能影响内存总线速率和其他系统内核的电源状态），并在内核空闲循环时进入较低功耗的空闲状态。在测量不同 CPU 的功耗状态来验证电源配置文件中的值时，请避免在测量其他参数时导致功耗发生变化。电源配置文件假设所有 CPU 的可用速率和功率特性都相同。

在测量 CPU 功率或者在保持恒定 CPU 功率以进行其他测量时，请保持在线 CPU 的数量恒定（例如一个 CPU 在线，其余处于离线状态/以热插拔方式拔出）。留下一个 CPU，并将其余的所有 CPU 处于调度空闲状态，这样可能有助于获得令人信服的结果。使用 adb shell stop 停止 Android 框架可以减少系统调度活动。

您必须在电源配置文件的 cpu.speeds 条目中指定设备的可用 CPU 速率。如需获取可用 CPU 速率列表，请运行以下命令：


>| adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state
这些速率与 cpu.active 值中对应的功率测量值相匹配。

如果某个平台的在线内核数量对功耗有很大的影响，您可能需要修改该平台的 cpufreq 驱动程序或调节器。大多数平台支持使用用户空间 cpufreq 调节器控制 CPU 速率以及使用 sysfs 接口来设置速率。例如，如需在只有 1 个 CPU 的系统上或者所有 CPU 共享一个公共 cpufreq 策略的系统上将速率设置为 200MHz，请使用系统控制台或 adb shell 运行以下命令：

```
echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
```

>| 注意：确切的命令可能因平台实施的 cpufreq 不同而有所差异。

这些命令可确保新的速率不超出允许的范围，并设置新的速率，然后输出 CPU 实际运行的速率（用于验证）。如果执行前的当前最小速率高于 200000，则可能需要交换前两行的顺序，或者再次执行第一行，以在设置最大速率之前降低最小速率。

要测量 CPU 在不同速率下运行时所消耗的电流，请使用以下命令通过系统控制台将 CPU 置于 CPU 限制循环中：

```
# while true; do true; done
```
请在执行循环时进行测量。

如果某些设备因测量温度值过高（即持续高速运行 CPU 一段时间后）需执行温控调频，则可能会限制最大 CPU 速率。
您可以通过两种方式观察是否存在此类限制：
一是在测量时使用系统控制台输出，
二是在测量后检查内核日志。

对于 cpu.awake 值，您可以测量系统未挂起且不执行任务时的功耗。
CPU 应处于低功耗调度程序空闲循环中（可能是正在执行 ARM 等待事件指令）或特定的 SoC 低功耗状态（适用于空闲状态下使用的快速退出延迟）。

对于 cpu.active 值，您可以测量系统未处于挂起模式且不执行任务时的功率。
一个 CPU（通常是主 CPU）应运行任务，而所有其他 CPU 都应处于空闲状态。



# referrence
[Android的离奇陷阱 — 设置线程优先级导致的微信卡顿惨案](https://posts.careerengine.us/p/60d7f9a9bc83141c093e4dfd?from=mostSharedPostSidePanel)
