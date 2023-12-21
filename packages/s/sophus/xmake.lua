package("sophus")

    set_kind("library", {headeronly = true})
    set_homepage("https://strasdat.github.io/Sophus/")
    set_description("Sophus - Lie groups for 2d/3d Geometry")
    set_license("MIT")

    add_urls("https://github.com/strasdat/Sophus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/strasdat/Sophus.git")
    add_versions("1.22.10", "eb1da440e6250c5efc7637a0611a5b8888875ce6ac22bf7ff6b6769bbc958082")

    add_configs("basic_logging", {description = "Use basic logging (in ensure and test macros).", default = false, type = "boolean"})

    add_deps("cmake", "eigen")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("basic_logging") then
            package:add("defines", "SOPHUS_USE_BASIC_LOGGING")
        else
            package:add("deps", "fmt")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_SOPHUS_TESTS=OFF", "-DBUILD_SOPHUS_EXAMPLES=OFF"}
        table.insert(configs, "-DSOPHUS_USE_BASIC_LOGGING=" .. (package:config("basic_logging") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <sophus/geometry.hpp>
            void test() {
                const double kPi = Sophus::Constants<double>::pi();
                Sophus::SO3d R1 = Sophus::SO3d::rotX(kPi / 4);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
