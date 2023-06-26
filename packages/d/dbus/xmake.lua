package("dbus")

    set_homepage("https://www.freedesktop.org/wiki/Software/dbus/")
    set_description("D-Bus is a message bus system, a simple way for applications to talk to one another.")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/dbus/dbus/-/archive/dbus-$(version)/dbus-dbus-$(version).tar.gz")
    add_versions("1.14.2", "9ec5aad6310f79149aa04e8c6bd9e5e2cdca47cf3acec2d23ee9fe06ac7e7a62")
    add_versions("1.14.6", "2533742eb324fa7fbb093a3ed0ff436c7eb11861fd6a31e9b857fc4878f01831")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::dbus")
    elseif is_plat("linux") then
        add_extsources("pacman::dbus", "apt::libdbus-1-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::dbus")
    end

    add_deps("expat", "cmake")
    add_includedirs("include/dbus-1.0", "lib/dbus-1.0/include")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("windows", "linux", "macosx", "cross", function (package)
        local configs = {"-DDBUS_BUILD_TESTS=OFF", "-DDBUS_ENABLE_DOXYGEN_DOCS=OFF", "-DDBUS_ENABLE_XML_DOCS=OFF"}
        table.insert(configs, "-DDBUS_SESSION_SOCKET_DIR=" .. package:installdir("socket"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local packagedeps
        if package:is_plat("windows") then
            packagedeps = "expat"
            io.replace("CMakeLists.txt", "find_package(EXPAT)", "", {plain = true})
            io.replace("CMakeLists.txt", "NOT EXPAT_FOUND", "FALSE", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dbus_get_local_machine_id()", {includes = "dbus/dbus.h"}))
    end)
