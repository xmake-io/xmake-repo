package("littlefs")
    set_homepage("https://github.com/littlefs-project/littlefs")
    set_description("A little fail-safe filesystem designed for microcontrollers")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/littlefs-project/littlefs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/littlefs-project/littlefs.git")

    add_versions("v2.9.0", "47b2c2aab6ca595e5eb4f8d1e5ec88d2566a153ca8b21176ba55abcb9d8808b6")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("littlefs")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h", {prefixdir = "littlefs"})
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lfs_mount", {includes = "littlefs/lfs.h"}))
    end)
