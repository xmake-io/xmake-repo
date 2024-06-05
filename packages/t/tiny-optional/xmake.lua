package("tiny-optional")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Sedeniono/tiny-optional")
    set_description("Replacement for std::optional that does not unnecessarily waste memory")
    set_license("BSL-1.0")

    add_urls("https://github.com/Sedeniono/tiny-optional/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Sedeniono/tiny-optional.git")

    add_versions("v1.2.1", "0305d31c43ef8365befd7d022c13c431b913036d4c10c0c5419e9765077c5122")
    add_versions("v1.2.0", "d4ce47d0c9c4f89ab41e4e0b96d25bfb98c0cc02da3d7b312337e5e4e6e1c9e8")

    on_install("windows|!arm*", "linux|!arm*", "macosx|!arm*", "bsd|!arm*", "mingw|!arm*", "msys|!arm*", "android|!arm*", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("tiny::optional<int>", {configs = {languages = "c++17"}, includes = "tiny/optional.h"}))
    end)
