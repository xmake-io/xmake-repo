package("fcpw")
    set_homepage("https://github.com/rohan-sawhney/fcpw")
    set_description("FCPW: Fastest Closest Points in the West")
    set_license("MIT")

    add_urls("https://github.com/rohan-sawhney/fcpw.git")
    add_versions("v1.0.5", "9a0c41ae44fbcbf32a1740adec7a2a79eded249f")
    add_versions("v1.1.2", "b61f006f35396968dfae982f7fba0a67b1f4b4a2")

    add_configs("enoki", {description = "Build enoki backend", default = false, type = "boolean"})
    add_configs("gpu", {description = "Enable GPU support", default = false, type = "boolean"})
    add_configs("python", {description = "Build python binding", default = false, type = "boolean"})

    add_deps("eigen")
    on_load(function (package)
        if package:config("enoki") then
            package:add("deps", "enoki")
            package:add("defines", "FCPW_USE_ENOKI")
            -- define FCPW_SIMD_WIDTH by user
        end
        if package:config("gpu") then
            package:add("defines", "FCPW_USE_GPU")
        end
        if package:config("python") then
            package:add("deps", "cmake")
            package:add("deps", "python 3.x")
        else
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        os.cp("include/fcpw", package:installdir("include"))
        if package:config("python") then
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DFCPW_USE_ENOKI=" .. (package:config("enoki") and "ON" or "OFF"))
            table.insert(configs, "-DFCPW_ENABLE_GPU_SUPPORT=" .. (package:config("gpu") and "ON" or "OFF"))
            table.insert(configs, "-DFCPW_BUILD_BINDINGS=" .. (package:config("python") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fcpw/fcpw.h>
            void test() {
                fcpw::Scene<3> scene;
                scene.setObjectCount(1);
                scene.build(fcpw::AggregateType::Bvh_SurfaceArea, true);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
