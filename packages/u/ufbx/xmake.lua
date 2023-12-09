package("ufbx")
    set_homepage("https://github.com/ufbx/ufbx")
    set_description("Single source file FBX loader")
    set_license("MIT")

    set_urls("https://github.com/ufbx/ufbx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ufbx/ufbx.git")

    add_versions("v0.6.1", "117a67e2b6d2866fb989bf1b740c89cfb3d5f2a97d46a821be536d9d0fbd5134")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("ufbx")
                set_kind("$(kind)")
                add_files("ufbx.c")
                add_headerfiles("ufbx.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ufbx_load_file", {includes = "ufbx.h"}))
    end)
