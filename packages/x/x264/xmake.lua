package("x264")

    set_homepage("https://www.videolan.org/developers/x264.html")
    set_description("A free software library and application for encoding video streams into the H.264/MPEG-4 AVC compression format.")

    add_urls("http://git.videolan.org/git/x264.git")
    add_versions("v2021.09.29", "66a5bc1bd1563d8227d5d18440b525a09bcf17ca")
    add_versions("v2018.09.25", "545de2ffec6ae9a80738de1b2c8cf820249a2530")

    add_deps("nasm")
    add_configs("toolchains", {readonly = true, description = "Set package toolchains only for cross-compilation."})

    add_syslinks("pthread", "dl")
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-avs", "--disable-lsmash", "--disable-lavf", "--disable-bashcompletion"}
        table.insert(configs, "--enable-" .. (package:config("shared") and "shared" or "static"))
        if package:config("pic") ~= false then
            table.insert(configs, "--enable-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x264_encoder_open", {includes = {"stdint.h", "x264.h"}}))
    end)
