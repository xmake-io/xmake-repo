package("libsmb2")
    set_homepage("https://github.com/sahlberg/libsmb2")
    set_description("SMB2/3 userspace client")
    set_license("LGPL-2.1")

    add_urls("https://github.com/sahlberg/libsmb2/archive/9e4b679ff32141fdddfe97f08d530f539162847b.tar.gz",
             "https://github.com/sahlberg/libsmb2.git")

    add_versions("2024.07.16", "49ac50058af28612da3fead14f9566fcd3ed334c8afc33f94d5cd790c745ea9c")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    add_includedirs("include", "include/smb2")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 26, "package(libsmb2): need ndk api level >= 26 for android")
        end)
    end

    on_install(function (package)
        if package:is_plat("mingw") then
            io.replace("lib/compat.h", "_WINDOWS", "_WIN32", {plain = true})
            io.replace("lib/compat.c", "_WINDOWS", "_WIN32", {plain = true})
            io.replace("lib/socket.c", "_WINDOWS", "_WIN32", {plain = true})
            io.replace("include/smb2/libsmb2.h", "_WINDOWS", "_WIN32", {plain = true})
            io.replace("include/asprintf.h", "vasprintf", "vasprintf_", {plain = true})
            io.replace("include/asprintf.h", "asprintf", "asprintf_", {plain = true})
            if package:is_arch("i386") then
                io.replace("lib/compat.h", "typedef SSIZE_T ssize_t;", "", {plain = true})
            end
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("smb2_init_context", {includes = {"stddef.h", "stdint.h", "smb2/libsmb2.h"}}))
    end)
