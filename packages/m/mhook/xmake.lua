package("mhook")
    set_homepage("https://github.com/martona/mhook")
    set_description("A Windows API hooking library ")
    set_license("MIT")

    set_urls("https://github.com/apriorit/mhook.git")

    add_versions("2022.04.12", "93ce2fcc6f91c9ee696a04fc07798e7cb13a6070")

    on_install("windows|!arm*", "mingw|!arm*", "msys", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("mhook")
                set_kind("$(kind)")
                add_files("disasm-lib/*.c", "mhook-lib/*.c")
                add_headerfiles("(mhook-lib/*.h)")
                add_defines("NO_SANITY_CHECKS", "UNICODE", "_UNICODE", "WIN32_LEAN_AND_MEAN")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("Mhook_SetHookEx", {includes = {"windows.h", "mhook-lib/mhook.h"}}))
    end)
