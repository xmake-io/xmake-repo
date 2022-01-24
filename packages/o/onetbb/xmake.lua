package("onetbb")
    set_homepage("https://oneapi-src.github.io/oneTBB/")
    set_description("oneAPI Threading Building Blocks (oneTBB)")
    set_license("Apache-2.0")

    add_urls("https://github.com/oneapi-src/oneTBB/archive/refs/tags/$(version).tar.gz",
             "https://github.com/oneapi-src/oneTBB.git")
    add_versions("v2021.5.0", "e5b57537c741400cf6134b428fc1689a649d7d38d9bb9c1b6d64f092ea28178a")

    add_deps("cmake")

    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("tbb::blocked_range<int>", {configs = {languages = "c++14"}, includes = "oneapi/tbb.h"}))
    end)
