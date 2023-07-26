package("osmanip")
    set_homepage("https://github.com/JustWhit3/osmanip")
    set_description("A cross-platform library for output stream manipulation using ANSI escape sequences.")
    set_license("MIT")

    add_urls("https://github.com/JustWhit3/osmanip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/JustWhit3/osmanip.git")
    add_versions("v4.6.0", "13230b91b482371e2f5f68adefd5abf98ec9a4e249fa734697ede17ffe60d423")

    add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory( deps )", "", {plain = true})
        io.replace("CMakeLists.txt", "    add_subdirectory( test/unit_tests )", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory( examples )", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <osmanip/utility/options.hpp>
            void test() {
                osm::OPTION(osm::CURSOR::OFF);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
