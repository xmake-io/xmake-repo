package("littlefs")
    set_homepage("https://github.com/littlefs-project/littlefs")
    set_description("A little fail-safe filesystem designed for microcontrollers")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/littlefs-project/littlefs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/littlefs-project/littlefs.git")

    add_versions("v2.10.1", "620691695d65ad161eed1247122b63ad03e0251d8617864ba086a563afe98216")
    add_versions("v2.9.3", "9cf2e7db673ea27d967a54cdafe8f55a7ffe27c63a2070ff7424fadd559cad67")
    add_versions("v2.9.2", "97675486790a09d335fa0955da105a0a08e1ff336208b77730d92a041b202015")
    add_versions("v2.8.2", "9f46d00d6d6ad0a0d72840455ba748efcad84b8a236bd8b9d3a08e3af7953386")
    add_versions("v2.5.0", "07de0d788c2a849a137715b48cce9daeb3fdc7570873ac6faae4566432e140c8")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("littlefs")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")
                if is_plat("windows") then
                    add_defines("LFS_NO_ERROR", "LFS_NO_DEBUG", "LFS_NO_WARN")
                end
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lfs_mount", {includes = "lfs.h"}))
    end)
