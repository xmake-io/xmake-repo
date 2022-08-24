package("cjson")

    set_homepage("https://github.com/DaveGamble/cJSON")
    set_description("Ultralightweight JSON parser in ANSI C.")
    set_license("MIT")

    set_urls("https://github.com/DaveGamble/cJSON/archive/v$(version).zip",
             "https://github.com/DaveGamble/cJSON.git")
    add_versions("1.7.10", "80a0584410656c8d8da2ba703744f44d7535fc4f0778d8bf4f980ce77c6a9f65")
    add_versions("1.7.14", "d797b4440c91a19fa9c721d1f8bab21078624aa9555fc64c5c82e24aa2a08221")
    add_versions("1.7.15", "c55519316d940757ef93a779f1db1ca809dbf979c551861f339d35aaea1c907c")

    add_deps("cmake")

    on_install("windows", "macosx", "linux", "iphoneos", "android", "mingw", function (package)
        local configs = {"-DENABLE_CJSON_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cJSON_malloc", {includes = "cjson/cJSON.h"}))
    end)
