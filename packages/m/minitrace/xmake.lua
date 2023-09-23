package("minitrace")
    set_homepage("https://github.com/hrydgard/minitrace")
    set_description("Simple C/C++ library for producing JSON traces suitable for Chrome's built-in trace viewer (about:tracing).")
    set_license("MIT")

    add_urls("https://github.com/hrydgard/minitrace.git")
    add_versions("2023.09.04", "bc377c921f8c7da38f2beab355245222a01efc1a")

    add_configs("mtr", {description = "Enable minitrace", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMTR_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMTR_ENABLED=" .. (package:config("mtr") and "ON" or "OFF"))
        if package:config("mtr") then
            package:add("defines", "MTR_ENABLED")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mtr_init", {includes = "minitrace.h"}))
    end)
