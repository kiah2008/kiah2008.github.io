---
layout: post
title: ESP32桌面机器人复刻
categories: [open-hardware]
tags: [esp]
description: some word here
keywords: ESP8266 , SPI 
dashang: true
topmost: false
mermaid: false
fullscreen: false
date:  2024-12-08 21:00:00 +0800
---

本文记录了复刻网络上的桌面机器人过程

<!-- more -->

* TOC
{:toc}
# ESP32 S3 SparkBot

ESP32 Bare Pin

![img](2024-12-08-esp32_desktop_robot.assets/esp32-pinout-chip-ESP-WROOM-32.png)



![img](2024-12-08-esp32_desktop_robot.assets/cam.65规格书.jpg)

采用低功耗双核32位CPU，可作应用处理器

主频高达240MHz，运算能力高达 600 DMIPS

内置 520 KB SRAM，外置8MB PSRAM

支持UART/SPI/I2C/PWM/ADC/DAC等接口

支持OV2640和OV7670摄像头，内置闪光灯

支持图片WiFI上传

支持TF卡

支持多种休眠模式。

内嵌Lwip和FreeRTOS

支持 STA/AP/STA+AP 工作模式

支持 Smart Config/AirKiss 一键配网

支持二次开发

![ESP32管脚定义](2024-12-08-esp32_desktop_robot.assets/269b17ad-f1e6-4295-a407-45300983906e.png)





![img](2024-12-08-esp32_desktop_robot.assets/c8c0921e9602442eb0ef2d5c7ed421d9.webp)





## LCD

factory_demo_v1\managed_components\espressif__esp_lvgl_port\test_apps

```
/* LCD pins */
#define EXAMPLE_LCD_GPIO_SCLK       (GPIO_NUM_7)
#define EXAMPLE_LCD_GPIO_MOSI       (GPIO_NUM_6)
#define EXAMPLE_LCD_GPIO_RST        (GPIO_NUM_48)
#define EXAMPLE_LCD_GPIO_DC         (GPIO_NUM_4)
#define EXAMPLE_LCD_GPIO_CS         (GPIO_NUM_5)
#define EXAMPLE_LCD_GPIO_BL         (GPIO_NUM_45)
```



https://forum.lvgl.io/t/st7735-128-160-interface-with-esp32-framework-espidf/6552/3

https://docs.lvgl.io/master/details/integration/driver/display/st7735.html







## Audio







# xiaozhi ESP



后端模型：Qwen-72B，SenseVoiceSmall 飞书文档：https://ccnphfhqs21z.feishu.cn/wiki/EH6wwrgvNiU7aykr7HgclP09nCh （附配件链接） 硬件开源：https://github.com/78/xiaozhi-esp32 Q群交流：946599635



https://github.com/78/xiaozhi-esp32



![img](2024-12-08-esp32_desktop_robot.assets/e746d3f18d502b63a58d595bd74cf1bb3546765074630961.png)

