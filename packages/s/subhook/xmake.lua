package("subhook")
    set_homepage("https://github.com/Dasharo/subhook")
    set_description("Simple hooking library for C/C++ (x86 only, 32/64-bit, no dependencies). Re-upload of Zeex/subhook.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Dasharo/subhook.git",
             "https://github.com/xmake-mirror/subhook.git")
    add_versions("2023.02.10", "e935959d2f9cc642bcbb5e7759b2b1e7196b0947")

    on_install("windows|!arm64", "linux|x86_64", "macosx|x86_64", "bsd", "mingw", "msys", function (package)
        if (not package:config("shared")) and package:is_plat("windows", "mingw") then
            package:add("defines", "SUBHOOK_STATIC")
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("subhook")
                set_kind("$(kind)")
                add_files("subhook.c")
                add_headerfiles("subhook.h")
                if is_kind("static") then
                    if is_plat("windows", "mingw") then
                        add_defines("SUBHOOK_STATIC")
                    end
                else
                    add_defines("SUBHOOK_IMPLEMENTATION")
                end
        ]])
        import("package.tools.xmake").install(package)
        wprint("The original repository Zeex/subhook is no longer public. You are using a mirror of this repository.")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("subhook_new", {includes = "subhook.h"}))
    end)
