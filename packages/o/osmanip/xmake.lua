package("osmanip")
    set_homepage("https://github.com/JustWhit3/osmanip")
    set_description("A cross-platform library for output stream manipulation using ANSI escape sequences.")
    set_license("MIT")

    add_urls("https://github.com/JustWhit3/osmanip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/JustWhit3/osmanip.git")
    add_versions("v4.6.1", "5454cb0caced1fb9af90666001f2874786a33e6830024cb41c99a5b4ab966f1c")

    add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DOSMANIP_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory( deps )", "", {plain = true})
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
