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

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if on_check then
        on_check(function (package)
            if package:check_sizeof("void*") == "8" then
                raise("package(rewolf-wow64ext): Windows OS supports only 32-bit, it does not unsupport 64-bit.")
            end
        end)
    end

    on_install("windows", "mingw", function (package)
        io.replace("src/wow64ext.cpp", [[#include <Windows.h>]], [[#include <windows.h>]], {plain = true})
        if package:is_plat("mingw") then
            local rc_str = io.readfile("src/wow64ext.rc", {encoding = "utf16le"})
            io.writefile("src/wow64ext.rc", rc_str, {encoding = "utf8"})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("rewolf-wow64ext")
                set_kind("$(kind)")
                set_languages("c++11")

                add_defines("WOW64EXT_EXPORTS")

                add_files("src/wow64ext.cpp")
                add_files("src/wow64ext.rc")

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
        ]]}, {configs = {languages = "c++11"}, includes = "wow64ext.h"}))
    end)
