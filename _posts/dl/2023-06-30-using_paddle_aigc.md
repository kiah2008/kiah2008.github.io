---
layout: post
title: using paddle for aigc and llm
categories: [dl]
tags: [aigc, llm]
description: using paddle for aigc and llm
keywords: paddlepaddle, aigc, llm, dl
dashang: true
topmost: false
mermaid: false
date:  2023-06-30 00:36:00 +0900
---

using paddlepaddle for aigc and llm

<!-- more -->

* TOC
{:toc}
# docker setup

we may install several dl frameworks , such as pytorch, caffe, paddlepaddle and so on.

suggest to using docker instead of installing in local environment.

``` 
~/worktmp/paddle$ docker image list
REPOSITORY    TAG                       IMAGE ID       CREATED        SIZE
nvidia/cuda   12.1.0-base-ubuntu20.04   110920755580   3 months ago   241MB
```

create docker volume

``` 
docker volume create my-dl
docker volume ls
kiah@think:~/worktmp/paddle$ docker volume ls
DRIVER    VOLUME NAME
local     my-dl
```

create docker container

```
docker run -it --gpus all --name paddle_env -p 8810:80 -p 8820:8080 -v /home/kiah/worktmp/paddle:/var/paddle:rw --mount source=my-vol,target=/usr/share/my_dl  nvidia/cuda:12.1.0-base-ubuntu20.04
```

ps.

export two ports from host which mapping to container's ports.

```
docker port paddle_env 
80/tcp -> 0.0.0.0:8810 ==> jupyter
80/tcp -> [::]:8810
8080/tcp -> 0.0.0.0:8820 ==> gradio ??
8080/tcp -> [::]:8820
```

in container, adduser

```
adduser kian
```

run container

```
docker exec -it -u kian -w /home/kian/ 2a4d /bin/bash
```

using alias to start the docker in short way.

```
alias usepaddle='docker start 2a4d && docker exec -it -u kian -w /home/kian/ 2a4d /bin/bash'
```

add soft link of paddle dir from host to workdir.

```
ln -s /var/paddle/ ~/
ls -l
lrwxrwxrwx 1 kian kian 12 Jun 30 04:50 paddle -> /var/paddle/
```



# install paddle in docker

## install pip 

suggest to mount local bin path to container, otherwise need to setup apt and install by yourself.

change apt source to aliyun.

install wget

install python3.8

install pip

change pip config to accelerate the network speed.

```
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
```

validate the pip config

``` 
pip config list
global.index-url='https://pypi.tuna.tsinghua.edu.cn/simple'
install.trusted-host='https://pypi.tuna.tsinghua.edu.cn
```



## install paddle-gpu

```
pip install paddlepaddle-gpu==0.0.0.post120 -f https://www.paddlepaddle.org.cn/whl/linux/gpu/develop.html --user
```

install cuda version 12.0. check the version, using `nvidia-smi`

```
vidia-smi
Thu Jun 29 16:31:30 2023       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 530.30.02              Driver Version: 530.30.02    CUDA Version: 12.1     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                  Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf            Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 2070 S...    On | 00000000:01:00.0 Off |                  N/A |
|  0%   49C    P8               26W / 215W|    497MiB /  8192MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
+---------------------------------------------------------------------------------------+

```

check the paddle module

```
python -c "import paddle"
```



## install gcc 12

```
python -c "import paddle"
Error: Can not import paddle core while this file exists: /home/kian/.local/lib/python3.8/site-packages/paddle/fluid/libpaddle.so
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/kian/.local/lib/python3.8/site-packages/paddle/__init__.py", line 31, in <module>
    from .framework import monkey_patch_variable
  File "/home/kian/.local/lib/python3.8/site-packages/paddle/framework/__init__.py", line 17, in <module>
    from . import random  # noqa: F401
  File "/home/kian/.local/lib/python3.8/site-packages/paddle/framework/random.py", line 17, in <module>
    from paddle import fluid
  File "/home/kian/.local/lib/python3.8/site-packages/paddle/fluid/__init__.py", line 36, in <module>
    from . import framework
  File "/home/kian/.local/lib/python3.8/site-packages/paddle/fluid/framework.py", line 35, in <module>
    from . import core
  File "/home/kian/.local/lib/python3.8/site-packages/paddle/fluid/core.py", line 360, in <module>
    raise e
  File "/home/kian/.local/lib/python3.8/site-packages/paddle/fluid/core.py", line 269, in <module>
    from . import libpaddle
ImportError: /lib/x86_64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.30' not found (required by /home/kian/.local/lib/python3.8/site-packages/paddle/fluid/libpaddle.so)
```

need to update libstedc++.so.

since libstdc++ is one part of gcc's libs, do install latest gcc(version > 12.0)

check version with below

```
GCC 11.1.0: libstdc++.so.6.0.29
GCC 12.1.0: libstdc++.so.6.0.30
GCC 13.1.0: libstdc++.so.6.0.31
GCC 13.2.0: libstdc++.so.6.0.32
GCC <next>: libstdc++.so.6.0.33
```

using wget to download the gcc tar

```
wget https://mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-12.3.0/gcc-12.3.0.tar.gz
```

cost a lot of time, using vpn....

using gcc_path/contrib/download_prerequisites to download extra modules.

cost more time, wtf.

```
mkdir build
cd build
../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib
```

after checking, do compile using make.

install so

```
# 安装
make install 
# 安装完后，编译出来的libstdc++.so.6.0.30 安装到 /usr/local/lib64/下面
# 可以 find / -name libstdc++.so*查找

# 把安装后的libstdc++.so.6.0.30拷贝到/usr/lib64
cp /usr/local/lib64/libstdc++.so.6.0.30 /usr/lib64/

# 创建软连接
ll libstdc++*
lrwxrwxrwx 1 root root       19 Mar 10 18:43 libstdc++.so.6 -> libstdc++.so.6.0.29
-rwxr-xr-x 1 root root   995840 Sep 30  2020 libstdc++.so.6.0.29
-rwxr-xr-x 1 root root 11521888 Apr 14 14:28 libstdc++.so.6.0.30
[root@xxxx lib64]# rm libstdc++.so.6
rm: remove symbolic link 'libstdc++.so.6'? y
[root@xxx lib64]# ln -sf libstdc++.so.6.0.30libstdc++.so.6
[root@xxx lib64]# ll libstdc++.so.6*
lrwxrwxrwx 1 root root       19 Apr 14 16:31 libstdc++.so.6 -> libstdc++.so.6.0.30
-rwxr-xr-x 1 root root   995840 Sep 30  2020 libstdc++.so.6.0.29
-rwxr-xr-x 1 root root 11521888 Apr 14 14:28 libstdc++.so.6.0.30
```



# run paddlepaddle samples





# run jupyter in docker

## install jupyter notebook

```
pip install jupyterlab
# show content using jupyter plugin
jupyter labextension install jupyterlab-toc
```



## start jupyter in container

help with jupyter lab

```
--config=<Unicode>
    Full path of a config file.
    Default: ''
    Equivalent to: [--JupyterApp.config_file]
--ip=<Unicode>
    The IP address the Jupyter server will listen on.
    Default: 'localhost'
    Equivalent to: [--ServerApp.ip]
--port=<Int>
    The port the server will listen on (env: JUPYTER_PORT).
    Default: 0
    Equivalent to: [--ServerApp.port]
--port-retries=<Int>
    The number of additional ports to try if the specified port is not available
    (env: JUPYTER_PORT_RETRIES).
    Default: 50
    Equivalent to: [--ServerApp.port_retries]
--notebook-dir=<Unicode>
    The directory to use for notebooks and kernels.
    Default: ''
    Equivalent to: [--ServerApp.root_dir]
--browser=<Unicode>
    Specify what command to use to invoke a web
                          browser when starting the server. If not specified, the
                          default browser will be determined by the `webbrowser`
                          standard library module, which allows setting of the
                          BROWSER environment variable to override it.
    Default: ''
    Equivalent to: [--ServerApp.browser]
--app-dir=<Unicode>
    The app directory to launch JupyterLab from.
    Default: None
    Equivalent to: [--LabApp.app_dir]
```

start jupyter

```
jupyter lab --port 80 --no-browser --ip 0.0.0.0
```

## generate config for jupyter lab

```
jupyter lab --port 80 --no-browser --ip 0.0.0.0 --generate-config
Writing default config to: /home/kian/.jupyter/jupyter_lab_config.py
```

override the field in jupyter_lab_config.

pay attention to the below fields:















