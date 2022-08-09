package("libev")

    set_homepage("http://software.schmorp.de/pkg/libev")
    set_description("Full-featured high-performance event loop loosely modelled after libevent.")

    add_urls("http://dist.schmorp.de/libev/libev-$(version).tar.gz",
             "https://github.com/xmake-mirror/libev/releases/download/$(version)/libev-$(version).tar.gz",
             "https://github.com/xmake-mirror/libev.git")
    add_versions("4.33", "507eb7b8d1015fbec5b935f34ebed15bf346bed04a11ab82b8eee848c4205aea")

    on_install("macosx", "linux", "iphoneos", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ev_loop", {includes = "ev.h"}))
    end)
