package("binn")
    set_homepage("https://github.com/liteserver/binn")
    set_description("Binary Serialization")
    set_license("Apache-2.0")

    add_urls("https://github.com/liteserver/binn/archive/refs/tags/$(version).tar.gz",
             "https://github.com/liteserver/binn.git")

    add_versions("v3.0", "cc5cc8a178484de8d46983cc459ab8ae7ec1227f05ec7bf527e4b9067c54a237")

    on_install(function(package)
        local f = io.readfile("src/binn.h")
        if package:is_plat("linux", "cross") then
            io.writefile("src/binn.h", [[#include <endian.h>
            #define 	LITTLE_ENDIAN __LITTLE_ENDIAN
            #define 	BIG_ENDIAN __BIG_ENDIAN
            #define 	BYTE_ORDER __BYTE_ORDER
            #define     _POSIX_C_SOURCE 200809L
            #include <strings.h>
            #include <string.h>
            #include <stddef.h>
            ]] .. f)
        elseif package:is_plat("wasm") then
            io.writefile("src/binn.h", [[#define     _POSIX_C_SOURCE 200809L
            #include <strings.h>
            #include <string.h>
            #include <stddef.h>
            ]] .. f)
        else
            io.writefile("src/binn.h", [[#include <stddef.h>
            ]] .. f)
        end
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            target("binn")
                set_version("%s.%s", {soname = true})
                set_languages("c11")
                set_kind("$(kind)")
                if is_plat("linux", "cross", "wasm") then
                    add_defines("_POSIX_C_SOURCE=200809L")
                end
                if is_plat("windows") then
                    if is_kind("shared") then
                        add_files("src/win32/dllmain.c", "src/win32/binn.def")
                    end
                end
                add_files("src/binn.c")
                add_headerfiles("src/(*.h)")
        ]]):format(package:version():major(), package:version():minor()))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <binn.h>
            void test() {
                binn* parent;
                int count = binn_count(parent);
            }
        ]]}, {configs = {languages = "c11"}}))
    end)
