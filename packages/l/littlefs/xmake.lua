package("littlefs")
    set_homepage("https://github.com/littlefs-project/littlefs")
    set_description("A little fail-safe filesystem designed for microcontrollers")

    add_urls("https://github.com/littlefs-project/littlefs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/littlefs-project/littlefs.git")
    add_versions("v2.5.0", "07de0d788c2a849a137715b48cce9daeb3fdc7570873ac6faae4566432e140c8")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("littlefs")
               set_kind("$(kind)")
               add_files("*.c")
               add_headerfiles("*.h")
               if is_plat("windows") then
                   add_defines("LFS_NO_ERROR", "LFS_NO_DEBUG", "LFS_NO_WARN")
               end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lfs_mount", {includes = "lfs.h"}))
    end)
