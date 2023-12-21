package("microsoft-detours")

    set_homepage("https://github.com/microsoft/Detours")
    set_description("Detours is a software package for monitoring and instrumenting API calls on Windows. It is distributed in source code form.")
    set_license("MIT")

    set_urls("https://github.com/microsoft/Detours.git")
    add_versions("2023.6.8", "734ac64899c44933151c1335f6ef54a590219221")

    on_install("windows", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("microsoft-detours")
                set_kind("$(kind)")
                add_files("src/*.cpp|uimports.cpp")
                add_headerfiles("src/*.h")
                add_defines("WIN32_LEAN_AND_MEAN")
                if is_mode("debug") then
                    add_defines("DETOUR_DEBUG=1")
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        if package:is_debug() then
            package:add("defines", "DETOUR_DEBUG=1")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <windows.h>
            #include <detours.h>
            void test() {
                DetourIsHelperProcess();
            }
        ]]}))
    end)
