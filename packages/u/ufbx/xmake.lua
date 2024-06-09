package("ufbx")
    set_homepage("https://github.com/ufbx/ufbx")
    set_description("Single source file FBX loader")
    set_license("MIT")

    set_urls("https://github.com/ufbx/ufbx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ufbx/ufbx.git")

    add_versions("v0.14.2", "0a50e7328a20a5e8be25a4ae13af1f2dacb51531a94321ef3fe5c57d799fc72e")
    add_versions("v0.14.0", "7bc48494b236e2ed41000f0008cecc9459956dd25154d91c4af4144c2a26fe6d")
    add_versions("v0.13.0", "7715ca1e66c005dea6cfe4817be71fa8e31a8e3d36bed18aec5e0df1a953a22c")
    add_versions("v0.12.0", "5897de4ff727f718df8b2dbe30797fbcbb0f2d7d47ec52f01d30729e62b314b3")
    add_versions("v0.11.1", "c95a698076179fcb1deb163cea9ab0c7c1cdc6b1bc7fb492da20f4a1315a186a")
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
