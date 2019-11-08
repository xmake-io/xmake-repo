package("libusb")

    set_homepage("https://libusb.info")
    set_description("A cross-platform library to access USB devices.")

    set_urls("https://github.com/libusb/libusb/archive/$(version).tar.gz",
             "https://github.com/libusb/libusb.git")
    add_versions("v1.0.23", "02620708c4eea7e736240a623b0b156650c39bfa93a14bcfa5f3e05270313eba")

    if not is_host("windows") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    add_includedirs("include/libusb-1.0")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libusb_init", {includes = "libusb.h"}))
    end)
