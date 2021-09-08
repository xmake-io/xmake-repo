package("bzip2")

    set_homepage("https://sourceware.org/bzip2/")
    set_description("Freely available, patent free, high-quality data compressor.")

    add_urls("https://sourceware.org/pub/bzip2/bzip2-$(version).tar.gz")
    add_versions("1.0.8", "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269")
    add_patches("1.0.8", path.join(os.scriptdir(), "patches", "dllexport.patch"), "f72679b2ad55262bbc9da49f352f6cf128db85047aaa04ca42126c839b709461")

    on_load(function (package)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "BZ_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        configs.mode = package:debug() and "debug" or "release"

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("bunzip2 --help")
        os.vrun("bzcat --help")
        os.vrun("bzip2 --help")
        assert(package:has_cfuncs("BZ2_bzCompressInit", {includes = "bzlib.h"}))
    end)
