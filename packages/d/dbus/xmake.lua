package("dbus")
    set_homepage("https://www.freedesktop.org/wiki/Software/dbus/")
    set_description("D-Bus is a message bus system, a simple way for applications to talk to one another.")
    set_license("GPL-2.0-or-later")

    add_urls("https://gitlab.freedesktop.org/dbus/dbus/-/archive/dbus-$(version)/dbus-dbus-$(version).tar.gz")
    add_versions("1.14.2", "9ec5aad6310f79149aa04e8c6bd9e5e2cdca47cf3acec2d23ee9fe06ac7e7a62")
    add_versions("1.14.6", "2533742eb324fa7fbb093a3ed0ff436c7eb11861fd6a31e9b857fc4878f01831")
    add_versions("1.14.8", "273718fe5150a1a44fe77abcf442dc64082f7375fdc15fcbd80b84316f897326")
    add_versions("1.16.2", "d77cc71acd93e85f2bd2a6fe3a40e5bd023519e3e9fa9b5361e7109f42b74060")

    -- bionic's socklen_t is signed on 32-bit ABIs (e.g. armeabi-v7a), which trips
    -- a dbus static assert that assumes it is unsigned; guard it on Android.
    add_patches("1.16.2", "patches/1.16.2/android-socklen_t-signed.patch", "c5c98e1300e05c737cfcf3a6904973dbb9fa0a71c036d5c96bd8c29f81f5b3a5")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::dbus")
    elseif is_plat("linux") then
        add_extsources("pacman::dbus", "apt::libdbus-1-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::dbus")
    end

    add_deps("cmake", "expat")
    add_includedirs("include/dbus-1.0", "lib/dbus-1.0/include")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("system_bus_address", {description = "D-Bus system bus address.", type = "string"})

    on_check("android", function (package)
        -- dbus uses getgrnam_r/getgrgid_r, which bionic only declares since API 24
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk and ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(dbus): need ndk api level >= 24 for android")
    end)

    on_install(function (package)
        local configs = {"-DDBUS_BUILD_TESTS=OFF", "-DDBUS_ENABLE_DOXYGEN_DOCS=OFF", "-DDBUS_ENABLE_XML_DOCS=OFF"}
        if package:is_plat("wasm") then
            table.insert(configs, "-DDBUS_BUILD_DAEMON=OFF")
            table.insert(configs, "-DDBUS_ENABLE_LAUNCHD=OFF")
            table.insert(configs, "-DDBUS_ENABLE_SYSTEMD=OFF")
            table.insert(configs, "-DDBUS_BUILD_X11=OFF")
        end
        table.insert(configs, "-DDBUS_SESSION_SOCKET_DIR=" .. path.unix(package:installdir("socket")))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        local system_bus_address = package:config("system_bus_address")
        if system_bus_address then
            table.insert(configs, "-DDBUS_SYSTEM_BUS_DEFAULT_ADDRESS=" .. system_bus_address)
        end
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", "find_package(EXPAT)", "", {plain = true})
            io.replace("CMakeLists.txt", "NOT EXPAT_FOUND", "FALSE", {plain = true})
        else
            local expat = package:dep("expat")
            local fetchinfo = expat and expat:fetch()
            if fetchinfo then
                local incdir = table.wrap(fetchinfo.includedirs or fetchinfo.sysincludedirs)[1]
                local libfile = table.wrap(fetchinfo.libfiles)[1]
                if incdir then
                    table.insert(configs, "-DEXPAT_INCLUDE_DIR=" .. incdir)
                end
                if libfile then
                    table.insert(configs, "-DEXPAT_LIBRARY=" .. libfile)
                end
            end
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "expat"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dbus_get_local_machine_id()", {includes = "dbus/dbus.h"}))
    end)
