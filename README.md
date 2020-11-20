<div align="center">
  <a href="https://xmake.io">
    <img width="160" heigth="160" src="https://tboox.org/static/img/xmake/logo256c.png">
  </a>  

  <h1>xmake-repo</h1>

  <div>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AWindows">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/Windows/dev.svg?style=flat-square&logo=windows" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3ALinux">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/Linux/dev.svg?style=flat-square&logo=linux" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AmacOS">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/macOS/dev.svg?style=flat-square&logo=apple" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AAndroid">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/Android/dev.svg?style=flat-square&logo=android" alt="github-ci" />
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
    <a href="https://github.com/xmake-io/xmake-repo/blob/master/LICENSE.md">
      <img src="https://img.shields.io/github/license/xmake-io/xmake-repo.svg?colorB=f48041&style=flat-square" alt="license" />
    </a>
    <a href="http://xmake.io/pages/donation.html#donate">
      <img src="https://img.shields.io/badge/donate-us-orange.svg?style=flat-square" alt="Donate" />
    </a>
  </div>

  <p>An official xmake package repository</p>
</div>

## Supporting the project

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. 🙏 [[Become a sponsor](https://xmake.io/#/about/sponsor)]

<a href="https://opencollective.com/xmake#backers" target="_blank"><img src="https://opencollective.com/xmake/backers.svg?width=890"></a>

## Introduction ([中文](/README_zh.md))

xmake-repo is an official xmake package repository. 

## Package dependences

<img src="https://xmake.io/assets/img/index/add_require.png" width="70%" />

## Package management

<img src="https://xmake.io/assets/img/index/package_manage.png" width="80%" />

If you want to know more, please refer to:

* [Documents](https://xmake.io/#/home)
* [Github](https://github.com/xmake-io/xmake)
* [HomePage](https://xmake.io)

## Xrepo

xrepo is a cross-platform C/C++ package manager based on [Xmake](https://github.com/xmake-io/xmake).

It is based on the runtime provided by xmake, but it is a complete and independent package management program. Compared with package managers such as vcpkg/homebrew, xrepo can provide C/C++ packages for more platforms and architectures at the same time.

If you want to know more, please refer to: [Documents](https://xrepo.xmake.io/#/getting_started), [Github](https://github.com/xmake-io/xrepo) and [Gitee](https://gitee.com/tboox/xrepo)

![](https://xrepo.xmake.io/assets/img/xrepo.gif)

## Submit package to repository

Write a xmake.lua of new package in `packages/x/xxx/xmake.lua` and push a pull-request to the dev branch.

For example, [packages/z/zlib/xmake.lua](https://github.com/xmake-io/xmake-repo/blob/dev/packages/z/zlib/xmake.lua):

If you want to known more, please see: [Create and Submit packages to the official repository](https://xmake.io/#/package/remote_package?id=submit-packages-to-the-official-repository)

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

## Supported Packages

|linux|windows|mingw|iphoneos|macosx|android|
|-----|-------|-----|--------|------|-------|
|boost|boost|catch2|catch2|autoconf|catch2||
|bullet3|bzip2|concurrentqueue|cjson|automake|cjson||
|bzip2|cairo|cpp-taskflow|concurrentqueue|boost|concurrentqueue||
|cairo|catch2|doctest|cpp-taskflow|bullet3|cpp-taskflow||
|catch2|concurrentqueue|fmt|doctest|bzip2|doctest||
|cjson|cpp-taskflow|gtest|fmt|cairo|ffmpeg||
|concurrentqueue|doctest|imgui|gtest|catch2|fmt||
|cpp-taskflow|expat|inja|imgui|cjson|gtest||
|doctest|fmt|libjpeg|inja|cmake|imgui||
|expat|freeglut|libsdl|json-c|concurrentqueue|inja||
|ffmpeg|freetype|nlohmann_json|libcurl|cpp-taskflow|json-c||
|fmt|glew|pcre|libev|doctest|libjpeg||
|fontconfig|go|pcre2|libffi|expat|libpng||
|freeglut|gtest|spdlog|libjpeg|ffmpeg|libuv||
|freetype|imgui|tbox|libpng|fmt|libxml2||
|gettext|inja|xz|libuv|fontconfig|lua||
|glew|libcurl|zlib|libxml2|freetype|nlohmann_json||
|glib|libjpeg||nlohmann_json|gettext|spdlog||
|go|libpng||spdlog|glew|tbox||
|gperf|libsdl||tbox|glib|zlib||
|gtest|libtiff||zlib|go|||
|icu4c|libuv|||gperf|||
|imgui|libwebsockets|||gtest|||
|inja|lua|||icu4c|||
|json-c|luajit|||imgui|||
|libcurl|nana|||inja|||
|libev|nlohmann_json|||json-c|||
|libffi|oatpp|||libcurl|||
|libiconv|pcre|||libev|||
|libjpeg|pixman|||libffi|||
|libmill|protobuf-c|||libiconv|||
|libpng|protobuf-cpp|||libjpeg|||
|libsdl|raylib|||libmill|||
|libtask|skia|||libpng|||
|libtiff|spdlog|||libsdl|||
|libusb|sqlite3|||libtask|||
|libuv|tbox|||libtiff|||
|libwebsockets|unqlite|||libtool|||
|libxml2|zeromq|||libusb|||

Note: Only some packages are shown here. If you want to see a complete list of all packages, please see: [Packages List](https://xrepo.xmake.io/#/packages/linux)

We also welcome everyone to contribute some packages to our package repository.🙏 

