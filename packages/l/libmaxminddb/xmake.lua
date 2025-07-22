package("libmaxminddb")
    set_homepage("https://maxmind.github.io/libmaxminddb/")
    set_description("C library for the MaxMind DB file format")
    set_license("Apache-2.0")

    add_urls("https://github.com/maxmind/libmaxminddb/releases/download/$(version)/libmaxminddb-$(version).tar.gz",
             "https://github.com/maxmind/libmaxminddb.git")

    add_versions("1.12.2", "1bfbf8efba3ed6462e04e225906ad5ce5fe958aa3d626a1235b2a2253d600743")
    add_versions("1.11.0", "b2eea79a96fed77ad4d6c39ec34fed83d45fcb75a31c58956813d58dcf30b19f")
    add_versions("1.10.0", "5e6db72df423ae225bfe8897069f6def40faa8931f456b99d79b8b4d664c6671")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

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
        table.insert(configs, "-DMAXMINDDB_BUILD_BINARIES=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MMDB_open", {includes = "maxminddb.h"}))
    end)
