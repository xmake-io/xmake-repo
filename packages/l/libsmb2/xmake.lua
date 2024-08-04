package("libsmb2")
    set_homepage("https://github.com/sahlberg/libsmb2")
    set_description("SMB2/3 userspace client")
    set_license("LGPL-2.1")

    add_urls("https://github.com/sahlberg/libsmb2/archive/9e4b679ff32141fdddfe97f08d530f539162847b.tar.gz",
             "https://github.com/sahlberg/libsmb2.git")

    add_versions("2024.07.16", "49ac50058af28612da3fead14f9566fcd3ed334c8afc33f94d5cd790c745ea9c")

    if is_plat("windows") then
        add_syslinks("ws2_32")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("smb2_init_context", {includes = {"stdint.h", "smb2/libsmb2.h"}}))
    end)
