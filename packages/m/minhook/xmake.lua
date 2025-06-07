package("minhook")

    set_homepage("https://github.com/TsudaKageyu/minhook")
    set_description("The Minimalistic x86/x64 API Hooking Library for Windows.")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/TsudaKageyu/minhook/archive/$(version).tar.gz",
             "https://github.com/TsudaKageyu/minhook.git")

    add_versions("v1.3.4", "1aebeae4ca898330c507860acc2fca2eb335fe446a3a2b8444c3bf8b2660a14e")
    add_versions("v1.3.3", "5bec16358ec9086d4593124bf558635e89135abea2c76e5761ecaf09f4546b19")

    on_install("windows|!arm*", "mingw|!arm*", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("minhook")
                set_kind("$(kind)")
                add_includedirs("src/", "src/hde/")
                add_files("src/*.c", is_arch("x64", "x86_64") and "src/hde/hde64.c" or "src/hde/hde32.c")
                if is_kind("shared") then
                    add_files("dll_resources/MinHook.rc")
                    if is_plat("windows") then
                        add_shflags("/def:dll_resources/MinHook.def")
                    end
                end
                add_headerfiles("include/MinHook.h")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MH_Initialize", {includes = "MinHook.h"}))
    end)
