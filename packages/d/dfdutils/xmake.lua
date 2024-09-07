package("dfdutils")
    set_homepage("https://github.com/KhronosGroup/dfdutils")
    set_description("Utilities for working with Khronos data format descriptors")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/dfdutils.git")
    add_versions("2023.10.27", "854792a6ced4cb7cce64f26bf297bf7ea294a9b6")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("dfdutils")
                set_kind("$(kind)")
                add_files(
                    "createdfd.c", "colourspaces.c", "interpretdfd.c",
                    "printdfd.c", "queries.c", "vk2dfd.c"
                )
                add_headerfiles("dfd.h", {prefixdir = "dfdutils"})
                add_headerfiles("(vulkan/*.h)", "(KHR/*.h)")
                add_includedirs(".", "KHR")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vk2dfd", {includes = "dfdutils/dfd.h"}))
    end)
