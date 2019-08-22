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

  <p>An official xmake package repository</p>
</div>

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
|autoconf|bzip2|doctest|doctest|autoconf|doctest||
|automake|cairo|nlohmann_json|libev|automake|libjpeg||
|bzip2|cmake|tbox|libjpeg|bzip2|libpng||
|cairo|doctest|zlib|libpng|cairo|libuv||
|cjson|expat||libuv|cjson|nlohmann_json||
|cmake(x86_64)|freeglut||nlohmann_json|cmake|tbox||
|doctest|freetype||tbox|doctest|zlib||
|expat|glew||zlib|expat|||
|ffmpeg|go|||ffmpeg|||
|fontconfig|libjpeg|||fontconfig|||
|freeglut|libpng|||freetype|||
|freetype|libsdl|||glew|||
|glew|libuv|||go|||
|go|lua|||gperf|||
|gperf|luajit|||json-c|||
|json-c|make|||libev|||
|libev|nlohmann_json|||libiconv|||
|libiconv|patch|||libjpeg|||
|libjpeg|pcre|||libmill|||
|libmill|pixman|||libpng|||
|libpng|python|||libsdl|||
|libsdl|sqlite3|||libtask|||
|libtask|tbox|||libtool|||
|libtool|zlib|||libuv|||
|libuv||||libxml2|||
|libxml2||||lua|||

Note: Only some packages are shown here. If you want to see a complete list of all packages, please see: [PKGLIST.md](https://github.com/xmake-io/xmake-repo/blob/master/PKGLIST.md)

We also welcome everyone to contribute some packages to our package repository.🙏 

