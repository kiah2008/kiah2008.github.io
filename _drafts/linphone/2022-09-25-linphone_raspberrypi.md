---
layout: post
title: 使用树莓派搭建一个视频监控系统
categories: [open-hardware]
description: 使用树莓派搭建一个视频监控系统
keywords: raspberry pi, 视频监控
dashang: true
topmost: false
tags: [RaspberryPi]
date:  2022-09-25 21:16:00 +0800
---

# Using the raspberry pi for video monitoring
<!-- more -->

The Raspberry PI is a good hardware for making a simple video monitoring device, such as watching at any time what's happening at home, if cats have enough to eat, chicken safe from fox attacks, or simply see at distance what's the weather like. The linphone console tools (**linphonec** and **linphone-daemon**) can be used to automatically accept a SIP call with video, so that it becomes possible from Linphone android or iOS app to call home at any time.

From a hardware standpoint, **a raspberry pi2 is a minimum for a decent image quality**. Indeed, video software encoding is a cpu consuming task that a pi 1 can hardly achieve as it doesn't have the NEON (multimedia) instruction set.

The PI's camera has excellent quality, however plugging a USB camera can be more interesting as it will provide sound recording thanks to its integrated microphone, which the raspberry doesn't have.

An ethernet connection is preferred, though wifi would work decently for video transmission as long as the raspberry is not too far from the wifi router.

Displaying the video received by the raspberry is out of this article's scope : we will just focus on the capture, sound and video, as well as the transmission via SIP to another SIP phone.

The following section explains how to setup the video monitoring on the raspberry pi by compilation on the raspberry to use linphone console tools directly

## Prequisites

We recommend to use Raspbian, as a base installation to run linphone.

The procedure was lastly tested on Raspbian 10.4 (August 2020).

## Compiling linphone on the rasberry pi

This procedure is for using the linphone console tools (linphonec, linphonecsh or linphone-daemon) on the raspberry pi.

**It assumes that the raspberry pi is installed with a Raspbian image**. 

- Install build dependencies from raspbian repositories

sudo apt install cmake automake autoconf libtool intltool yasm libasound2-dev libpulse-dev libv4l-dev nasm git libglew-dev

- Clone the linphone-sdk git repository on its latest stable branch (as of 2021/04/02 it is *release/4.5*). This repository comprises the liblinphone source code plus all required dependencies, with an overall build script that builds everything in order. The console tools (linphonec, linphone-daemon) are included with liblinphone.

git clone --branch release/4.5 https://gitlab.linphone.org/BC/public/linphone-sdk.git --recursive

- Setup compilation options. The line below sets options for a minimal liblinphone build with video features.

cd linphone-sdk
mkdir build-raspberry
cd build-raspberry
cmake .. -DLINPHONESDK_PLATFORM=Desktop -DCMAKE_C_FLAGS="-mfpu=neon" -DENABLE_OPENH264=ON  -DENABLE_LIME_X3DH=OFF -DENABLE_ADVANCED_IM=OFF -DENABLE_WEBRTC_AEC=OFF -DENABLE_UNIT_TESTS=OFF -DENABLE_MKV=OFF -DENABLE_FFMPEG=ON -DENABLE_CXX_WRAPPER=OFF -DENABLE_NON_FREE_CODECS=ON -DENABLE_VCARD=OFF -DENABLE_BV16=OFF -DENABLE_V4L=ON -DENABLE_CONSOLE_UI=ON -DENABLE_DAEMON=ON

- Now proceed with the compilation. This step may take around half an hour and will warm the raspberry !

make -j2

- Once completed, the output executables are in linphone-sdk/desktop/bin. The intermediate compilation products are all located in the WORK directory, that you can safely remove. Should any compilation problem happen, in order to restart the compilation from the beginning, removing the WORK directory is sufficient.

**BUG:** liblinphone won't initialize correctly if the data directory (for persistent storage) is not created. To workaround do:
mkdir -p ~/.local/share/linphone

**Now the software is ready to be used !**

### Configuration

First run *linphonec* once in order to configure your SIP account, so that you can place calls to your raspberry from another place (typically the linphone app on android or iOS!). We recommend to use our free sip.linphone.org service, on which accounts can be created [using this online form](https://www.linphone.org/freesip/home).

cd linphone-sdk/desktop/bin

./linphonec

[.....]

linphonec> proxy add

[…enter sip account configuration.
We recommend to set proxy address to <sip:sip.linphone.org;transport=tls>
Once done, you should be prompted for your sip account password, and then it should indicate that it is successfully registered. ]
quit

*You may also, within the linphonec command prompt, set the sound card to use for capturing sound. The raspberry-pi has no microphone, but if your plan is to plug a USB camera onto the raspberry pi, it probably has a built-in microphone. To tell linphonec to use the microphone from the usb camera, use the "soundcard list" and "soundcard use" commands to select the sound card index to use.*

Now open *~/.linphonerc* file with an editor (vim, nano...) in order to tweak a few things:

- In section [sound], set

echocancellation=0

Indeed, echo cancellation is not needed, our raspberry pi has no speaker. No need to spend cpu cycles on this.

- In section [video], set vga video size to achieve decent quality, compatible with the pi's processing capabilities:

 

size=vga

 

720p is also possible but the pi2 cpu is a bit too slow for this image format with VP8 codec. svga tends to work not so bad as well.

- Turn on ICE, in section [net] section:

stun_server=stun.linphone.org
firewall_policy=3

### Starting linphonec

You can then launch linphonec in background mode in with auto-answer mode. We assume the current directory is already in the OUTPUT/no-ui/bin directory.

export PATH=$PATH:`pwd`
linphonecsh init -a -C -c ~/.linphonerc -d 6 -l /tmp/log.txt

Notice the "-d 6 -l /tmp/log.txt" which are there to tell linphonec to output all debug messages into /tmp/log.txt. Looking into this file might be useful should any trouble arrive.

To stop it, do:

linphonecsh **exit**

### Automatic start at boot

In order to have linphonec automatically started when the raspberry boots: you can add this line to /etc/rc.local :

export PATH=/home/pi/linphone-sdk/build-raspberry/linphone-sdk/desktop/bin:$PATH
sudo -u pi linphonecsh init -a -C -c /home/pi/.linphonerc -d 6 -l /tmp/log.txt

The lines above assume that your linphone-desktop source tree is in /home/pi/linphone-desktop. Please adapt if it is not the case.

Just a final reboot and now you can place calls from your favourite linphone app (mobile or desktop) to your raspberry, by calling its sip address !

### Common hardware problems

If you are using the RaspberryPi Camera, you'll notice it won't show up as a /dev/video entry, thus it won't be available in linphone for use. To fix that, use the following:

- first enable the camera thanks to the raspi-config utility included in your raspberry.
- tell the raspberry to load the driver specific to the raspberry camera and do it automatically and next reboot:

sudo bash
modprobe bcm2835-v4l2
echo "bcm2835-v4l2" >> /etc/modules
**exit**

Sadly, the raspberry loosing the network connectivity is a frequent occurrence. Unfortunately, all that NetworkManager stuff included with Raspbian was designed for Linux workstation or servers, and is not robust to temporary network connectivity losses. They happen quite frequently because of various reasons:

- The internet box looses DSL connection and reboots
- The wifi signal is lost temporarily due to interferences
- The wifi driver has bugs and looses connection after some hours
- The house general power shuts down and comes back due to a thunderstorm, but the raspberry starts faster than the DSL box and will have no internet at boot time.

I recommend to plug the DSL box onto a programable power timer so that it is restarted every day : indeed it is not so rare that a DSL box hangs forever and needs a manual reboot.

In order to force the raspberry to check the network periodically and force a re-connection, I suggest these two scripts, that can be invoked periodically from cron daemon:

- The first one called "restart_wlan0_if_necessary.sh". It just tries a ping to linphone.org, and in absence of response, trigers a shutdown/restart of the wlan0 network interface.

*#!/bin/sh
*date
**if** test -z "`ping -w 5 linphone.org |grep time`" ; **then** 
     echo "broken connection, restarting wlan0 now"
    /sbin/ifdown wlan0
    sleep 1
    /sbin/ifup wlan0
     echo "wlan0 restarted."
**else**
     echo "Everything ok with network."
**fi**

- The second one, called "reboot_if_necessary.sh". Its goal is to reboot the raspberry if network is still not working, which is the case when the wifi driver or hardware has entered an irrecoverabilly corrupted state.

Sadly, the wifi devices and drivers are generally so bad in terms of robustness, that this kind of trick is necessary.

*#!/bin/sh
*date
**if** test -z "`ping -w 5 linphone.org |grep time`" ; **then**
     echo "broken connection, rebooting now"
    /sbin/reboot
**else**
     echo "Everything ok with network."
**fi**

And here's the crontab file:

5 12 * * *    /home/pi/reboot_if_necessary >> /home/pi/reboots.log 2>&1
0 *  * * *    /home/pi/restart_wlan0_if_necessary.sh >> /home/pi/restarts.log 2>&1

Use *sudo crontab -e* to write these lines aboves.

This will schedule restart_wlan0_if_necessary.sh every hour, and reboot_if_necessary every day at 12:05.

### Startup time issue

On some raspberry devices, the startup time can be very long (several minutes).
This can be caused by a lack of entropy for mbedTLS, as described [here](https://github.com/BelledonneCommunications/linphone-sdk/issues/119).
This can be worked around with the package **haveged** (installable from repositories) and a reboot.
Thanks to [llunohodl](https://github.com/llunohodl) for the tip !

 





> https://wiki.linphone.org/xwiki/wiki/public/view/Linphone/Linphone%20and%20Raspberry%20Pi/
>
> 