package("libimobiledevice")

    set_homepage("https://github.com/libimobiledevice/libimobiledevice")
    set_description("A cross-platform protocol library to communicate with iOS devices")

    add_urls("https://github.com/libimobiledevice/libimobiledevice/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libimobiledevice/libimobiledevice.git")
    add_versions("1.3.0", "acbfb73eabee162e64c0d9de207d71c0a5f47c40cd5ad32a5097f734328ce10a")

    add_deps("libplist", "libusbmuxd", "openssl")
    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-debug=" .. (package:config("debug") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("idevice_event_subscribe", {includes = "libimobiledevice/libimobiledevice.h"}))
    end)
