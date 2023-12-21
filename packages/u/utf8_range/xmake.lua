package("utf8_range")
    set_homepage("https://github.com/protocolbuffers/utf8_range")
    set_description("Utf8 range")
    set_license("MIT")

    add_urls("https://github.com/protocolbuffers/utf8_range.git")
    add_versions("2022.11.15", "72c943dea2b9240cd09efde15191e144bc7c7d38")

    add_deps("cmake", "abseil")

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-Dutf8_range_ENABLE_TESTS=OFF", "-DCMAKE_CXX_STANDARD=11"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("utf8_range2", {includes = "utf8_range.h"}))
    end)
