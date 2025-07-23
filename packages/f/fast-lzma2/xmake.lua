package("fast-lzma2")
    set_homepage("https://github.com/conor42/fast-lzma2")
    set_description("Fast LZMA2 Library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/conor42/fast-lzma2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/conor42/fast-lzma2.git")

    add_versions("v1.0.1", "60fd0a031fb0a153ba4f00799aed443ce9f149b203c59e17e558afbfafe8bf64")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("xxhash")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "FL2_DLL_IMPORT")
        end

        os.rm("xxhash.c")
        os.rm("xxhash.h")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FL2_compress", {includes = "fast-lzma2.h"}))
    end)
