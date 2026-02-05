package("libvpx")
    set_homepage("https://chromium.googlesource.com/webm/libvpx/")
    set_description("libvpx is a free software video codec library from Google and the Alliance for Open Media (AOMedia)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/webmproject/libvpx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/webmproject/libvpx.git",
             "https://chromium.googlesource.com/webm/libvpx.git")
    add_versions("v1.16.0", "7a479a3c66b9f5d5542a4c6a1b7d3768a983b1e5c14c60a9396edc9b649e015c")
    add_versions("v1.15.2", "26fcd3db88045dee380e581862a6ef106f49b74b6396ee95c2993a260b4636aa")
    add_versions("v1.15.1", "6cba661b22a552bad729bd2b52df5f0d57d14b9789219d46d38f73c821d3a990")
    add_versions("v1.15.0", "e935eded7d81631a538bfae703fd1e293aad1c7fd3407ba00440c95105d2011e")
    add_versions("v1.14.1", "901747254d80a7937c933d03bd7c5d41e8e6c883e0665fadcb172542167c7977")

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool", "m4", "yasm")
    end

    add_configs("vp8",              {description = "enable the vp8 codec", default = false, type = "boolean"})
    add_configs("vp9",              {description = "enable the vp9 codec", default = false, type = "boolean"})
    add_configs("vp9_post",         {description = "vp9 specific postprocessing", default = false, type = "boolean"})
    add_configs("vp9_highbitdepth", {description = "use VP9 high bit depth (10/12) profiles", default = false, type = "boolean"})

    add_configs("postproc",         {description = "postprocessing", default = false, type = "boolean"})
    add_configs("codec_srcs",       {description = "in/exclude codec library source code", default = false, type = "boolean"})
    add_configs("webm_io",          {description = "enable input from and output to WebM container", default = false, type = "boolean"})
    add_configs("libyuv",           {description = "enable libyuv", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("libyuv") then
            package:add("deps", "libyuv")
        end
    end)

    if on_check then
        on_check(function (package)
            if package:has_tool("cxx", "clang") and package:is_arch("x64", "x86_64") then
                raise("package(libvpx) unsupported clang toolchain")
            end
        end)
    end

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-examples", "--disable-docs", "--as=yasm", "--disable-unit-tests"}

        table.insert(configs, (package:config("shared") and "--enable-shared --disable-static" or "--disable-shared --enable-static"))
        table.insert(configs, (package:is_debug() and "--enable-debug" or ""))

        table.insert(configs, (package:config("vp8") and "--enable-vp8" or "--disable-vp8"))
        table.insert(configs, (package:config("vp9") and "--enable-vp9" or "--disable-vp9"))
        table.insert(configs, (package:config("vp9_post") and "--enable-vp9-postproc" or "--disable-vp9-postproc"))
        table.insert(configs, (package:config("vp9_highbitdepth") and "--enable-vp9-highbitdepth" or "--disable-vp9-highbitdepth"))
        
        table.insert(configs, (package:config("postproc") and "--enable-postproc" or "--disable-postproc"))
        table.insert(configs, (package:config("codec_srcs") and "--enable-codec-srcs" or ""))
        table.insert(configs, (package:config("webm_io") and "--enable-webm-io" or "--disable-webm-io"))
        table.insert(configs, (package:config("libyuv") and "--enable-libyuv" or "--disable-libyuv"))

        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vpx_codec_build_config", {includes = "vpx/vpx_codec.h"}))
        if package:config("vp8") then 
            assert(package:has_cfuncs("vpx_codec_encode", {includes = "vpx/vpx_encoder.h"}))
        end
    end)
