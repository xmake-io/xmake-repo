package("lz4")

    set_homepage("https://www.lz4.org/")
    set_description("LZ4 - Extremely fast compression")

    set_urls("https://github.com/lz4/lz4/archive/$(version).tar.gz",
             "https://github.com/lz4/lz4.git")
    add_versions("v1.9.3", "030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lz4")
                set_kind("$(kind)")
                add_files("lib/*.c")
                add_headerfiles("lib/lz4.h")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("LZ4_DLL_EXPORT")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("LZ4_compress_default", {includes = {"lz4.h"}}))
    end)
