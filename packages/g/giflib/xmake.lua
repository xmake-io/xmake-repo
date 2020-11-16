package("giflib")

    set_homepage("https://sourceforge.net/projects/giflib/")
    set_description("A library for reading and writing gif images.")

    add_urls("https://jaist.dl.sourceforge.net/project/giflib/giflib-$(version).tar.gz")
    add_versions("5.2.1", "31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd")

    add_configs("utils", {description = "Build utility binaries.", default = true, type = "boolean"})

    if is_plat("windows") then
        add_deps("cgetopt")
    end

    on_install("linux", "macosx", "windows", "mingw", "android", "iphoneos", function (package)
        local lib_sources = {"dgif_lib.c", "egif_lib.c", "gifalloc.c", "gif_err.c", "gif_font.c", "gif_hash.c", "openbsd-reallocarray.c"}
        if package:is_plat("windows") then
            io.gsub("gif_hash.h", "\n#include <unistd.h>\n", [[
                #ifndef _MSC_VER
                #include <unistd.h>
                #endif
            ]])
            io.gsub("gif_font.c", "\n#include \"gif_lib.h\"\n", "\n#include \"gif_lib.h\"\n#define strtok_r strtok_s\n")
        end
        local xmake_lua = string.format([[
            add_rules("mode.debug", "mode.release")
            if is_plat("windows") then
                add_requires("cgetopt")
            end
            target("gif")
                set_kind("%s")
                add_files("%s")
                add_headerfiles("gif_lib.h")
        ]], (package:config("shared") and "shared" or "static"), table.concat(lib_sources, "\", \""))
        if package:config("utils") then
            local util_table = {"gif2rgb", "gifbuild", "gifclrmp", "giffix", "giftext", "giftool"}
            for _, util in ipairs(util_table) do
                xmake_lua = xmake_lua .. string.format([[
                    target("%s")
                        set_kind("binary")
                        if is_plat("windows") then
                            add_packages("cgetopt")
                        end
                        add_files("%s.c", "getarg.c", "qprintf.c", "quantize.c", "%s")
                ]], util, util, table.concat(lib_sources, "\", \""))
            end
        end
        io.writefile("xmake.lua", xmake_lua)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("GifMakeMapObject", {includes = "gif_lib.h"}))
    end)
