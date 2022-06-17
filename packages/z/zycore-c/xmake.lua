package("zycore-c")
    set_homepage("https://github.com/zyantific/zycore-c")
    set_description("Internal library providing platform independent types, macros and a fallback for environments without LibC.")
    set_license("MIT")

    add_urls("https://github.com/zyantific/zycore-c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zyantific/zycore-c.git")
<<<<<<< HEAD
    add_versions("v1.1.0", "b5496779b95206763980aad30db10e36a13a10ebaf2e74574cddf2ca744ad227")
=======
>>>>>>> 0964a50 (add package: zycore-c)
    add_versions("v1.0.0", "aa93d6da992953693754834c130ce193980b7d7137ea2d41c2c1f618c65e4545")

    add_deps("cmake")

    on_install(function (package)
        if package:version():eq("v1.1.0") and package:is_plat("mingw") then
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
