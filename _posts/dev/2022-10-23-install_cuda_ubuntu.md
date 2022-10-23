---
layout: post
title: 在Ubuntu系统安装CUDA
categories: [dev]
tags: [cuda,ubuntu]
description: 在Ubuntu系统安装CUDA
keywords: cuda, ubuntu
dashang: true
topmost: false
mermaid: false
date:  2022-10-23 14:00:00 +0900
---

安裝Nvidia CUDA

<!-- more -->

* TOC
{:toc}
## Install Nvidia Driver Using GUI

Ubuntu comes with open-source Nouveau drivers for Nvidia GPUs out of the box. The Nouveau driver does not harness the GPU’s full power and sometimes performs worse or even causes system instability. Nvidia proprietary drivers are much more reliable and stable.

The first way to install Nvidia drivers is by using the GUI **Software & Updates** app.

### Step 1: Open Software and Updates From the App Menu

\1. Open the *Applications* menu and type “software and updates.”

\2. Select the **Software and Updates** app.

### Step 2: Click the Additional Drivers Tab

Wait for the app to download a list of additional drivers available for your GPU.

![Install proprietary Nvidia drivers via a GUI app.](https://phoenixnap.com/kb/wp-content/uploads/2021/04/additional-gpu-drivers.png)

The driver installed on your machine is selected by default. It is usually an open-source Nouveau display driver.

### Step 3: Choose a Driver

\1. From the list, select the latest Nvidia driver labeled ***proprietary**, **tested***. This is the latest stable driver published by Nvidia for your GPU.

![Choose a proprietary Nvidia driver to install on Ubuntu 20.04](https://phoenixnap.com/kb/wp-content/uploads/2021/04/choose-gpu-driver.png)

\2. Click **Apply Changes**.

\3. Enter your password and wait for the installation to finish.

### Step 4: Restart

Restart the machine for the changes to take effect.

### Step 5: Check nvidia info

```
$ nvidia-smi 
Sun Oct 23 11:46:28 2022       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 515.76       Driver Version: 515.76       CUDA Version: 11.7     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0  On |                  N/A |
| 33%   28C    P8     1W /  38W |    372MiB /  1024MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A      1034      G   /usr/lib/xorg/Xorg                101MiB |
|    0   N/A  N/A      1297      G   /usr/bin/gnome-shell              101MiB |
|    0   N/A  N/A      2688      G   ...777036185490121345,131072      164MiB |
+-----------------------------------------------------------------------------+
```

run "lsmod|grep -i nvidia"

```
lsmod |grep -i nvidia
nvidia_uvm           1323008  0
nvidia_drm             73728  7
nvidia_modeset       1146880  8 nvidia_drm
nvidia              40841216  334 nvidia_uvm,nvidia_modeset
drm_kms_helper        311296  1 nvidia_drm
drm                   622592  11 drm_kms_helper,nvidia,nvidia_drm
```



### Step 6: install cuda tookit

`sudo apt install nvidia-cuda-toolkit`

check if works

`nvcc --version`

### Step 7: Update kernel headers

`sudo apt install linux-headers-$(uname -r) -y`

### Step 8: Installing **the Latest Version of CUDA from the Official NVIDIA Package Repository**

`sudo apt install linux-headers-$(uname -r) -y`

Now, download the CUDA repository Pin file from the official website of NVIDIA with the following command:

`sudo wget -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin`

add gpg key

`sudo apt-key adv --fetch-keys https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub`

### Step 9: install CUDA

`sudo apt install cuda`

```
A new initrd image has also been created. To revert, please regenerate your
initrd by running the following command after deleting the modprobe.d file:
`/usr/sbin/initramfs -u`

*****************************************************************************
*** Reboot your computer and verify that the NVIDIA graphics driver can   ***
*** be loaded.                                                            ***
*****************************************************************************

INFO:Enable nvidia
DEBUG:Parsing /usr/share/ubuntu-drivers-common/quirks/lenovo_thinkpad
DEBUG:Parsing /usr/share/ubuntu-drivers-common/quirks/put_your_quirks_here
DEBUG:Parsing /usr/share/ubuntu-drivers-common/quirks/dell_latitude
Loading new nvidia-520.61.05 DKMS files...
Building for 5.15.0-52-generic
Building for architecture x86_64
Building initial module for 5.15.0-52-generic
.....................
```



### using nvcc to compile

```c
#include <stdio.h>
#include <unistd.h>

__global__ void say_hello() {
    printf("Hello world from the GPU!\n");
}

int main() {

    printf("Hello world from the CPU!\n");
    say_hello<<<1,1>>>();
    cudaDeviceSynchronize();
    sleep(2);
    printf("Bye!\n");

    fflush(stdout);    
    return 0;
}
```

`nvcc say_hello.cu -o hello`

```
├── hello
└── say_hello.cu

0 directories, 2 files
```



runing hello

```
./hello 
Hello world from the CPU!
Bye!
```









## Install Nvidia Driver via Command Line

The second way to install Nvidia drivers is by using the **terminal**.

### Step 1: Search for Nvidia Drivers

\1. Open the terminal by pressing **Ctrl+Alt+T** or search for “terminal” in the *Applications* menu.

\2. Run the following command:

```
apt search nvidia-driver
```

![Search for available Nvidia drivers using the terminal in Ubuntu 20.04.](https://phoenixnap.com/kb/wp-content/uploads/2021/04/search-nvidia-drivers.png)

The output shows a **list of available drivers** for your GPU.

### Step 2: Update the System Package Repository

Before installing the driver, make sure to update the package repository. Run the following commands:

```
sudo apt update``sudo apt upgrade
```

### Step 3: Install the Right Driver for Your GPU

\1. Choose a driver to install from the list of available GPU drivers. The best fit is the latest tested proprietary version.

\2. The syntax for installing the driver is:

```
sudo apt install [driver_name]
```

![Install Nvidia drivers by using the terminal in Ubuntu 20.04](https://phoenixnap.com/kb/wp-content/uploads/2021/04/install-nvidia-driver.png)

For this tutorial, we installed nvidia-driver-340, the latest tested proprietary driver for this GPU.

### Step 4: Reboot

Reboot your machine with the following command:

```
sudo reboot
```

## Install Nvidia Beta Drivers via PPA Repository

The PPA repository allows developers to distribute software that is not available in the official Ubuntu repositories. This means that you can install the latest **beta drivers**, however, at the risk of an **unstable system**.

To install the latest Nvidia drivers via the PPA repository, follow these steps:

### Step 1: Add PPA GPU Drivers Repository to the System

\1. Add the graphics drivers repository to the system with the following command:

```
sudo add-apt-repository ppa:graphics-drivers/ppa
```

![Add the GPU PPA repository to Ubuntu 20.04.](https://phoenixnap.com/kb/wp-content/uploads/2021/04/add-ppa-gpu-repository.png)

\2. Enter your password and hit **Enter** when asked if you want to add the repository.

### Step 2: Identify GPU Model and Available Drivers

To verify which GPU model you are using and to see a list of available drivers, run the following command:

```
ubuntu-drivers devices
```

![Identify GPU and available Nvidia drivers in Ubuntu 20.04.](https://phoenixnap.com/kb/wp-content/uploads/2021/04/identify-gpu-and-drivers.png)

The output shows your GPU model as well as any available drivers for that specific GPU.

### Step 3: Install Nvidia Driver

\1. To install a specific driver, use the following syntax:

```
sudo apt install [driver_name]
```

![Install Nvidia drivers by using the terminal in Ubuntu 20.04](https://phoenixnap.com/kb/wp-content/uploads/2021/04/install-nvidia-driver.png)

For example, we installed the nvidia-340 driver version.

\2. Alternatively, install the **recommended driver** **automatically** by running:

```
sudo ubuntu-drivers autoinstall
```

![Install the recommended Nvidia driver automatically in Ubuntu 20.04.](https://phoenixnap.com/kb/wp-content/uploads/2021/04/autoinstall-nvidia-driver.png)

In this example, no changes were made as the recommended driver is already installed.

### Step 4: Restart the System

Reboot the machine for the changes to take effect.

## How to Uninstall Nvidia Driver

If you want to uninstall the proprietary Nvidia driver, the best option is to **`remove --purge`** the driver.

### Step 1: See Installed Packages

To check which Nvidia packages are installed on the system, run the following command:

```
dpkg -l | grep -i nvidia
```

![See installed Nvidia packages on Ubuntu 20.04.](https://phoenixnap.com/kb/wp-content/uploads/2021/04/see-installed-nvidia-packages.png)

The output returns a list of all Nvidia packages on the system.
