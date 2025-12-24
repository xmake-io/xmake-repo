package("ufbx")
    set_homepage("https://github.com/ufbx/ufbx")
    set_description("Single source file FBX loader")
    set_license("MIT")

    set_urls("https://github.com/ufbx/ufbx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ufbx/ufbx.git")

    add_versions("v0.21.2", "41488cde8a7dd43e361d04a7d4003123be9af8eaa2cc26d48e1834b44d120606")
    add_versions("v0.20.1", "1e45f7040ee38e8a6b564a5becb6b64335af89505f7077a0cc7bce092e188fca")
    add_versions("v0.20.0", "108fde070dc7c1471ad5a08890804cf92c84de7415cbb12d21f4ceaaa13a14cc")
    add_versions("v0.18.2", "9161239e9aade9fc3e432420450687fa538893566002ffc016aa0cba4d1c36a6")
    add_versions("v0.15.1", "de8766f2f4dd1230a2cf32c0f1ffa5e14cf2ce4f46dfe8596b83b3d7f02d5dbe")
    add_versions("v0.15.0", "5de2e49f2bf93a21697b98a1885004487e850efffa29f054703affb1c1b3fbc8")
    add_versions("v0.14.3", "190bf253d5c7da55b54fa9c16357b0de1ec356ff6a92f5b4e0c6b39d2d3ebff7")
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
        os.trycp("extra/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ufbx_load_file", {includes = "ufbx.h"}))
    end)
