package("hyperscan")
    set_homepage("https://www.hyperscan.io")
    set_description("High-performance regular expression matching library")
    set_license("BSD-3")

    add_urls("https://github.com/intel/hyperscan/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/hyperscan.git")
    add_versions("v5.4.2", "32b0f24b3113bbc46b6bfaa05cf7cf45840b6b59333d078cc1f624e4c40b2b99")

    add_deps("cmake", "boost", "ragel", "python")

    on_install("linux", "windows|!arm*", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("hs_compile", {includes = "hs/hs.h"}))
    end)
