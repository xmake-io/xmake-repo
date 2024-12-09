package("jxrlib")
    set_homepage("https://github.com/4creators/jxrlib")
    set_description("jxrlib is JPEG XR Image Codec reference implementation library released by Microsoft under BSD-2-Clause License. This repo is a clone of jxrlib as released by Microsoft from it's original Codeplex location https://jxrlib.codeplex.com.  The only changes comprise addition of LICENSE and README.md in repo root.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/4creators/jxrlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/4creators/jxrlib.git")

    add_versions("v2019.10.9", "555c006e27c5cb66f99c05dcbb2feb197199ca9018dbd06d3467d37cd29a79cd")

    -- https://github.com/conan-io/conan-center-index/tree/master/recipes/jxrlib/all/patches
    add_patches("2019.10.9", "patches/missing-declarations.patch", "5f92269d5aef7abdae7fdd2df42259cdce1f41b394f204768a234d462f3a9ae6")
    -- https://github.com/microsoft/vcpkg/blob/b9f5f9c4fd0088a7e56ae357a4ba39bc3f8be2de/ports/jxrlib/fix-mingw.patch
    add_patches("2019.10.9", "patches/mingw.patch", "00b06017562d618832943e02d914f39ff5480a8917dd8147b2c26fd15f68ddaa")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_includedirs("include", "include/jxrlib")

    on_load(function (package)
        package:add("links", "jxrglue", "jpegxr")
        if package:is_plat("windows", "mingw", "msys") then
            package:add("defines", "WIN32")
        else
            package:add("defines", "__ANSI__")
        end
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PKCreateCodecFactory", {includes = "JXRTest.h"}))
    end)
