package("rewolf-wow64ext")
    set_homepage("https://github.com/rwfpl/rewolf-wow64ext")
    set_description("Helper library for x86 programs that runs under WOW64 layer on x64 versions of Microsoft Windows operating systems.")
    set_license("LGPL-3.0-or-later")

    add_urls("https://github.com/rwfpl/rewolf-wow64ext/archive/refs/tags/$(version).tar.gz", {
        alias = "tag", version = function (version)
            return version:gsub("+", ".")
        end
    })
    add_urls("https://github.com/rwfpl/rewolf-wow64ext.git", {alias = "git"})
    
    add_versions("tag:v1.0.0+9", "d74cd5353ec4f565c61302cf667f4319d2efb554a76cf83b216f8a8a32c058f6")
    add_versions("git:2022.09.26", "82045488f48c8641609d9a5d8bb832937b9b5acd")

    add_patches("v1.0.0+9", "patches/v1.0.0+9/fix-mingw.patch", "d6cc4844ff4607ab450bc594792dd07594de1ecd9961e3f551350cb41ea8c23f")
    add_patches("2022.09.26", "patches/2022.09.26/fix-mingw.patch", "7920999af8511066db3a5a2641e074f7d2bc81caf4f3fc31f370fb2843ac9be0")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "WOW64EXT_STATIC")
        end
    end)

    if on_check then
        on_check(function (package)
            if package:check_sizeof("void*") == "8" then
                raise("package(rewolf-wow64ext): Windows OS supports only 32-bit, it does not unsupport 64-bit.")
            end
        end)
    end

    on_install("windows", "mingw", function (package)
        io.replace("src/wow64ext.cpp", [[#include <Windows.h>]], [[#include <windows.h>]], {plain = true})
        -- Avoid colliding with the Windows SDK's non-template _CLIENT_ID.
        io.replace("src/wow64ext.h", "_CLIENT_ID", "_WOW64EXT_CLIENT_ID", {plain = true})
        if not package:config("shared") then
            -- A static library uses the consumer's CRT and has no DllMain.
            io.replace("src/wow64ext.cpp", "#include <cstddef>",
                       "#include <cstddef>\n#include <cstdlib>\n#include <winternl.h>", {plain = true})
            io.gsub("src/wow64ext.cpp", "HANDLE g_heap;.-#pragma warning%(push%)", [[
                BOOL g_isWow64 = [] {
                    BOOL result = FALSE;
                    IsWow64Process(GetCurrentProcess(), &result);
                    return result;
                }();
                #pragma warning(push)]])
            io.replace("src/wow64ext.cpp", "__declspec(dllexport)", "", {plain = true})
            io.replace("src/wow64ext.h", "__declspec(SPEC)", "WOW64EXT_API ", {plain = true})
            io.replace("src/wow64ext.h", "extern \"C\"", [[
                #ifdef WOW64EXT_STATIC
                #define WOW64EXT_API
                #else
                #define WOW64EXT_API __declspec(SPEC)
                #endif
                extern "C"]], {plain = true})
        end
        if package:config("shared") then
            local rc_str = io.readfile("src/wow64ext.rc", {encoding = "utf16le"})
            rc_str = rc_str:gsub("afxres.h", "winres.h")
            io.writefile("src/wow64ext.rc", rc_str, {encoding = "utf8"})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("rewolf-wow64ext")
                set_kind("$(kind)")
                set_languages("c++11")

                add_defines("WOW64EXT_EXPORTS")
                if is_kind("static") then
                    add_defines("WOW64EXT_STATIC")
                end

                add_files("src/wow64ext.cpp")
                if is_kind("shared") then
                    add_files("src/wow64ext.rc")
                end

                add_headerfiles("src/(*.h)")

                add_includedirs("src")

                if is_plat("mingw") then
                    add_shflags("-mwindows")
                    add_asflags("-masm=intel")
                elseif is_plat("windows") then
                    add_shflags("/subsystem:windows")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto handle = GetModuleHandle64(L"user32.dll");
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"windows.h", "winternl.h", "wow64ext.h"}}))
    end)
