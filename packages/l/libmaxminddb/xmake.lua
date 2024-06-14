package("libmaxminddb")
    set_homepage("https://maxmind.github.io/libmaxminddb/")
    set_description("C library for the MaxMind DB file format")
    set_license("Apache-2.0")

    add_urls("https://github.com/maxmind/libmaxminddb/releases/download/$(version)/libmaxminddb-$(version).tar.gz",
             "https://github.com/maxmind/libmaxminddb.git")

    add_versions("1.9.1", "a80682a89d915fdf60b35d316232fb04ebf36fff27fda9bd39fe8a38d3cd3f12")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_STATIC_RUNTIME=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MMDB_open", {includes = "maxminddb.h"}))
    end)
