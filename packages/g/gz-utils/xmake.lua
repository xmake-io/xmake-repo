package("gz-utils")
    set_homepage("https://gazebosim.org/")
    set_description("Classes and functions for robot applications")
    set_license("Apache-2.0")

    add_urls("https://github.com/gazebosim/gz-utils/archive/refs/tags/gz-utils4_$(version).tar.gz")
    add_urls("https://github.com/gazebosim/gz-utils.git", {alias = "git"})

    add_versions("4.0.0", "b06a179ea4297be8b8d09ea7a5d3d45059a3e4030c1bd256afc62f997cc992ed")

    add_versions("git:4.0.0", "gz-utils4_4.0.0")

    add_includedirs("include", "include/gz/utils4")

    add_deps("cmake", "gz-cmake 5.x")
    add_deps("cli11", {configs = {cmake = true}})
    add_deps("spdlog", {configs = {header_only = false}})

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "GZ_UTILS_STATIC_DEFINE")
        end

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <gz/utils/cli/CLI.hpp>
            #include <gz/utils/log/Logger.hh>
            void test() {
                CLI::App app{"Using gz-utils CLI wrapper"};
                gz::utils::log::Logger logger("my_logger");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
