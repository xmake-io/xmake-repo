package("xz")

    set_homepage("https://tukaani.org/xz/")
    set_description("General-purpose data compression with high compression ratio.")

    set_urls("https://downloads.sourceforge.net/project/lzmautils/xz-$(version).tar.gz",
             "https://tukaani.org/xz/xz-$(version).tar.gz")
    add_versions("5.2.5", "f6f4910fd033078738bd82bfba4f49219d03b17eb0794eb91efbae419f4aba10")
    add_versions("5.2.10", "eb7a3b2623c9d0135da70ca12808a214be9c019132baaa61c9e1d198d1d9ded3")
    add_versions("5.4.1", "e4b0f81582efa155ccf27bb88275254a429d44968e488fc94b806f2a61cd3e22")

    on_load(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "LZMA_API_STATIC")
        end
    end)

    on_install("windows", "mingw@windows", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("lzma")
                set_kind("$(kind)")
                add_defines("HAVE_CONFIG_H")
                add_includedirs("src/common",
                                "src/liblzma/common",
                                "src/liblzma/api",
                                "src/liblzma/check",
                                "src/liblzma/delta",
                                "src/liblzma/lz",
                                "src/liblzma/lzma",
                                "src/liblzma/rangecoder",
                                "src/liblzma/simple",
                                --2013/2017/2019 config.h is the same
                                "windows/vs2013")
                add_files("src/common/tuklib_cpucores.c",
                          "src/common/tuklib_physmem.c",
                          "src/liblzma/check/*.c|*_small.c|*_tablegen.c",
                          "src/liblzma/common/*.c",
                          "src/liblzma/delta/*.c",
                          "src/liblzma/lzma/*.c|*_tablegen.c",
                          "src/liblzma/lz/*.c",
                          "src/liblzma/rangecoder/price_table.c",
                          "src/liblzma/simple/*.c")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("DLL_EXPORT")
                end
                add_headerfiles("src/liblzma/api/*.h")
                add_headerfiles("src/liblzma/api/(lzma/*.h)")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_install("macosx", "linux", "mingw@linux,macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-static=no")
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lzma_code", {includes = "lzma.h"}))
    end)
