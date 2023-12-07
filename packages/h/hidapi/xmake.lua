package("hidapi")
    set_homepage("https://libusb.info/hidapi/")
    set_description("A Simple cross-platform library for communicating with HID devices")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libusb/hidapi/archive/refs/tags/hidapi-$(version).tar.gz",
             "https://github.com/libusb/hidapi.git")

    add_versions("0.14.0", "a5714234abe6e1f53647dd8cba7d69f65f71c558b7896ed218864ffcf405bcbd")

    add_deps("cmake")

    if is_plat("linux") then
        add_deps("libusb")
    elseif is_plat("macosx") then
        add_frameworks("IOKit", "CoreFoundation", "AppKit")
    elseif is_plat("bsd") then
        add_deps("pkg-config")
    end

    on_install("windows|x86", "windows|x64", "linux", "macosx", function (package)
        local configs = {
            "-DHIDAPI_WITH_TESTS=OFF",
            "-DHIDAPI_BUILD_PP_DATA_DUMP=OFF",
            "-DHIDAPI_BUILD_HIDTEST=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHIDAPI_ENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hid_init", {includes = "hidapi/hidapi.h"}))
    end)
