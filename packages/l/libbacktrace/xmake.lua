package("libbacktrace")
    set_homepage("https://github.com/ianlancetaylor/libbacktrace")
    set_description("A C library that may be linked into a C/C++ program to produce symbolic backtraces")

    add_urls("https://github.com/ianlancetaylor/libbacktrace.git")
    add_versions("2025.04.10", "793921876c981ce49759114d7bb89bb89b2d3a2d")

    add_deps("autotools")

    on_install("!windows", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("backtrace_create_state", {includes = "backtrace.h"}))
        assert(package:has_cfuncs("backtrace_full", {includes = "backtrace.h"}))
    end)
