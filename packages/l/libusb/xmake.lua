package("libusb")
    set_homepage("https://libusb.info")
    set_description("A cross-platform library to access USB devices ")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libusb/libusb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libusb/libusb.git")

    add_versions("v1.0.26", "a09bff99c74e03e582aa30759cada218ea8fa03580517e52d463c59c0b25e240")

    add_resources("v1.0.26", "libusb-cmake", "https://github.com/libusb/libusb-cmake.git", "84fb1bba4dde4c266944e7c7aa641a8a15d18f31")

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "IOKit", "Security")
        add_extsources("brew::libusb")
    elseif is_plat("bsd") then
        add_syslinks("pthread")
    elseif is_plat("linux") then
        add_deps("eudev")
        add_syslinks("pthread")
        add_extsources("apt::libusb-dev", "pacman::libusb")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libusb")
    end

    add_deps("cmake")

    add_includedirs("include", "include/libusb-1.0")

    on_install("windows", "linux", "macosx", "bsd", "msys", "android", function (package)
        local dir = package:resourcefile("libusb-cmake")
        os.cp(path.join(dir, "CMakeLists.txt"), os.curdir())
        os.cp(path.join(dir, "config.h.in"), os.curdir())
        io.replace("CMakeLists.txt",
            [[get_filename_component(LIBUSB_ROOT "libusb/libusb" ABSOLUTE)]],
            [[get_filename_component(LIBUSB_ROOT "libusb" ABSOLUTE)]], {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local packagedeps = {}
        if package:is_plat("linux") then
            table.insert(packagedeps, "eudev")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libusb_init", {includes = "libusb-1.0/libusb.h"}))
    end)
