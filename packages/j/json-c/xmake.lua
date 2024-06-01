package("json-c")
    set_homepage("https://github.com/json-c/json-c/wiki")
    set_description("JSON parser for C")
    set_license("MIT")

    set_urls("https://github.com/json-c/json-c/archive/refs/tags/json-c-$(version).zip")

    add_versions("0.17-20230812", "471e9eb1dad4fd2e4fec571d8415993e66a89f23a5b052f1ba11b54db90252de")

    add_deps("cmake")
    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_APPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
            table.insert(configs, "-DDISABLE_STATIC_FPIC=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("json_object_new_object", {includes = "json-c/json.h"}))
    end)
