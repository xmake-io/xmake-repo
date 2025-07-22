package("tinyjpeg")
    set_kind("libary", {headeronly = true})
    set_homepage("https://github.com/serge-rgb/TinyJPEG")
    set_description("Single header lib for JPEG encoding. Public domain. C99. stb style.")

    add_urls("https://github.com/serge-rgb/TinyJPEG.git")
    add_versions("2022.08.20", "e978b746714abad76e0f00264d2a154b52de8fc1")

    on_install(function (package)
        os.cp("tiny_jpeg.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tje_encode_to_file", {includes = "tiny_jpeg.h"}))
    end)
