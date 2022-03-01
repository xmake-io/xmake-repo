package("utf8proc")

    set_homepage("https://juliastrings.github.io/utf8proc/")
    set_description("A clean C library for processing UTF-8 Unicode data")
    set_license("MIT")

    add_urls("https://github.com/JuliaStrings/utf8proc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/JuliaStrings/utf8proc.git")
    add_versions('v2.7.0', '4bb121e297293c0fd55f08f83afab6d35d48f0af4ecc07523ad8ec99aa2b12a1')

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DUTF8PROC_ENABLE_TESTING=OFF",
        }
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("utf8proc_encode_char", {includes = "utf8proc.h"}))
    end)
