package("lz4")

    set_homepage("https://www.lz4.org/")
    set_description("LZ4 - Extremely fast compression")

    set_urls("https://github.com/lz4/lz4/archive/$(version).tar.gz",
             "https://github.com/lz4/lz4.git")
    add_versions("v1.9.4", "0b0e3aa07c8c063ddf40b082bdf7e37a1562bda40a0ff5272957f3e987e0e54b")
    add_versions("v1.9.3", "030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1")

    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "LZ4_DLL_IMPORT")
        end
    end)

    if is_plat("macosx") then
        add_extsources("brew::lz4")
    elseif is_plat("linux") then
        add_extsources("pacman::lz4")
    end

    on_install(function (package)
        io.writefile("xmake.lua", ([[
            set_version("%s")
            add_rules("mode.debug", "mode.release")
            target("lz4")
                set_kind("$(kind)")
                add_rules("utils.install.pkgconfig_importfiles", {filename = "liblz4.pc"})
                add_files("lib/*.c")
                add_headerfiles("lib/lz4.h", "lib/lz4hc.h", "lib/lz4frame.h")
                add_defines("XXH_NAMESPACE=LZ4_")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("LZ4_DLL_EXPORT")
                end
                if is_kind("static") then
                    add_defines("LZ4_HC_STATIC_LINKING_ONLY", "LZ4_STATIC_LINKING_ONLY")
                end
        ]]):format(package:version_str()))
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
