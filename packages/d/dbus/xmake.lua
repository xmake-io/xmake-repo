package("dbus")

    set_homepage("https://www.freedesktop.org/wiki/Software/dbus/")
    set_description("D-Bus is a message bus system, a simple way for applications to talk to one another.")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/dbus/dbus/-/archive/dbus-1.14.2/dbus-dbus-$(version).tar.gz")
    add_versions("1.14.2", "9ec5aad6310f79149aa04e8c6bd9e5e2cdca47cf3acec2d23ee9fe06ac7e7a62")

    add_deps("expat", "cmake")
    add_includedirs("include/dbus-1.0", "lib/dbus-1.0/include")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("windows", "linux", "macosx", "cross", function (package)
        local configs = {"-DDBUS_BUILD_TESTS=OFF"}
        table.insert(configs, "-DDBUS_SESSION_SOCKET_DIR=./tmp")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local packagedeps
        if package:is_plat("windows") then
            packagedeps = "expat"
            table.insert(configs, "-DDBUS_ENABLE_XML_DOCS=OFF")
            io.replace("CMakeLists.txt", "find_package(EXPAT)", "", {plain = true})
            io.replace("CMakeLists.txt", "NOT EXPAT_FOUND", "FALSE", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dbus_get_local_machine_id()", {includes = "dbus/dbus.h"}))
    end)
