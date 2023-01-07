package("libaesgm")
    set_homepage("https://github.com/xmake-mirror/libaesgm")
    set_description("https://repology.org/project/libaesgm/packages")

    add_urls("https://github.com/xmake-mirror/libaesgm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-mirror/libaesgm.git")
    add_versions("2013.1.1", "102353a486126c91ccab791c3e718d056d8fbb1be488da81b26561bc7ef4f363")

    on_install("linux", "macosx", "windows", "mingw", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("aesgm")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aes_init", {includes = "aes.h"}))
    end)
