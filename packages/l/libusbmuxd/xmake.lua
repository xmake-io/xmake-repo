package("libusbmuxd")

    set_homepage("https://github.com/libimobiledevice/libusbmuxd")
    set_description("A client library to multiplex connections from and to iOS devices")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libimobiledevice/libusbmuxd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libimobiledevice/libusbmuxd.git")
    add_versions("2.0.2", "8ae3e1d9340177f8f3a785be276435869363de79f491d05d8a84a59efc8a8fdc")

    add_deps("libplist")
    on_install("macosx", "linux", "mingw@macosx", function (package)
        local configs = {"--with-pic"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("usbmuxd_events_subscribe", {includes = "usbmuxd.h"}))
    end)
