package("libusb-win32")
    set_homepage("https://github.com/mcuee/libusb-win32")
    set_description("libusb-win32 is a port of the libusb-0.1 API for Windows with some additional asynchronous transfer support.")
    set_license("LGPL-2.0-or-later")

    add_urls("https://github.com/mcuee/libusb-win32/archive/refs/tags/release_$(version).0.tar.gz", {alias = "tarball"})
    add_urls("https://github.com/mcuee/libusb-win32.git", {alias = "git"})

    add_versions("tarball:1.4.0", "78a002442e98d2f01c469ac7d01283f9655e257e18c4ad7670d00494b48deb8d")
    add_versions("git:1.4.0", "release_1.4.0.0")

    on_install("windows", "mingw", "msys", "cygwin", function (package)
        os.cd("libusb")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("libusb0")
                set_kind("$(kind)")
                add_files(
                    "src/descriptors.c",
                    "src/error.c",
                    "src/install.c",
                    "src/registry.c",
                    "src/usb.c",
                    "src/windows.c"
                )
                add_headerfiles(
                    "src/error.h",
                    "src/lusb0_usb.h",
                    "src/registry.h",
                    "src/usbi.h"
                )
                -- add_files("src/resource.rc")
                add_syslinks("advapi32", "gdi32", "setupapi", "user32")
                add_files("libusb0.def")
                add_defines("LOG_APPNAME=\"libusb-dll\"")
                add_includedirs(
                    "src",
                    "src/driver"
                )
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                usb_init();
            }
        ]]}, {configs = {languages = "c99"}, includes = "lusb0_usb.h"}))
    end)
