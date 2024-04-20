package("tmxlite")
    set_homepage("https://github.com/fallahn/tmxlite")
    set_description("lightweight C++14 parser for Tiled tmx files")
    set_license("zlib")

    add_urls("https://github.com/fallahn/tmxlite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fallahn/tmxlite.git")

    add_versions("v1.4.4", "ec8893efc8396308f291c284cb09f007441a15aabbb0e5722096cf79c65c9e58")

    add_deps("cmake", "pugixml", "zlib", "zstd")

    on_install("windows", "mingw", "linux", "macos", "bsd", "iphoneos", "cross", function (package)
        os.cd("tmxlite")
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DTMXLITE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DUSE_EXTLIBS=ON")
        table.insert(configs, "-DUSE_ZSTD=ON")

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tmx::Map map;
                map.load("assets/test.tmx");
            }
        ]]}, {configs = {languages = "c++14"}, includes = "tmxlite/Map.hpp"}))
    end)
