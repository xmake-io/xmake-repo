<div align="center">
  <a href="https://xmake.io">
    <img width="200" heigth="200" src="https://tboox.org/static/img/xmake/logo256c.png">
  </a>  

  <h1>xmake-repo</h1>

  <div>
    <a href="https://travis-ci.org/xmake-io/xmake-repo">
      <img src="https://img.shields.io/travis/xmake-io/xmake-repo/dev.svg?style=flat-square" alt="travis-ci" />
    </a>
    <a href="https://ci.appveyor.com/project/waruqi/xmake-repo">
      <img src="https://img.shields.io/appveyor/ci/waruqi/xmake-repo/dev.svg?style=flat-square" alt="appveyor-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/blob/master/LICENSE.md">
      <img src="https://img.shields.io/github/license/xmake-io/xmake-repo.svg?colorB=f48041&style=flat-square" alt="license" />
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
    <a href="http://xmake.io/pages/donation.html#donate">
      <img src="https://img.shields.io/badge/donate-us-orange.svg?style=flat-square" alt="Donate" />
    </a>
  </div>

  <p>一个官方的xmake包管理仓库</p>
</div>

## 简介

xmake-repo是一个官方的xmake包管理仓库，收录了常用的c/c++开发包，提供跨平台支持。

## 包依赖描述

<img src="https://xmake.io/assets/img/index/add_require.png" width="70%" />

## 包依赖管理

<img src="https://xmake.io/assets/img/index/package_manage.png" width="80%" />

如果你想要了解更多，请参考：

* [在线文档](https://xmake.io/#/zh/)
* [在线源码](https://github.com/xmake-io/xmake)
* [项目主页](https://xmake.io/cn)

## 提交一个新包到仓库

在`packages/x/xxx/xmake.lua`中写个关于新包的xmake.lua描述，然后提交一个pull-request到dev分支。

例如：[packages/z/zlib/xmake.lua](https://github.com/xmake-io/xmake-repo/blob/dev/packages/z/zlib/xmake.lua):

关于如何制作包的更详细描述，请参看文档：[制作和提交到官方仓库](https://xmake.io/#/zh-cn/package/remote_package?id=%e6%b7%bb%e5%8a%a0%e5%8c%85%e5%88%b0%e4%bb%93%e5%ba%93)

```lua
package("zlib")

    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")

    set_urls("http://zlib.net/zlib-$(version).tar.gz",
             "https://downloads.sourceforge.net/project/libpng/zlib/$(version)/zlib-$(version).tar.gz")

    add_versions("1.2.10", "8d7e9f698ce48787b6e1c67e6bff79e487303e66077e25cb9784ac8835978017")
    add_versions("1.2.11", "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1")

    on_install("windows", function (package)
        io.gsub("win32/Makefile.msc", "%-MD", "-" .. package:config("vs_runtime"))
        os.vrun("nmake -f win32\\Makefile.msc zlib.lib")
        os.cp("zlib.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package, {"--static"})
    end)
 
    on_install("iphoneos", "android@linux,macosx", "mingw@linux,macosx", function (package)
        import("package.tools.autoconf").configure(package, {host = "", "--static"})
        io.gsub("Makefile", "\nAR=.-\n",      "\nAR=" .. (package:build_getenv("ar") or "") .. "\n")
        io.gsub("Makefile", "\nARFLAGS=.-\n", "\nARFLAGS=cr\n")
        io.gsub("Makefile", "\nRANLIB=.-\n",  "\nRANLIB=\n")
        os.vrun("make install -j4")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zlib.h"}))
    end)
```

## 被支持的包列表


|linux|windows|mingw|iphoneos|macosx|android|
|-----|-------|-----|--------|------|-------|
|boost|boost|catch2|catch2|autoconf|catch2||
|bzip2|bzip2|doctest|cjson|automake|cjson||
|cairo|cairo|nlohmann_json|doctest|boost|doctest||
|catch2|catch2|tbox|json-c|bzip2|json-c||
|cjson|doctest|zlib|libcurl|cairo|libjpeg||
|doctest|expat||libev|catch2|libpng||
|expat|freeglut||libffi|cjson|libuv||
|ffmpeg|freetype||libjpeg|cmake|libxml2||
|fontconfig|glew||libpng|doctest|lua||
|freeglut|go||libuv|expat|nlohmann_json||
|freetype|libcurl||libxml2|ffmpeg|tbox||
|gettext|libjpeg||nlohmann_json|fontconfig|zlib||
|glew|libpng||tbox|freetype|||
|glib|libsdl||zlib|gettext|||
|go|libuv|||glew|||
|gperf|lua|||glib|||
|icu4c|luajit|||go|||
|json-c|nlohmann_json|||gperf|||
|libcurl|pcre|||icu4c|||
|libev|pixman|||json-c|||
|libffi|protobuf-c|||libcurl|||
|libiconv|protobuf-cpp|||libev|||
|libjpeg|skia|||libffi|||
|libmill|sqlite3|||libiconv|||
|libpng|tbox|||libjpeg|||
|libsdl|zlib|||libmill|||
|libtask||||libpng|||
|libuv||||libsdl|||
|libxml2||||libtask|||

这里只显示了部分包，如果你想看所有包列表，可以看下：[PKGLIST.md](https://github.com/xmake-io/xmake-repo/blob/master/PKGLIST.md)

我们也非常欢迎大家能够贡献一些进来。🙏 
