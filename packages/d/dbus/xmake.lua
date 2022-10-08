package("dbus")
 
    set_homepage("https://www.freedesktop.org/wiki/Software/dbus/")
    set_description("D-Bus is a message bus system, a simple way for applications to talk to one another.")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/dbus/dbus/-/archive/dbus-1.14.2/dbus-dbus-$(version).tar.gz")
    add_versions("1.14.2", "9ec5aad6310f79149aa04e8c6bd9e5e2cdca47cf3acec2d23ee9fe06ac7e7a62")

    add_deps("expat")
    add_includedirs("include/dbus-1.0", "lib/dbus-1.0/include")

    on_install("windows", "linux", "cross", function (package)
        local configs = {"--enable-tests=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    
    
    on_test(function (package)
        assert(package:has_cfuncs("dbus_get_local_machine_id()", {includes = "dbus/dbus.h"}))
    end)
