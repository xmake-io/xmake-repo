package("libusbmuxd")

    set_homepage("https://github.com/libimobiledevice/libusbmuxd")
    set_description("A client library to multiplex connections from and to iOS devices")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libimobiledevice/libusbmuxd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libimobiledevice/libusbmuxd.git")
    add_versions("2.0.2", "8ae3e1d9340177f8f3a785be276435869363de79f491d05d8a84a59efc8a8fdc")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    add_deps("libplist")
    on_install("macosx", "linux", "mingw@macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local cflags
        if package:is_plat("mingw") then
            -- disable ifaddrs for mingw
            cflags = {"-DWIN32", "-D_WIN32_WINNT=0x0600"}
            io.replace("common/socket.c", "AF_INET6", "AF_INET6_")
        end
        -- disable tools
        io.replace("tools/Makefile.am", "bin_PROGRAMS = iproxy inetcat", "bin_PROGRAMS =")
        -- fix multiple definition with libplist
        io.replace("common/thread.c", "thread_once", "thread_once_")
        io.replace("common/thread.h", "thread_once", "thread_once_")
        io.replace("src/libusbmuxd.c", "thread_once", "thread_once_")
        import("package.tools.autoconf").install(package, configs, {cflags = cflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("usbmuxd_events_subscribe", {includes = "usbmuxd.h"}))
    end)
