package("x264")

    set_homepage("https://www.videolan.org/developers/x264.html")
    set_description("A free software library and application for encoding video streams into the H.264/MPEG-4 AVC compression format.")

    add_urls("http://git.videolan.org/git/x264.git")

    add_versions("v2018.09.25", "545de2ffec6ae9a80738de1b2c8cf820249a2530")

    add_deps("nasm")

    add_syslinks("pthread", "dl")

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package, {"--disable-lsmash", "--enable-static", "--enable-strip"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x264_encoder_open", {includes = {"stdint.h", "x264.h"}}))
    end)
