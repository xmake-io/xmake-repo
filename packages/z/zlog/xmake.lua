package("zlog")
    set_homepage("https://github.com/HardySimpson/zlog")
    set_description("A reliable, high-performance, thread safe, flexsible, clear-model, pure C logging library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/HardySimpson/zlog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/HardySimpson/zlog.git")

    add_versions("1.2.18", "3977dc8ea0069139816ec4025b320d9a7fc2035398775ea91429e83cb0d1ce4e")
    add_versions("1.2.17", "7fe412130abbb75a0779df89ae407db5d8f594435cc4ff6b068d924e13fd5c68")

    add_patches("1.2.17", "patches/1.2.17/cmake.patch", "0558364a4a4a2d54375fffb1ae33877562058d90865712bb7519c9219b0f79e7")

    add_syslinks("pthread")

    add_deps("cmake")

    on_install("linux", "macosx", "cross", "iphoneos", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zlog_init", {includes = "zlog.h"}))
    end)
