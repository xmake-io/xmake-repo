package("jansson")
    set_homepage("https://github.com/akheron/jansson")
    set_description("C library for encoding, decoding and manipulating JSON data")
    set_license("MIT")

    add_urls("https://github.com/akheron/jansson/releases/download/v$(version)/jansson-$(version).tar.gz",
             "https://github.com/akheron/jansson.git")

    add_versions("2.15.0", "070a629590723228dc3b744ae90e965a569efb9c535b3309b52e80e75d8eb3be")
    add_versions("2.14.1", "2521cd51a9641d7a4e457f7215a4cd5bb176f690bc11715ddeec483e85d9e2b3")
    add_versions("2.14", "5798d010e41cf8d76b66236cfb2f2543c8d082181d16bc3085ab49538d4b9929")

    on_load(function (package)
        if package:is_plat("linux") and package:config("shared") then
            package:add("deps", "autotools")
        else
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:is_plat("linux") and package:config("shared") then
            local configs = {}
            table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            import("package.tools.autoconf").install(package, configs)
        else
            local configs = {
                "-DJANSSON_EXAMPLES=OFF",
                "-DJANSSON_BUILD_DOCS=OFF",
                "-DJANSSON_WITHOUT_TESTS=ON",
                "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            }
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DJANSSON_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:is_plat("windows") then
                table.insert(configs, "-DJANSSON_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            end
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("json_loads", {includes = "jansson.h"}))
    end)
