package("libevdev")

    set_homepage("https://www.freedesktop.org/wiki/Software/libevdev/")
    set_description("libevdev is a wrapper library for evdev devices. it moves the common tasks when dealing with evdev devices into a library and provides a library interface to the callers, thus avoiding erroneous ioctls, etc. The eventual goal is that libevdev wraps all ioctls available to evdev devices, thus making direct access unnecessary.")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/libevdev/libevdev/-/archive/libevdev-$(version)/libevdev-libevdev-$(version).tar.gz")
    add_versions("1.13.1", "438a9060dca43a305f75a590624412d1f858a908d4807433c67c58770f676a47")

    add_includedirs("include/libevdev-1.0")


    add_deps("meson", "ninja", "pkg-config")
    on_install("linux", function (package)
        import("package.tools.meson").build(package, {"-Dtests=disabled", "-Ddocumentation=disabled"}, {buildir = "out"})
        import("package.tools.ninja").install(package, {}, {buildir = "out"})
    end)


    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <stdlib.h>
            #include <libevdev/libevdev.h>
            #include <libevdev/libevdev-uinput.h>
            void test () {
                struct libevdev *dev = NULL;
                dev = libevdev_new();
                libevdev_free(dev);
            }
        ]]}, {configs = {languages = "c11"}}))
    end)
