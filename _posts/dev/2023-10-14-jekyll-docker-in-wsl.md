---
layout: post
title: WSL2使用Docker for Jekyll
categories: [dev]
tags: [docker, jekyll, wsl]
description: wsl使用jekyll镜像
keywords: docker
dashang: true
topmost: false
mermaid: true
date:  2023-10-14 14:11:00 +0800
---

本文记录wsl使用jekyll镜像的相关问题, docker的相关使用， 可以参考文章[docker快速入门](/2023/04/29/docker-guide/)。

<!-- more -->

* TOC
{:toc}

# 开始前
安装docker，不过在安装docker的时候遇到几个问题：
1. systemctl 无法启动docker
    ```
    sudo systemctl status docker
    System has not been booted with systemd as init system (PID 1). Can't operate.
    Failed to connect to bus: Host is down
    ```
    从log知道， wsl不是使用systemd启动，也即无法使用systemd管理服务。网上解释很多，不过还是退而求其次，使用service启动docker
    ```
    sudo service docker restart
    ```
2. 使用service启动docker后， 查看docker服务， 却又发现docker服务没有启动.
    ```
    sudo service docker status
    * Docker is not running
    ```

    查看docker.log, 发现是iptables无法使用。网上再度查询相关资料， 最后发现是命令行需要管理员身份启动， 并进入wsl即可。
    ```
    sudo service docker restart
    * Starting Docker: docker                                                                                       [ OK ]
    ```
    问题解决.

3. 解决了上面问题， 后面又发现"bridge"问题， 后面查到知乎一篇文章，索性升级wsl2到2.0版本。[WSL2 的 2.0 更新彻底解决网络问题](https://zhuanlan.zhihu.com/p/657110386)
   
   
    >| 需要windows 11才能支持
    
    ```
    failed to start daemon: Error initializing network controller: error creating default "bridge" network: device or resource busy
    ```
    更新系统版本到 23H2 （目前还没发正式版，可以考虑加入 Windows Insider 的 Release Preview 或者 Beta 预览版通道）。或者如果不想加入预览版计划的话你也可以等几周，23H2 也快发布正式版了。
    wsl --update --pre-release 把 WSL2 更新到 2.0.0 或以上版本
    在 %userprofile%\.wslconfig 中写入以下内容然后保存：
    ```
    [experimental]
    autoMemoryReclaim=gradual # 可以在 gradual 、dropcache 、disabled 之间选择
    networkingMode=mirrored
    dnsTunneling=true
    firewall=true
    autoProxy=true
    sparseVhd=true
    ```
    然后运行 wsl --manage 发行版名字 --set-sparse true 启用稀疏 VHD 允许 WSL2 的硬盘空间自动回收，比如 wsl --manage Ubuntu --set-sparse true

    然后你会发现，WSL2 和 Windows 主机的网络互通而且 IP 地址相同了，还支持 IPv6 了，并且从外部（比如局域网）可以同时访问 WSL2 和 Windows 的网络。这波升级彻底带回以前 WSL1 那时候的无缝网络体验了，并且 Windows 防火墙也能过滤 WSL 里的包了，再也不需要什么桥接网卡、端口转发之类的操作了。并且 WSL2 的内存占用和硬盘空间都可以自动回收了！

    另外，使用 VSCode - WSL 插件的，建议去 VSCode 设置里把自动端口转发关掉（Remote: Auto Forward Ports），避免冲突，因为 WSL2 更新之后新的网络已经是和你的 Windows 使用相同网络了，不再需要端口转发了。
4. 折腾了这么久， 最后推翻，从APP Store重新安装Ubuntu完事。Linux就是折腾。
    ```
    docker run --rm hello-world
    Unable to find image 'hello-world:latest' locally
    latest: Pulling from library/hello-world
    719385e32844: Pull complete
    Digest: sha256:88ec0acaa3ec199d3b7eaf73588f4518c25f9d34f58ce9a0df68429c5af48e8d
    Status: Downloaded newer image for hello-world:latest
    
    Hello from Docker!
    This message shows that your installation appears to be working correctly.
    ```
# 创建jekyll镜像
1. 拉去jekyll镜像

    `docker pull jekyll/jekyll`
2. 进入镜像查看配置信息

    ```
    docker run -it  jekyll/jekyll bash
    
    ```
3. 我们配置启动容器的bash， 并在容器内部手动启动jekyll服务

    设定上传pages目录~/kiah/invoai.top,挂载路径

    ```
    docker run -it --name jekyll -u jekyll -p 8080:4008 -v /home/kiah/invoai.top/:/srv/jekyll/:rw jekyll/jekyll bash
    //su root, 并执行bundle install， 安装gems

    //启动容器，并执行bash
    docker exec -it -u jekyll jekyll bash
    ```
4. 执行jekyll
    ```
    bundle exec jekyll build && JEKYLL_ENV=development bundle exec jekyll server -H 0.0.0.0 -P 4008 --incremental --watch
    ```

# 其它
在网上碰到一个主题模板， 感觉挺好的， 有需要的，可以学习借鉴下。
https://github.com/cotes2020/jekyll-theme-chirpy

# FAQ
1. Docker的容器中出现时区错误， 可以尝试挂在本地的时区信息

    `-v /etc/localtime:/etc/localtime:ro`





# Reference

- [Docker从入门到实践](https://yeasy.gitbook.io/docker_practice/)
- `Dockerfile` 官方文档：https://docs.docker.com/engine/reference/builder/
- `Dockerfile` 最佳实践文档：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- `Docker` 官方镜像 `Dockerfile`：https://github.com/docker-library/docs
