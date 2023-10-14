---
layout: post
title: CMAKE的三方库管理
categories: [dev]
tags: [cmake]
description: CMAKE依赖管理
keywords: cmake,依赖管理
dashang: true
topmost: false
mermaid: false
date:  2022-11-20 10:00:00 +0800
---
现代项目中，越来越多的项目构建使用CMake,而仍有很多项目的构建会使用其它构建方式， 如gnu make等， 因此学会CMake项目中的依赖管理，有助于快速进行项目开发。

<!-- more -->

* TOC
{:toc}
在 C/C++ 项目中使用第三方库有两种方式：

1. 第三方库在项目外部单独构建：从库的官网或是系统包管理程序上下载预编译好的包，或者事先在项目外部的其他路径下使用库的源码进行编译
2. 第三方库的构建集成到项目的构建过程里，从源码开始编译

第一种方式对外部环境编译的要求是不确定的，很可能会打击构建项目的积极性，毕竟并不是所有的平台/发行版/系统版本都能轻松完成各种库的编译和安装。但这种方式很适合编译时间久或者工具链复杂的第三方库，比如说 Qt、V8、OSPRay 等。

第二种方式对开发者比较友好，简单粗暴的实现方式是使用 Git Submodule 拉取依赖源码，或者编写一些脚本管理第三方库。 但如果是使用 CMake 作为构建系统的项目，我们可以利用 CMake 的 FetchContent 模块来管理依赖。 [FetchCotent](https://cmake.org/cmake/help/latest/module/FetchContent.html) 是 CMake 3.11 版本开始引入的依赖管理模块，和其他方式相比主要有以下几个优点：

1. 支持 Git Clone、下载源码压缩包等多种方式获取代码
2. 可以处理依赖树中存在的重复依赖
3. 在 CMake Configure 阶段拉取代码，build 阶段编译代码，符合 CMake 原有机制，减少了执行多个命令的麻烦
4. 用 CMake 一套工具控制一切编译、安装任务

上面提到了两种使用第三方库的方式，在 CMake 项目中还可以分出两种子情况，即第三方库是否也使用 CMake 作为构建系统，下面就介绍如何处理这四种情况。

# 1、第三方库使用 CMake, 并集成到项目的构建过程里

这种情况可以使用`FetchContent`模块获取第三方库的源码，核心函数只有两个：`FetchContent_Declare`和`FetchContent_Populate`，前者用于声明信息，后者用于下载代码。

下面的例子声明了两个依赖，AAA 和 bbb：

```c
include(FetchContent) # 引入该CMake模块
FetchContent_Declare( # 声明依赖的相关信息
  AAA
  GIT_REPOSITORY https://github.com/AAA/AAA.git
  GIT_TAG        v1.0.0
  GIT_SHALLOW    TRUE # 不拉取完整历史，相当于`git clone --depth=1`
)
FetchContent_Declare(
  bbb
  URL  https://bbb.com/v2.0.0/bbb.tar.gz
  HASH qwerty # 可选，确保文件的正确性
)
```

但仅声明不会有代码被下载，还需要执行`FetchContent_Populate`才能使代码能在 Configure 阶段被下载，下载前也可以设置一些变量对子 CMake 项目进行控制：

```c
set(AAA_BUILD_TESTS OFF) # 设置好变量用于关掉AAA项目的测试

FetchContent_GetProperties(AAA)
if(NOT AAA_POPULATED) # 确保只拉取一次
  FetchContent_Populate(AAA) # 此函数执行后将设置AAA_POPULATED变量
  # 通过AAA_SOURCE_DIR和AAA_BINARY_DIR就可以拿到源码所在目录的路径以及编译产物的目标路径
  # 此外还有其他变量可以用，见CMake FetchContent文档
  add_subdirectory(${AAA_SOURCE_DIR} ${AAA_BINARY_DIR})
endif ()

FetchContent_GetProperties(bbb)
if(NOT bbb_POPULATED)
  FetchContent_Populate(bbb)
  add_subdirectory(${bbb_SOURCE_DIR} ${bbb_BINARY_DIR})
endif ()
```

`add_subdirectory`后，AAA 项目的 target 都会进入到当前项目的作用域里，使用`target_link_libraries`即可完成关联。 (如果不了解 target 的概念，可以看我的另一篇文章:[现代 CMake 的设计理念和使用](https://ukabuer.me/blog/more-modern-cmake/)。)

`AAA_POPULATED`这个变量会被`FetchContent_Populate`设置，可以用于确保同名依赖只被拉取一次。 因此当依赖树中存在同名的重复依赖时，最先被拉取的将会覆盖其他的版本。 假设上面的 AAA 和 bbb 两个依赖，同时使用`FetchContent_Declare`声明依赖了不同版本的 Ccc。如果 AAA 项目先执行`FetchContent_Populate`，则最终 Ccc 项目会使用 AAA 项目中定义的版本。 除此之外，我们还可以在声明 AAA 和 bbb 两个依赖前，提前 populate 特定版本的 Ccc，就可以实现版本的覆盖。

顺带一提，所有使用 FetchContent 模块下载的源码相关目录都在 build 目录下的`_deps`文件夹里。

# 2、第三方库未使用 CMake，将其集成到项目的构建过程里

使用的第三方库不一定使用了 CMake，或者使用不是现代 CMake。这些情况下利用`FetchContent_GetProperties`可以拿到依赖库的各种目录，结合 CMake 的其他命令完成各种操作。

比如`Eigen`这个 header-only 库，虽然使用了 CMake，但项目中测试相关的 target 过多，并且难以方便的禁用，我们可以在拿到源代码路径后自己创建一个简单的 target

```c
include(FetchContent)
FetchContent_Declare(
    eigen3
    URL https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.bz2
    URL_MD5 b9e98a200d2455f06db9c661c5610496
)
FetchContent_GetProperties(eigen3)
if (NOT eigen3_POPULATED)
  FetchContent_Populate(eigen3)
endif ()

add_library(eigen INTERFACE)
target_include_directories(eigen INTERFACE ${eigen3_SOURCE_DIR})
```

还有很多使用 make 作为编译工具的项目，我们可以通过拿到源码目录后，使用`add_custom_command`和`add_custom_target`原地编译，并创建一个简单的 imported target。 这里以[uWebSockets](https://github.com/uNetworking/uWebSockets)为例，这个库本身是 header-only 的，但使用 Git Submodules 依赖了一个使用 make 的子项目 uSockets：

```c
# 常规操作，declare后polulate
include(FetchContent)
FetchContent_Declare(
    uWebSockets-git
    GIT_REPOSITORY https://github.com/uNetworking/uWebSockets.git
    GIT_TAG v18
)

FetchContent_GetProperties(uWebSockets-git)
if (NOT uWebSockets-git_POPULATED)
  FetchContent_Populate(uWebSockets-git)
endif ()

# 创建一个命令用于编译出uSockets的静态库，并且创建好头文件目录
add_custom_command(
    OUTPUT ${uWebSockets-git_SOURCE_DIR}/uSockets/uSockets.a
    COMMAND cp -r src uWebSockets && make
    WORKING_DIRECTORY ${uWebSockets-git_SOURCE_DIR}
    COMMENT "build uSockets"
    VERBATIM
)
# 创建一个自定义target，依赖上面自定义命令的OUTPUT，但这样CMake还不会编译这个target，还需要一个真正的target依赖此target
add_custom_target(uSockets DEPENDS ${uWebSockets-git_SOURCE_DIR}/uSockets/uSockets.a)

# 创建一个imported target，依赖上面的自定义target，从而确保在使用这个imported target时，上面的编译命令能被执行
add_library(uWebSockets STATIC IMPORTED)
set_property(TARGET uWebSockets PROPERTY IMPORTED_LOCATION ${uWebSockets-git_SOURCE_DIR}/uSockets/uSockets.a)
set_target_properties(
    uWebSockets PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${uWebSockets-git_SOURCE_DIR};${uWebSockets-git_SOURCE_DIR}/uSockets/src"
)
add_dependencies(uWebSockets uSockets) # 见上面add_custom_target的说明
```

总之当拿到源码目录后，可以结合 CMake 的其他命令完成各种操作，毕竟我们需要的可以只有头文件和链接库文件。

# 3、第三方库使用 CMake，在项目外部构建

一个靠谱的 CMake Library 项目应该在 install package 时提供`xxx-config.cmake`或者`XXXConfig.cmake`文件，其中包含项目相关的 imported target， 或者设置链接库路径等 CMake 变量。 （具体怎么做可以参考 CMake 官方的这个教程: [Adding Export Configuration (Step 11)](https://cmake.org/cmake/help/latest/guide/tutorial/index.html#adding-export-configuration-step-11)，或者这篇更详细的指导：[Tutorial: Easily supporting CMake install and find_package()](https://foonathan.net/2016/03/cmake-install/))

这种情况下可以使用`find_package`命令来寻找依赖。假设库的名称为`Aaa`，调用`find_package(Aaa 1.0.0)`时，CMake 会尝试在`/usr/lib/cmake`等[默认路径](https://cmake.org/cmake/help/latest/command/find_package.html#search-procedure)下寻找`Aaa-config.cmake`或者`AaaConfig.cmake`，这个文件可以放在以`Aaa*`为前缀的文件夹下来支持多版本并存。（Linux 用户可以执行`ls /usr/lib/cmake`看看）

当然，这个第三方库不一定就安装在默认路径，那么用户可以设置`Aaa_DIR`这个变量，用于提示 CMake 应该去哪里寻找 config 文件。 在找到该文件后，`Aaa_FOUND`变量会被设置，同时 config 文件中包含的 target 以及 CMake 变量都会存在于`fink_packge`之后的的作用域里，可以按需使用。

# 4、第三方库未使用 CMake，在项目外部构建(不建议使用，可能容易根Host环境混淆)

现实并不总是那么美好，第三方库安装时可能没有提供 config 文件，比如使用`make`作为构建工具的项目。

我们可以直接使用`find_path`, `find_library`两个命令来寻找头文件以及链接库所在的路径，CMake 会尝试到默认路径下寻找， 但同样的，库不一定被安装在默认路径下，于是我们可以允许使用一个变量来提示位置：

```c
# 可以设置POCO_INCLUDE_DIR这个变量进行路径的提示
find_path(
  POCO_INCLUDE_PATH
  NAMES Poco.h Poco/Poco.h
  HINTS ${POCO_INCLUDE_DIR} "${CMAKE_PREFIX_PATH}/include"
)
# 可以设置POCO_LIB_DIR这个变量进行路径的提示
find_library(
  POCO_FOUNDATION_LIB
  NAMES PocoFoundation
  HINTS ${POCO_LIB_DIR} "${CMAKE_PREFIX_PATH}/lib"
)
```

在找到头文件以及链接库后，我们可以直接用，或者创建个 imported target 使用。

```c
add_library(Poco)STATIC IMPORTED)
set_property(TARGET Poco PROPERTY IMPORTED_LOCATION ${POCO_FOUNDATION_LIB})
set_target_properties(
    Poco PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${POCO_INCLUDE_DIR}
)
```

更优雅的方式是向 CMake 提供一个`FindXxx.cmake`脚本，其中可以使用各种方法（比如`find_path`和`find_library`）找到库，并并导出库的信息。

上一节提到`find_package(Aaa 1.0.0)`会去寻找 config 文件，这个描述实际上并不完整。 `find_package`有`MODULE`和`CONFIG`两种模式，`MODULE`模式寻找`FindXxx.cmake`文件，`CONFIG`模式寻找 config 文件。 如果像本文里没有指定模式，CMake 优先按`MODULE`模式寻找库，没找到的话 fallback 到`CONFIG`模式。（详见[Basic Signature and Module Mode](https://cmake.org/cmake/help/latest/command/find_package.html#id2)）。两者一个重要的区别在于，config 脚本由库的开发者提供，find 脚本由使用者提供。

很多基于 make 构建工具的第三方库都可以在网上可以找到 find 脚本，同时 CMake 官方也为我们写好了很多常用库的[Find 脚本](https://cmake.org/cmake/help/latest/manual/cmake-modules.7.html#find-modules)，比如 OpenGL, JPEG, ZLIB，对于这些库无需编写 find 脚本直接使用`find_package`就可以了。

寻找 find 脚本时，CMake 会优先到`CMAKE_MODULE_PATH`变量对应的路径找，随后是 CMake 自带的 find 脚本目录。 如果我们准备好了某个库的 find 脚本，可以把其所在的目录加到`CMAKE_MODULE_PATH`里，这样`find_package`就能找到他。

```c
list(APPEND CMAKE_MODULE_PATH "./cmake/")
find_package(MyLib)
if (MyLib_FOUND)
  # ...
```

# 5、使用ExternalProject

FetchContent vs ExternalProject

| project                      | CMAKE_SOURCE_DIR                   | CMAKE_BINARY_DIR                         | PROJECT_SOURCE_DIR                 |
| ---------------------------- | ---------------------------------- | ---------------------------------------- | ---------------------------------- |
| parent                       | ~/foo                              | ~/foo/build                              | ~/foo                              |
| child: standalone            | ~/bar                              | ~/bar/build                              | ~/bar                              |
| child: CMake ExternalProject | ~/foo/build/child-prefix/src/child | ~/foo/build/child-prefix/src/child-build | ~/foo/build/child-prefix/src/child |
| child: CMake FetchContent    | ~/foo                              | ~/foo/build                              | ~/foo/build/_deps/child-src        |

**FetchContent** populates content from the other project at **configure** time. FetchContent populates the “child” project with default values from the “parent” project. Varibles set in the “child” project generally do not affect the “parent” project unless specifically used from the “parent” project.

From “parent” project CMakeLists.txt:

```cmake
cmake_minimum_required(VERSION 3.14)
project(parent Fortran)

include(FetchContent)
FetchContent_Declare(child
  GIT_REPOSITORY https://github.invalid/username/child.git
  GIT_TAG main
)
# it's much better to use a specific Git revision or Git tag for reproducibility

FetchContent_MakeAvailable(child)

# your program
add_executable(myprog main.f90)
target_link_libraries(myprog mylib)  # mylib is from "child"
```

- `FetchContent_MakeAvailable`

  make “child” code configure, populating variables and targets as if it were part of “parent” CMake project.

------

suppose “child” project CMakeLists.txt contains:

```cmake
project(child LANGUAGES Fortran)

add_library(mylib mylib.f90)

target_include_libraries(mylib INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/include)

set_property(TARGET mylib PROPERTY Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
```

The child project `CMAKE_BINARY_DIR` and `CMAKE_SOURCE_DIR` will be those of parent project. That is, if the parent project is in ~/foo and the build directory is ~/foo/build, then the child project in ~/childcode called by FetchContent will also have `CMAKE_SOURCE_DIR` of ~/foo and `CMAKE_BINARY_DIR` of ~/foo/build. So be careful in the child project when using such variables that may be defined by parent projects. This is why projects that aren’t specifically designed to work together may be better joined by ExternalProject. A typical technique within the child project that can operate standalone is to refer to `CMAKE_CURRENT_SOURCE_DIR` instead of `CMAKE_SOURCE_DIR` as the latter will break when used from FetchContent.

**IMPORTANT:** When using `if()` clauses to determine execution of FetchContent, ensure that the FetchContent stanzas are executed each time CMake is run. Otherwise, the FetchContent targets may fail to be available or may have missing target properties on CMake rebuild.

**ExternalProject** populates content from the other project at **build** time. This means the other project’s libraries are not visible until the parent project is built. Since ExternalProject does not combine the project namespaces, ExternalProject may be necessary if you don’t control the other projects.

**ExternalProject may not activate without the `add_dependencies()` statement.** Upon `cmake --build` of the parent project, ExternalProject downloads, configures and builds.

From “parent” project CMakeLists.txt:

```cmake
project(parent LANGUAGES Fortran)

include(ExternalProject)

set(mylist "a;b;c")
# passing a list to external project is best done via CMAKE_CACHE_ARGS
# CMAKE_ARGS doesn't work correctly for lists

set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED true)
# don't repeatedly build ExternalProjects.
# dir prop scope: CMake_current_source_dir and subdirectories

ExternalProject_Add(CHILD
GIT_REPOSITORY https://github.com/scivision/cmake-externalproject
GIT_TAG main
CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
CMAKE_CACHE_ARGS -Dmyvar:STRING=${mylist}   # need variable type e.g. STRING for this
CONFIGURE_HANDLED_BY_BUILD ON
BUILD_BYPRODUCTS ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}timestwo${CMAKE_STATIC_LIBRARY_SUFFIX}
)

add_library(timestwo STATIC IMPORTED GLOBAL)
set_property(TARGET timestwo PROPERTY IMPORTED_LOCATION ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}timestwo${CMAKE_STATIC_LIBRARY_SUFFIX})
set_property(TARGET timestwo PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_INSTALL_PREFIX}/include)

add_executable(test_timestwo test_timestwo.f90)  # your program
add_dependencies(test_timestwo CHILD)  # externalproject won't download without this
target_link_libraries(test_timestwo PRIVATE timestwo)
```

- [add_dependencies()](https://cmake.org/cmake/help/latest/command/add_dependencies.html)

  make ExternalProject always update and build first

- CONFIGURE_HANDLED_BY_BUILD ON

  tells CMake not to reconfigure each build, unless the build system requests configure

- BUILD_BYPRODUCTS

  necessary for Ninja to not complain about missing targets. Note how we can’t use BINARY_DIR since it’s populated by ExternalProject_Get_Property()

The imported library `ext` is used in the “parent” project just like any other library.

------

“child” project CMakeLists.txt includes:

```cmake
project(child Fortran)

add_library(timestwo STATIC timestwo.f90)
set_property(TARGET timestwo PROPERTY Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
```

Configure “child” `Fortran_MODULE_DIRECTORY` so that it’s not necessary for “parent” to introspect “child” directory structure.



# 6、创建对下游友好的 CMake 项目

目前想到了下面这几点，对于最佳实践的追求总是没有尽头的，但希望大家可以一起建设更友好的 C/C++ 开发生态：

1. 使用基于 target 的现代 CMake
2. 作为库的开发者，在预编译的 package 里提供 config 脚本
3. 代码仓库里不要放太多代码无关的大文件，避免下载时间过长
4. 打好版本 tag，方便控制版
