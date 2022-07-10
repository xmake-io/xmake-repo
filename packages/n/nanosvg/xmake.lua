package("nanosvg")
    set_homepage("https://github.com/memononen/nanosvg")
    set_description("Simple stupid SVG parser")
    set_license("zlib")

    add_urls("https://github.com/memononen/nanosvg.git")
    add_versions("2022.07.09", "7e37e00ef4c46c122e2948c5dd6d162271dc4f0c")

    add_deps("cmake")

    add_includedirs("include", "include/nanosvg")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nsvgParseFromFile", {includes = "nanosvg.h"}))
    end)
