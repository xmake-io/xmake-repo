package("libqrencode")
    set_homepage("https://github.com/fukuchi/libqrencode")
    set_description("A fast and compact QR Code encoding library")
    set_license("LGPL-2.1")

    add_urls("https://github.com/fukuchi/libqrencode/archive/refs/tags/v$(version).zip")
    add_versions("4.1.1", "5ebf5f71fefda8e58e713e821f956759b38b9178ce455df7444e17f5c99e1b19")

    add_deps("cmake")
    add_deps("libpng")

    on_install(function (package)
        local configs = {"-DWITH_TOOLS=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("QRinput_append", {includes = "qrencode.h"}))
    end)
