---
layout: post
title: Harris corner detector
categories: [cv]
tags: [corner_detector]
description: some word here
keywords: keyword1, keyword2
dashang: true
topmost: false
mermaid: false
date:  2022-10-01 21:00:00 +0900
---

description

<!-- more -->

* TOC
{:toc}
## Theory

### What is a feature?

- In computer vision, usually we need to find matching points between different frames of an environment. Why? If we know how two images relate to each other, we can use *both* images to extract information of them.
- When we say **matching points** we are referring, in a general sense, to *characteristics* in the scene that we can recognize easily. We call these characteristics **features**.
- So, what characteristics should a feature have?
  - It must be *uniquely recognizable*

### Types of Image Features

To mention a few:

- Edges
- **Corners** (also known as interest points)
- Blobs (also known as regions of interest )

In this tutorial we will study the *corner* features, specifically.

### Why is a corner so special?

- Because, since it is the intersection of two edges, it represents a point in which the directions of these two edges *change*. Hence, the gradient of the image (in both directions) have a high variation, which can be used to detect it.

### How does it work?

- Let's look for corners. Since corners represents a variation in the gradient in the image, we will look for this "variation".

- Consider a grayscale image I. We are going to sweep a window w(x,y) (with displacements u in the x direction and v in the y direction) I and will calculate the variation of intensity.

  ```mathematica
  E(u,v)=∑x,yw(x,y)[I(x+u,y+v)−I(x,y)]2
```
  
  where:

  - w(x,y) is the window at position (x,y)
- I(x,y) is the intensity at (x,y)
  - I(x+u,y+v) is the intensity at the moved window (x+u,y+v)

- Since we are looking for windows with corners, we are looking for windows with a large variation in intensity. Hence, we have to maximize the equation above, specifically the term:

  ```mathematica
  ∑x,y[I(x+u,y+v)−I(x,y)]2
  ```

  

- Using *Taylor expansion*:

  

  E(u,v)≈∑x,y[I(x,y)+uIx+vIy−I(x,y)]2

  

- Expanding the equation and cancelling properly:

  

  E(u,v)≈∑x,yu2I2x+2uvIxIy+v2I2y

  

- Which can be expressed in a matrix form as:

  

  E(u,v)≈[uv](∑x,yw(x,y)[I2xIxIyIxIyI2y])[uv]

  

- Let's denote:

  

  M=∑x,yw(x,y)[I2xIxIyIxIyI2y]

  

- So, our equation now is:

  

  E(u,v)≈[uv]M[uv]

  

- A score is calculated for each window, to determine if it can possibly contain a corner:

  

  R=det(M)−k(trace(M))2

  

  where:

  - det(M) = λ1λ2
  - trace(M) = λ1+λ2

  a window with a score R greater than a certain value is considered a "corner"

