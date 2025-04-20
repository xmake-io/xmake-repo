package("sophus")
    set_kind("library", {headeronly = true})
    set_homepage("https://strasdat.github.io/Sophus/")
    set_description("C++ implementation of Lie Groups using Eigen.")
    set_license("MIT")

    add_urls("https://github.com/strasdat/Sophus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/strasdat/Sophus.git")

    add_versions("1.24.6", "3f3098bdac2c74d42a921dbfb0e5e4b23601739e35a1c1236c2807c399da960c")
    add_versions("1.22.10", "eb1da440e6250c5efc7637a0611a5b8888875ce6ac22bf7ff6b6769bbc958082")

    add_configs("basic_logging", {description = "Use basic logging (in ensure and test macros).", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("eigen")

    on_load(function (package)
        if package:config("basic_logging") then
            package:add("defines", "SOPHUS_USE_BASIC_LOGGING")
        else
            package:add("deps", "fmt")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_SOPHUS_TESTS=OFF", "-DBUILD_SOPHUS_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSOPHUS_USE_BASIC_LOGGING=" .. (package:config("basic_logging") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const double kPi = Sophus::Constants<double>::pi();
                Sophus::SO3d R1 = Sophus::SO3d::rotX(kPi / 4);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "sophus/geometry.hpp"}))
    end)
