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

using `gcc_path/contrib/download_prerequisites `to download extra modules.

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

using ldconfig to add the dir to lib search path.

```
echo /usr/local/lib64/ >> /etc/ld.so.conf.d/stdc++_6.conf
ldconfig
ldconfig -v |grep c++
	libstdc++.so.6 -> libstdc++.so.6.0.30
	libstdc++.so.6 -> libstdc++.so.6.0.28
	
# test python paddle, and no error raise.
python -c "import paddle"
```



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
jupyter lab --port 80 --ip 0.0.0.0
```

## generate config for jupyter lab

```
jupyter lab --port 80 --no-browser --ip 0.0.0.0 --generate-config
Writing default config to: /home/kian/.jupyter/jupyter_lab_config.py
```

override the field in jupyter_lab_config.

pay attention to the below fields:

```
< c.ExtensionApp.open_browser = False
---
> # c.ExtensionApp.open_browser = False
321c321
< c.LabServerApp.open_browser = False
---
> # c.LabServerApp.open_browser = False
397c397
< c.LabApp.open_browser = False
---
> # c.LabApp.open_browser = False
650c650
< c.ServerApp.allow_credentials = False
---
> # c.ServerApp.allow_credentials = False
667c667
< c.ServerApp.allow_origin = '*'
---
> # c.ServerApp.allow_origin = ''
698c698
< c.ServerApp.allow_remote_access = True
---
> # c.ServerApp.allow_remote_access = False
857c857
< c.ServerApp.ip = '0.0.0.0'
---
> # c.ServerApp.ip = 'localhost'
906c906
< #c.ServerApp.local_hostnames = ['localhost']
---
> # c.ServerApp.local_hostnames = ['localhost']
965c965
< # c.ServerApp.password = '' add your passwd if neccessary.
---
> # c.ServerApp.password = ''
969c969
< c.ServerApp.password_required = False
---
> # c.ServerApp.password_required = False
973c973
< c.ServerApp.port = 80
---
> # c.ServerApp.port = 0
1003c1003
< c.ServerApp.root_dir = '/home/kian'
---
> # c.ServerApp.root_dir = ''
1059c1059
```

# run paddlepaddle samples

```
import paddle
print(paddle.version.cuda())
#12.0
```

```
from ppdiffusers import StableDiffusionPipeline

# 加载模型
model_path = "Neolle_Face_Generator"
pipe = StableDiffusionPipeline.from_pretrained(model_path)

prompt = "Noelle with cat ears, green hair"

# 生成
image = pipe(prompt, num_inference_steps=50,guidance_scale=10).images[0]
# 保存
image.save("test.jpg")
# 展示图片
image.show()
```



WTF!

```
Out of memory error on GPU 0. Cannot allocate 1.000000GB memory on GPU 0, 7.084717GB memory has been allocated and available memory is only 716.750000MB.
```


# run chatglm2

```
from transformers import AutoModel, AutoTokenizer
import gradio as gr
import mdtex2html

# add proxy in environments, such as http_proxy, all_proxy

tokenizer = AutoTokenizer.from_pretrained("THUDM/chatglm2-6b", trust_remote_code=True)

model = AutoModel.from_pretrained("THUDM/chatglm2-6b", trust_remote_code=True).quantize(4).cuda()
model = model.eval()
"""Override Chatbot.postprocess"""


def postprocess(self, y):
    if y is None:
        return []
    for i, (message, response) in enumerate(y):
        y[i] = (
            None if message is None else mdtex2html.convert((message)),
            None if response is None else mdtex2html.convert(response),
        )
    return y


gr.Chatbot.postprocess = postprocess


def parse_text(text):
    """copy from https://github.com/GaiZhenbiao/ChuanhuChatGPT/"""
    lines = text.split("\n")
    lines = [line for line in lines if line != ""]
    count = 0
    for i, line in enumerate(lines):
        if "```" in line:
            count += 1
            items = line.split('`')
            if count % 2 == 1:
                lines[i] = f'<pre><code class="language-{items[-1]}">'
            else:
                lines[i] = f'<br></code></pre>'
        else:
            if i > 0:
                if count % 2 == 1:
                    line = line.replace("`", "\`")
                    line = line.replace("<", "&lt;")
                    line = line.replace(">", "&gt;")
                    line = line.replace(" ", "&nbsp;")
                    line = line.replace("*", "&ast;")
                    line = line.replace("_", "&lowbar;")
                    line = line.replace("-", "&#45;")
                    line = line.replace(".", "&#46;")
                    line = line.replace("!", "&#33;")
                    line = line.replace("(", "&#40;")
                    line = line.replace(")", "&#41;")
                    line = line.replace("$", "&#36;")
                lines[i] = "<br>"+line
    text = "".join(lines)
    return text


def predict(input, chatbot, max_length, top_p, temperature, history, past_key_values):
    chatbot.append((parse_text(input), ""))
    for response, history, past_key_values in model.stream_chat(tokenizer, input, history, past_key_values=past_key_values,
                                                                return_past_key_values=True,
                                                                max_length=max_length, top_p=top_p,
                                                                temperature=temperature):
        chatbot[-1] = (parse_text(input), parse_text(response))

        yield chatbot, history, past_key_values


def reset_user_input():
    return gr.update(value='')


def reset_state():
    return [], [], None


with gr.Blocks() as demo:
    gr.HTML("""<h1 align="center">ChatGLM2-6B</h1>""")

    chatbot = gr.Chatbot()
    with gr.Row():
        with gr.Column(scale=4):
            with gr.Column(scale=12):
                user_input = gr.Textbox(show_label=False, placeholder="Input...", lines=10).style(
                    container=False)
            with gr.Column(min_width=32, scale=1):
                submitBtn = gr.Button("Submit", variant="primary")
        with gr.Column(scale=1):
            emptyBtn = gr.Button("Clear History")
            max_length = gr.Slider(0, 32768, value=8192, step=1.0, label="Maximum length", interactive=True)
            top_p = gr.Slider(0, 1, value=0.8, step=0.01, label="Top P", interactive=True)
            temperature = gr.Slider(0, 1, value=0.95, step=0.01, label="Temperature", interactive=True)

    history = gr.State([])
    past_key_values = gr.State(None)

    submitBtn.click(predict, [user_input, chatbot, max_length, top_p, temperature, history, past_key_values],
                    [chatbot, history, past_key_values], show_progress=True)
    submitBtn.click(reset_user_input, [], [user_input])

    emptyBtn.click(reset_state, outputs=[chatbot, history, past_key_values], show_progress=True)

demo.queue().launch(share=False, inbrowser=True)
```





# setup gpu environment

## install cuda-toolkit

https://developer.nvidia.com/cuda-toolkit-archive

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda-repo-ubuntu2004-12-2-local_12.2.0-535.54.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-12-2-local_12.2.0-535.54.03-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2004-12-2-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda
```

## cudnn

https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html

[download cudnn](https://developer.nvidia.com/cudnn)

```
dpkg -i cudnn-local-repo-${distro}-8.9.2.26_amd64.deb
cp /var/cudnn-local-repo-ubuntu2004-8.9.2.26/cudnn-local-9AE71A4A-keyring.gpg /usr/share/keyrings/
apt-get update
apt install libcudnn8
apt install libcudnn8-dev
##################
Get:1 https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64  libcudnn8 8.9.2.26-1+cuda12.1 [464 MB]
Fetched 464 MB in 10s (48.5 MB/s)                                                                                                                                                                         
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package libcudnn8.
(Reading database ... 13836 files and directories currently installed.)
Preparing to unpack .../libcudnn8_8.9.2.26-1+cuda12.1_amd64.deb ...
```



## cudnn share library not found

```
sudo ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so.8 /usr/local/cuda/lib64/libcudnn.so
```

restart jupyter



## 









