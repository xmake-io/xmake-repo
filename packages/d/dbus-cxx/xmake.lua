package("dbus-cxx")
    set_homepage("https://dbus-cxx.github.io/")
    set_description("DBus-cxx provides an object-oriented interface to DBus")
    set_license("LGPL-3.0-or-later AND BSD-3-Clause")

    add_urls("https://github.com/dbus-cxx/dbus-cxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dbus-cxx/dbus-cxx.git")

    add_versions("2.6.0", "ca22380ec04a1f10154fca76d41e8ce4a8a6351ce86546b297bda5f7eefbc108")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("glib", {description = "Build dbus-cxx with GLib module.", default = true, type = "boolean"})
    add_configs("libuv", {description = "Build dbus-cxx with libuv module.", default = true, type = "boolean"})
    add_configs("qt5", {description = "Build dbus-cxx with QT5 module.", default = true, type = "boolean"})

    add_includedirs("include", "include/dbus-cxx-2.0")

    add_deps("cmake")
    add_deps("libsigcplusplus")

    on_load(function (package)
        if package:is_plat("linux") and package:is_arch("arm64") and package:config("qt5") then
            package:config_set("qt5", false)
            wprint("Disabling qt5, since Linux arm64 AQT does not support QT5, but supports QT6 (6.7.0 -> 6.10.0).")
        end
        if package:config("glib") then
            package:add("deps", "glib")
            package:add("includedirs", "include/dbus-cxx-glib-2.0")
        end
        if package:config("libuv") then
            package:add("deps", "libuv")
            package:add("includedirs", "include/dbus-cxx-uv-2.0")
        end
        if package:config("qt5") then
            package:add("deps", "qt5core")
            package:add("includedirs", "include/dbus-cxx-qt-2.0")
        end
    end)

    on_install("linux", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF", "-DENABLE_CODE_COVERAGE_REPORT=OFF",
            "-DENABLE_EXAMPLES=OFF", "-DENABLE_TOOLS=OFF", "-DBUILD_SITE=OFF", "-DUV_STATIC=OFF"
        }
        table.insert(configs, "-DENABLE_GLIB_SUPPORT=" .. (package:config("glib") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_UV_SUPPORT=" .. (package:config("libuv") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_QT_SUPPORT=" .. (package:config("qt5") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dbus-cxx.h>
            void test() {
                auto connection = DBus::Connection::create(DBus::BusType::SESSION);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
