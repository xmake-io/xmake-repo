package("bzip3")
    set_homepage("https://github.com/kspalaiologos/bzip3")
    set_description("A better and stronger spiritual successor to BZip2.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/kspalaiologos/bzip3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kspalaiologos/bzip3.git")

    add_versions("1.4.0", "d70334c19c7cce2cc6c823566b7d8968ff08a52043d518f55caebd2e407b2233")

    add_configs("native", {description = "Enable CPU-specific optimizations", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBZIP3_BUILD_APPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBZIP3_ENABLE_ARCH_NATIVE=" .. (package:config("native") and "ON" or "OFF"))
        table.insert(configs, "-DBZIP3_ENABLE_PTHREAD=" .. (package:is_plat("linux", "bsd") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bz3_compress", {includes = "libbz3.h"}))
    end)
