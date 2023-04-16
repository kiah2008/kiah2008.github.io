---
layout: post
title: 深度学习模型端侧部署
categories: [dl]
tags: [deploy]
description: some word here
keywords: keyword1, keyword2
dashang: true
topmost: false
mermaid: false
date:  2023-04-09 21:00:00 +0900
---

description

<!-- more -->

* TOC
{:toc}


# ADD Custom OP



# Model

# ONNX

## ONNX-[Open Neural Network Exchange ](https://onnx.ai/) 

Most `PPLNN` supported ops are based on onnx opset 11. If you are using onnx model with different opset version, you need to convert your onnx model opset version to 11.

`ONNX` officially provided an opset convert tool `version_converter`. Its tutorials is at: [Version Conversion](https://github.com/onnx/tutorials/blob/master/tutorials/VersionConversion.md). Please update to onnx v1.11(or above) and try `version_converter`:

```python
import onnx
from onnx import version_converter

model = onnx.load("<your_path_to_onnx_model>")
converted_model = version_converter.convert_version(onnx_model, 11)
onnx.save(converted_model, "<your_save_path>")
```

## PyTorch to ONNX

https://pytorch.org/docs/master/onnx.html



## Deploy ONNX

https://onnx.ai/supported-tools.html#deployModel





# Qualcomm Mobile Deploy

## [Snapdragon Neural Processing Engine SDK](https://developer.qualcomm.com/sites/default/files/docs/snpe/revision_history.html)

 



