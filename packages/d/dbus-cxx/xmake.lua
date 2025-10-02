package("dbus-cxx")
    set_homepage("https://dbus-cxx.github.io/")
    set_description("DBus-cxx provides an object-oriented interface to DBus")

    add_urls("https://github.com/dbus-cxx/dbus-cxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dbus-cxx/dbus-cxx.git")

    add_versions("2.6.0", "ca22380ec04a1f10154fca76d41e8ce4a8a6351ce86546b297bda5f7eefbc108")

    add_configs("with_glib", {description = "Build with GLib library support.", default = true, type = "boolean"})
    add_configs("with_qt", {description = "Build with QT library support.", default = true, type = "boolean"})
    add_configs("with_uv", {description = "Build with UV library support.", default = true, type = "boolean"})

    add_includedirs("include", "include/dbus-cxx-2.0")

    add_deps("cmake")
    add_deps("libsigcplusplus")

    on_load(function (package)
        if package:config("with_glib") then
            package:add("deps", "glib")
        end
        if package:config("with_qt") then
            package:add("deps", "qt5core")
        end
        if package:config("with_uv") then
            package:add("deps", "libuv")
        end
        if package:is_plat("linux") and package:is_arch("arm64") then
            package:config_set("with_qt", false)
            wprint("Linux arm64 AQT does not support QT5, but supports QT6 (6.7.0 -> 6.10.0)")
        end
    end)

    on_install("linux", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF", "-DENABLE_CODE_COVERAGE_REPORT=OFF",
            "-DENABLE_EXAMPLES=OFF", "-DENABLE_TOOLS=OFF", "-DBUILD_SITE=OFF", "-DUV_STATIC=OFF"}

        table.insert(configs, "-DENABLE_GLIB_SUPPORT=" .. (package:config("with_glib") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_QT_SUPPORT=" .. (package:config("with_qt") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_UV_SUPPORT=" .. (package:config("with_uv") and "ON" or "OFF"))

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
