package("oniguruma")
    set_homepage("https://github.com/kkos/oniguruma")
    set_description("regular expression library")
    set_license("BSD")

    add_urls("https://github.com/kkos/oniguruma/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kkos/oniguruma.git")

    add_versions("v6.9.10", "ad92309d0d13eebc27f6592e875f3efbfa3dda2bf6da5952e00f0a2120c921a8")
    add_versions("v6.9.9", "001aa1202e78448f4c0bf1a48c76e556876b36f16d92ce3207eccfd61d99f2a0")

    add_configs("posix", {description = "Include POSIX API", default = false, type = "boolean"})
    add_configs("compatible_posix", {description = "Include Binary compatible POSIX API", default = false, type = "boolean"})
    add_configs("statistics", {description = "Include statistics API", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DINSTALL_DOCUMENTATION=OFF", "-DBUILD_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if not package:config("shared") then
                package:add("defines", "ONIG_STATIC")
            end
        end
        table.insert(configs, "-DENABLE_POSIX_API=" .. (package:config("posix") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_BINARY_COMPATIBLE_POSIX_API=" .. (package:config("compatible_posix") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATISTICS=" .. (package:config("statistics") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("onig_new", {includes = "oniguruma.h"}))
    end)
