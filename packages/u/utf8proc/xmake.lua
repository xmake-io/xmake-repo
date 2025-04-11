package("utf8proc")

    set_homepage("https://juliastrings.github.io/utf8proc/")
    set_description("A clean C library for processing UTF-8 Unicode data")
    set_license("MIT")

    add_urls("https://github.com/JuliaStrings/utf8proc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/JuliaStrings/utf8proc.git")
    add_versions("v2.10.0", "6f4f1b639daa6dca9f80bc5db1233e9cbaa31a67790887106160b33ef743f136")
    add_versions("v2.9.0", "18c1626e9fc5a2e192311e36b3010bfc698078f692888940f1fa150547abb0c1")
    add_versions("v2.7.0", "4bb121e297293c0fd55f08f83afab6d35d48f0af4ecc07523ad8ec99aa2b12a1")
    add_versions("v2.8.0", "a0a60a79fe6f6d54e7d411facbfcc867a6e198608f2cd992490e46f04b1bcecc")

    add_deps("cmake")
    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "UTF8PROC_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {"-DUTF8PROC_ENABLE_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("utf8proc_encode_char", {includes = "utf8proc.h"}))
    end)
