package("mman_win32")
    set_homepage("https://github.com/alitrack/mman-win32")
    set_description("mman library for Windows. mirror of https://code.google.com/p/mman-win32/")

    add_urls("https://github.com/alitrack/mman-win32.git")
    add_versions("2019.10.11", "2d1c576e62b99e85d99407e1a88794c6e44c3310")

    add_deps("cmake")

    on_install("windows", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mmap", {includes = "sys/mman.h"}))
    end)
