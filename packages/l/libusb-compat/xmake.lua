package("libusb-compat")
    set_homepage("https://github.com/libusb/libusb-compat-0.1")
    set_description("A compatibility layer allowing applications written for libusb-0.1 to work with libusb-1.0.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libusb/libusb-compat-0.1/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libusb/libusb-compat-0.1.git")

    add_versions("v0.1.8", "73f8023b91a4359781c6f1046ae84156e06816aa5c2916ebd76f353d41e0c685")

    add_deps("libusb")

    on_load("wasm", function (package)
        package:add("defines", "PATH_MAX=4096")
    end)

    -- libusb does not support iOS and FreeBSD.
    -- libusb-compat compatibility layer does not support bare win32
    on_install("!iphoneos and !bsd and !windows", function (package)
        io.writefile("config.h", [[
            #define API_EXPORTED __attribute__((visibility("default")))
            #define ENABLE_DEBUG_LOGGING 0
            #define ENABLE_LOGGING 1
        ]])
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libusb")
            target("libusb-compat")
                set_kind("$(kind)")
                add_files("libusb/core.c")
                add_includedirs(".")
                add_headerfiles("libusb/usb.h")
                add_packages("libusb")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("usb_init", {configs = {languages = "c99"}, includes = "usb.h"}))
    end)
