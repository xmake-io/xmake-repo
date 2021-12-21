package("libusbmuxd")

    set_homepage("https://github.com/libimobiledevice/libusbmuxd")
    set_description("A client library to multiplex connections from and to iOS devices")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libimobiledevice/libusbmuxd.git")
    add_versions("2021.09.13", "2ec5354a6ff2ba5e2740eabe7402186f29294f79")
    add_deps("libimobiledevice-glue")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    on_install("macosx", "linux", "mingw@macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        io.replace("tools/Makefile.am", "bin_PROGRAMS = iproxy inetcat", "bin_PROGRAMS =")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("usbmuxd_events_subscribe", {includes = "usbmuxd.h"}))
    end)
