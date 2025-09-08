package("libbacktrace")
    set_homepage("https://github.com/ianlancetaylor/libbacktrace")
    set_description("A C library that may be linked into a C/C++ program to produce symbolic backtraces")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ianlancetaylor/libbacktrace.git")
    add_versions("2025.04.10", "793921876c981ce49759114d7bb89bb89b2d3a2d")

    add_configs("bitswidth", {default = "64", type = "string", values = {"64", "32"}})

    add_deps("xz", "zlib", "zstd")
    if is_plat("windows") then
        add_deps("unistd_h")
    end

    on_check("cross", function (package)
        if not package:is_arch64() then
            assert(false, "package(libbacktrace): Unsupported on non-arch64 cross.")
        end
    end)

    on_install(function (package)
        if package:is_plat("windows") then
            local internal_h_content = io.readfile("internal.h")
            io.writefile("internal.h", internal_h_content .. [[
    #if !defined(_SSIZE_T_) && !defined(_SSIZE_T_DEFINED)
    # ifndef ssize_t
    typedef intptr_t ssize_t;
    # endif
    # define SSIZE_MAX INTPTR_MAX
    # define _SSIZE_T_
    # define _SSIZE_T_DEFINED
    #endif]])
        end
        local configs = {bitswidth = package:is_arch64() and "64" or "32"}
        io.gsub("config.h.in", "# *undef (.-)\n", "${define %1}\n")
        io.gsub("backtrace-supported.h.in", "# *define (.-)\n", "${define %1}\n")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("backtrace_create_state", {includes = "backtrace.h"}))
        assert(package:has_cfuncs("backtrace_full", {includes = "backtrace.h"}))
    end)
