package("streamvbyte")
    set_homepage("https://github.com/lemire/streamvbyte")
    set_description("Fast integer compression in C using the StreamVByte codec")
    set_license("Apache-2.0")

    add_urls("https://github.com/lemire/streamvbyte/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lemire/streamvbyte.git")

    add_versions("v1.0.0", "6b1920e9865146ba444cc317aa61cd39cdf760236e354ef7956011a9fe577882")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DSTREAMVBYTE_ENABLE_EXAMPLES=OFF", "-DSTREAMVBYTE_ENABLE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSTREAMVBYTE_SANITIZE=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("streamvbyte_encode", {includes = "streamvbyte.h"}))
    end)
