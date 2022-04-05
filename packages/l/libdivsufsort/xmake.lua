package("libdivsufsort")

    set_homepage("https://android.googlesource.com/platform/external/libdivsufsort/")
    set_description("A lightweight suffix array sorting library")

    add_urls("https://android.googlesource.com/platform/external/libdivsufsort.git")

    add_versions("2021.2.18", "d6031097d39aabfff1372e9a1601eed3fbd5fd9b")

    if is_plat("linux") then
        add_extsources("apt::libdivsufsort-dev", "paru::libdivsufsort")
    end
    add_deps("cmake")
    add_configs("use_64", {description = "Build 64bit suffxi array sorting APIs", default = false, type = "boolean"})

    on_install(function (package)
        import("package.tools.cmake")
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=on")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=off")
        end
        if package:config("use_64") then
            table.insert(configs, "-DBUILD_DIVSUFSORT64=on")
        end
        cmake.install(package, configs)
    end)

    on_test(function (package)
        if package:config("use_64") then
            assert(package:has_cfuncs("sa_search64", {includes = "divsufsort64.h"}))
        else
            assert(package:has_cfuncs("sa_search", {includes = "divsufsort.h"}))
        end
    end)
