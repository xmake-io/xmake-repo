package("jansson")

    set_homepage("https://github.com/akheron/jansson")
    set_description("C library for encoding, decoding and manipulating JSON data")
    set_license("MIT")

    add_urls("https://github.com/akheron/jansson/releases/download/v$(version)/jansson-$(version).tar.gz")
    add_versions("2.14", "5798d010e41cf8d76b66236cfb2f2543c8d082181d16bc3085ab49538d4b9929")

    add_deps("cmake")
    on_install("windows", "macosx", "linux", "mingw", function (package)
        local configs = {"-DJANSSON_EXAMPLES=OFF", "-DJANSSON_BUILD_DOCS=OFF", "-DJANSSON_WITHOUT_TESTS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DJANSSON_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DJANSSON_STATIC_CRT=" .. ((package:config("runtimes") and package:has_runtime("MT", "MTd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MT")) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("json_loads", {includes = "jansson.h"}))
    end)
