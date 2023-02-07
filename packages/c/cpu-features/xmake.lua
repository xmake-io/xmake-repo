package("cpu-features")

    set_homepage("https://github.com/google/cpu_features")
    set_description("A cross platform C99 library to get cpu features at runtime.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/cpu_features/archive/$(version).tar.gz",
             "https://github.com/google/cpu_features.git")
    add_versions("v0.6.0", "95a1cf6f24948031df114798a97eea2a71143bd38a4d07d9a758dda3924c1932")
    add_versions("v0.7.0", "df80d9439abf741c7d2fdcdfd2d26528b136e6c52976be8bd0cd5e45a27262c0")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "android", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("linux") then
            table.insert(configs, "-DBUILD_PIC=ON")
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("list_cpu_features")
        end
        assert(package:has_ctypes("CacheLevelInfo", {includes = "cpu_features/cpu_features_cache_info.h"}))
    end)
