package("libvpx")
    set_homepage("https://chromium.googlesource.com/webm/libvpx/")
    set_description("libvpx is a free software video codec library from Google and the Alliance for Open Media (AOMedia)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/webmproject/libvpx/archive/refs/tags/v1.14.1.tar.gz")
    add_versions("v1.14.1", "901747254d80a7937c933d03bd7c5d41e8e6c883e0665fadcb172542167c7977")

    add_deps("autoconf", "automake", "libtool", "m4", "yasm")

    add_configs("vp8",              {description = "enable the vp8 codec", default = false, type = "boolean"})
    add_configs("vp9",              {description = "enable the vp9 codec", default = false, type = "boolean"})
    add_configs("vp9_post",         {description = "vp9 specific postprocessing", default = false, type = "boolean"})
    add_configs("vp9_highbitdepth", {description = "use VP9 high bit depth (10/12) profiles", default = false, type = "boolean"})

    add_configs("postproc",         {description = "postprocessing", default = false, type = "boolean"})
    add_configs("codec_srcs",       {description = "in/exclude codec library source code", default = false, type = "boolean"})
    add_configs("webm_io",          {description = "enable input from and output to WebM container", default = false, type = "boolean"})
    add_configs("libyuv",           {description = "enable libyuv", default = false, type = "boolean"})


    if on_check then
        on_check(function (package)
            if package:has_tool("cxx", "clang") and is_arch("x64", "x86_64") then
                raise("package(libvpx) unsupported clang toolchain")
            end
        end)
    end

    on_install(function (package)
        local configs = {"--disable-dependency-tracking", "--disable-examples", "--disable-docs", "--as=yasm", "--disable-unit-tests"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")
        else
            table.insert(configs, "--disable-shared")
            table.insert(configs, "--enable-static")
        end
        table.insert(configs, (package:is_debug() and "--enable-debug" or ""))

        table.insert(configs, (package:config("vp8") and "--enable-vp8" or "--disable-vp8"))
        table.insert(configs, (package:config("vp9") and "--enable-vp9" or "--disable-vp9"))
        table.insert(configs, (package:config("vp9_post") and "----enable-vp9-postproc" or ""))
        table.insert(configs, (package:config("vp9_highbitdepth") and "----enable-vp9-postproc" or ""))
        
        table.insert(configs, (package:config("postproc") and "--enable-postproc" or ""))
        table.insert(configs, (package:config("codec_srcs") and "--enable-codec-srcs" or ""))
        table.insert(configs, (package:config("webm_io") and "--enable-webm-io" or ""))
        table.insert(configs, (package:config("libyuv") and "--enable-libyuv" or ""))
        
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vpx_codec_build_config", {includes = "vpx/vpx_codec.h"}))
        if package:config("vp8") then 
            assert(package:has_cfuncs("vpx_codec_encode", {includes = "vpx/vpx_encoder.h"}))
        end
    end)
