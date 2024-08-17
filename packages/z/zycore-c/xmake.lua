package("zycore-c")
    set_homepage("https://github.com/zyantific/zycore-c")
    set_description("Internal library providing platform independent types, macros and a fallback for environments without LibC.")
    set_license("MIT")

    add_urls("https://github.com/zyantific/zycore-c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zyantific/zycore-c.git")

    add_versions("v1.5.0", "68e287cb6c95a6dede810d1e4fb2aebf7a09473089570a847e9a2b115ff96ff4")
    add_versions("v1.4.1", "8f610917c4254a69ec7e0c63492e9d0be9d18f4bb8fe91a3ff6ebed917d1f0f8")
    add_versions("v1.4.0", "b5ff45647c59be733e746c3a0d3c8d8a81f9e46f868af88e65b0e581b1171855")
    add_versions("v1.3.0", "547ed2902332b25e5a8eeb97d0fb268cb39c156bb04e70d66c28b25712b60346")
    add_versions("v1.2.0", "6389ecee0c8176de9d61d40f2d3801d2371012ba415dc899665de4949ca4b35d")
    add_versions("v1.1.0", "b5496779b95206763980aad30db10e36a13a10ebaf2e74574cddf2ca744ad227")
    add_versions("v1.0.0", "aa93d6da992953693754834c130ce193980b7d7137ea2d41c2c1f618c65e4545")

    add_deps("cmake")

    on_install("!wasm", function (package)
        if package:version():ge("1.1.0") and package:version():le("1.2.0") and package:is_plat("mingw") then
            local rc_str = io.readfile("resources/VersionInfo.rc", {encoding = "utf16le"})
            io.writefile("resources/VersionInfo.rc", rc_str, {encoding = "utf8"})
        end
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DZYCORE_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Zycore/Comparison.h>
            #include <Zycore/Vector.h>
            void test() {
                ZyanVector vector;
                ZyanU16 buffer[32];
            }
        ]]}))
    end)
