<div align="center">
  <a href="https://xmake.io">
    <img width="160" heigth="160" src="https://tboox.org/static/img/xmake/logo256c.png">
  </a>

  <h1>xmake-repo</h1>

  <div>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AWindows">
      <img src="https://img.shields.io/github/actions/workflow/status/xmake-io/xmake-repo/windows.yml?branch=dev&style=flat-square&logo=windows" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3ALinux">
      <img src="https://img.shields.io/github/actions/workflow/status/xmake-io/xmake-repo/ubuntu.yml?branch=dev&style=flat-square&logo=linux" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AmacOS">
      <img src="https://img.shields.io/github/actions/workflow/status/xmake-io/xmake-repo/macos.yml?branch=dev&style=flat-square&logo=apple" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AAndroid">
      <img src="https://img.shields.io/github/actions/workflow/status/xmake-io/xmake-repo/android.yml?branch=dev&style=flat-square&logo=android" alt="github-ci" />
    </a>
  </div>
  <div>
    <a href="https://www.reddit.com/r/tboox/">
      <img src="https://img.shields.io/badge/chat-on%20reddit-ff3f34.svg?style=flat-square" alt="Reddit" />
    </a>
    <a href="https://gitter.im/tboox/tboox?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
      <img src="https://img.shields.io/gitter/room/tboox/tboox.svg?style=flat-square&colorB=96c312" alt="Gitter" />
    </a>
    <a href="https://t.me/tbooxorg">
      <img src="https://img.shields.io/badge/chat-on%20telegram-blue.svg?style=flat-square" alt="Telegram" />
    </a>
    <a href="https://jq.qq.com/?_wv=1027&k=5hpwWFv">
      <img src="https://img.shields.io/badge/chat-on%20QQ-ff69b4.svg?style=flat-square" alt="QQ" />
    </a>
    <a href="https://discord.gg/XXRp26A4Gr">
      <img src="https://img.shields.io/badge/chat-on%20discord-7289da.svg?style=flat-square" alt="Discord" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/blob/master/LICENSE.md">
      <img src="https://img.shields.io/github/license/xmake-io/xmake-repo.svg?colorB=f48041&style=flat-square" alt="license" />
    </a>
    <a href="http://xmake.io/pages/donation.html#donate">
      <img src="https://img.shields.io/badge/donate-us-orange.svg?style=flat-square" alt="Donate" />
    </a>
  </div>

  <p>一个官方的xmake包管理仓库</p>
</div>

## 项目支持

通过成为赞助者来支持该项目。您的logo将显示在此处，并带有指向您网站的链接。🙏 [[成为赞助商](https://xmake.io/#/zh-cn/about/sponsor)]

<a href="https://opencollective.com/xmake#backers" target="_blank"><img src="https://opencollective.com/xmake/backers.svg?width=890"></a>

## 简介

xmake-repo是一个官方的xmake包管理仓库，收录了常用的c/c++开发包，提供跨平台支持。

## 包依赖描述

<img src="https://xmake.io/assets/img/index/add_require.png" width="70%" />

## 包依赖管理

<img src="https://xmake.io/assets/img/index/package_manage.png" width="80%" />

如果你想要了解更多，请参考：

* [在线文档](https://xmake.io/#/zh-cn/package/remote_package)
* [在线源码](https://github.com/xmake-io/xmake)
* [项目主页](https://xmake.io/#/zh-cn/)

## Xrepo

xrepo 是一个基于 [Xmake](https://github.com/xmake-io/xmake) 的跨平台 C/C++ 包管理器。

它基于 xmake 提供的运行时，但却是一个完整独立的包管理程序，相比 vcpkg/homebrew 此类包管理器，xrepo 能够同时提供更多平台和架构的 C/C++ 包。

如果你想要了解更多，请参考：[在线文档](https://xrepo.xmake.io/#/zh-cn/getting_started), [Github](https://github.com/xmake-io/xrepo) 以及 [Gitee](https://gitee.com/tboox/xrepo)

![](https://xrepo.xmake.io/assets/img/xrepo.gif)

## 提交一个新包到仓库

在`packages/x/xxx/xmake.lua`中写个关于新包的xmake.lua描述，然后提交一个pull-request到dev分支。

例如：[packages/z/zlib/xmake.lua](https://github.com/xmake-io/xmake-repo/blob/dev/packages/z/zlib/xmake.lua):

关于如何制作包的更详细描述，请参看文档：[制作和提交到官方仓库](https://xmake.io/#/zh-cn/package/remote_package?id=%e6%b7%bb%e5%8a%a0%e5%8c%85%e5%88%b0%e4%bb%93%e5%ba%93)

## 从 Github 创建一个包模板

我们需要先安装 [gh](https://github.com/cli/cli) cli 工具，然后执行下面的命令登入 github。

```console
$ gh auth login
```

基于 github 的包地址创建一个包配置文件到此仓库。

```console
$ xmake l scripts/new.lua github:glennrp/libpng
package("libpng")
    set_homepage("http://libpng.sf.net")
    set_description("LIBPNG: Portable Network Graphics support, official libpng repository")

    add_urls("https://github.com/glennrp/libpng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/glennrp/libpng.git")
    add_versions("v1.6.35", "6d59d6a154ccbb772ec11772cb8f8beb0d382b61e7ccc62435bf7311c9f4b210")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
packages/l/libpng/xmake.lua generated!
```

### 在本地测试一个包

```console
$ xmake l scripts/test.lua --shallow -vD zlib
$ xmake l scripts/test.lua --shallow -vD -p iphoneos zlib
$ xmake l scripts/test.lua --shallow -vD -k shared -m debug zlib
$ xmake l scripts/test.lua --shallow -vD --vs_runtime=MD zlib
```
