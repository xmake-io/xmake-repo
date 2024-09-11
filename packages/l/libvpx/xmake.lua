package("libvpx")
    set_homepage("https://chromium.googlesource.com/webm/libvpx/")
    set_description("libvpx is a free software video codec library from Google and the Alliance for Open Media (AOMedia)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/webmproject/libvpx/archive/refs/tags/v1.14.1.tar.gz")
    add_versions("v1.14.1", "901747254d80a7937c933d03bd7c5d41e8e6c883e0665fadcb172542167c7977")

    add_deps("autoconf", "automake", "libtool", "m4", "yasm", "nasm")

    add_configs("vp8", {description = "enable the vp8 codec", default = false, type = "boolean"})
    add_configs("vp9", {description = "enable the vp9 codec", default = false, type = "boolean"})
    add_configs("vp9-post", {description = "vp9 specific postprocessing", default = false, type = "boolean"})
    add_configs("postproc", {description = "postprocessing", default = false, type = "boolean"})
    add_configs("codec-srcs", {description = "in/exclude codec library source code", default = false, type = "boolean"})

    on_install("linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-examples", "--disable-docs"}
        table.insert(configs, (package:is_debug() and "--enable-debug" or ""))
        table.insert(configs, (package:config("shared") and "--enable-shared" or ""))
        table.insert(configs, (package:config("vp8") and "--enable-vp8" or ""))
        table.insert(configs, (package:config("vp9") and "--enable-vp9" or ""))
        table.insert(configs, (package:config("vp9-post") and "----enable-vp9-postproc" or ""))
        table.insert(configs, (package:config("codec-srcs") and "--enable-codec-srcs" or ""))
        table.insert(configs, (package:config("postproc") and "--enable-postproc" or ""))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vpx_codec_encode", {includes = "vpx/vpx_encoder.h"}))
    end)
