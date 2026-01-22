package("orocos-kdl")
    set_homepage("http://www.orocos.org/")
    set_description("Orocos Kinematics and Dynamics C++ library")

    add_urls("https://github.com/orocos/orocos_kinematics_dynamics/archive/refs/tags/$(version).tar.gz",
             "https://github.com/orocos/orocos_kinematics_dynamics.git", {submodules = false})

    add_versions("1.5.3", "3895eed1b51a6803c79e7ac4acd6a2243d621b887ac26a1a6b82a86a1131c3b6")

    add_configs("models", {description = "Build models for some well known robots", default = false, type = "boolean"})

    add_links("orocos-kdl-models", "orocos-kdl")

    add_deps("cmake")
    add_deps("eigen")

    on_install(function (package)
        io.replace("orocos_kdl/src/CMakeLists.txt", "ADD_LIBRARY(orocos-kdl ${LIB_TYPE} ${KDL_SRCS})", "ADD_LIBRARY(orocos-kdl ${KDL_SRCS})", {plain = true})

        local configs = {
            "-DENABLE_TESTS=OFF",
            "-DENABLE_EXAMPLES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DBUILD_MODELS=" .. (package:config("models") and "ON" or "OFF"))

        os.cd("orocos_kdl")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <kdl/path_roundedcomposite.hpp>
            #include <kdl/rotational_interpolation_sa.hpp>

            using namespace KDL;

            void test() {
                Path_RoundedComposite* path = new Path_RoundedComposite(0.2,0.01,new RotationalInterpolation_SingleAxis());
                path->Add(Frame(Rotation::RPY(PI,0,0), Vector(-1,0,0)));
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
