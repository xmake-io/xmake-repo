package("libbacktrace")

    set_homepage("https://github.com/ianlancetaylor/libbacktrace")
    set_description("A C library that may be linked into a C/C++ program to produce symbolic backtraces")

    add_urls("https://github.com/ianlancetaylor/libbacktrace.git")
    add_versions("v1.0", "d0f5e95a87a4d3e0a1ed6c069b5dae7cbab3ed2a")

    on_install("linux", "macosx", function (package)
        local configs = {}
        local cxflags = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(cxflags, "-fPIC")
        end
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("backtrace_create_state", {includes = "backtrace.h"}))
        assert(package:has_cfuncs("backtrace_full", {includes = "backtrace.h"}))
    end)
