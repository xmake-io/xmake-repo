package("kvazaar")
    set_homepage("https://github.com/ultravideo/kvazaar")
    set_description("An open-source HEVC encoder")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ultravideo/kvazaar/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ultravideo/kvazaar.git")

    add_versions("v2.3.2", "ddd0038696631ca5368d8e40efee36d2bbb805854b9b1dda8b12ea9b397ea951")
    add_versions("v2.3.1", "c5a1699d0bd50bc6bdba485b3438a5681a43d7b2c4fd6311a144740bfa59c9cc")

    add_configs("cryptopp", {description = "Use crypto library", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("cryptopp") then
            package:add("deps", "cryptopp")
        end
        if not package:config("shared") then
            package:add("defines", "KVZ_STATIC_LIB")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_CRYPTO=" .. (package:config("cryptopp") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kvz_api_get", {includes = "kvazaar.h"}))
    end)
