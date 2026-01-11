package("girlhook")
    set_homepage("https://github.com/Lynnette177/GirlHook")
    set_description("GirlHook is a Lua-scriptable ART hook framework designed for dynamic method interception.")

    add_urls("https://github.com/Lynnette177/GirlHook/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Lynnette177/GirlHook.git")

    add_versions("1.0.4", "5307b0eae1ba6724d69546d5c4f4ae1e2391656d849a609c79fadd24ce21a600")

    add_deps("elfio", "sol2", "lua")

    if on_check then
        on_check(function (package)
            assert(package:check_sizeof("void*") == "8", "package(girlhook): only supports 64 bit.")
        end)
    end

    on_install("android", function (package)
        io.replace("app/src/main/cpp/JVM/JVM.h", [[#include "../include/ELFIO/elfio/elfio.hpp"]], [[#include <elfio/elfio.hpp>]], {plain = true})
        os.rmdir(
            "app/src/main/cpp/include/ELFIO",
            "app/src/main/cpp/include/sol2",
            "app/src/main/cpp/lua")
        os.cd("app/src/main/cpp")
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c++17")

            add_requires("elfio", "sol2", "lua")
            add_packages("elfio", "sol2", "lua")

            target("girlhook")
                set_kind("$(kind)")
                add_files(
                    "GirlHook.cpp",
                    "JVM/JVM.cpp",
                    "Hook/Hook.cpp",
                    "test/test.cpp",
                    "Caller/Caller.cpp",
                    "Utility/FindClass.cpp",
                    "Utility/GirlLog.cpp",
                    "Bridge/bridge.cpp",
                    "Bridge/WrappedC_LuaFunction.cpp",
                    "Communicate/Communicate.cpp",
                    "Commands/Commands.cpp")
                add_headerfiles("(**.h)", {prefixdir = "GirlHook"})
                add_syslinks("android", "log")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                unhook_all();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "GirlHook/Hook/Hook.h"}))
    end)
