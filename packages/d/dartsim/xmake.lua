package("dartsim")

    set_homepage("https://dartsim.github.io/")
    set_description("Dynamic Animation and Robotics Toolkit")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/dartsim/dart/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dartsim/dart.git")
    add_versions("v6.13.0", "4da3ff8cee056252a558b05625a5ff29b21e71f2995e6d7f789abbf6261895f7")

    add_configs("dartpy", {description = "Build dartpy interface.", default = false, type = "boolean"})
    local configdeps = {bullet3 = "Bullet",
                        freeglut = "GLUT",
                        nlopt = "NLOPT",
                        ode = "ODE",
                        openscenegraph = "OpenSceneGraph",
                        tinyxml2 = "tinyxml2",
                        urdfdom = "urdfdom",
                        spdlog = "spdlog"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = false, type = "boolean"})
    end
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
        add_cxxflags("/permissive-")
        add_syslinks("user32")
    end

    add_deps("cmake")
    add_deps("assimp", "libccd", "eigen", "fcl", "octomap", "fmt")
    on_load("windows|x64", "linux", "macosx", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
    end)

    on_install("windows|x64", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "/GL", "", {plain = true})
        io.replace("CMakeLists.txt", "if(TARGET dart)", "if(FALSE)", {plain = true})
        io.replace("dart/CMakeLists.txt", "/LTCG", "", {plain = true})
        io.replace("python/CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        io.replace("python/CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})
        io.replace("python/CMakeLists.txt", "add_subdirectory(tutorials)", "", {plain = true})
        io.replace("cmake/DARTFindDependencies.cmake", "dart_check_required_package(assimp \"assimp\")", "dart_check_required_package(assimp \"assimp\")\nfind_package(ZLIB)\ntarget_link_libraries(assimp INTERFACE ZLIB::ZLIB)", {plain = true})
        io.replace("cmake/DARTFindDependencies.cmake", "dart_check_required_package(fcl \"fcl\")", "dart_check_required_package(fcl \"fcl\")\ntarget_link_libraries(fcl INTERFACE ccd)", {plain = true})
        io.replace("cmake/DARTFindDependencies.cmake", "check_cxx_source_compiles%(.-\".-\".-(ASSIMP.-DEFINED)%)", "set(%1 1)")
        local configs = {
            "-DDART_SKIP_lz4=ON",
            "-DDART_SKIP_flann=ON",
            "-DDART_SKIP_IPOPT=ON",
            "-DDART_SKIP_pagmo=ON",
            "-DDART_SKIP_DOXYGEN=ON",
            "-DDART_TREAT_WARNINGS_AS_ERRORS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DDART_SKIP_" .. dep .. "=" .. (package:config(config) and "OFF" or "ON"))
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DDART_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "/MT" or "/MD"))
        end
        table.insert(configs, "-DDART_BUILD_DARTPY=" .. (package:config("dartpy") and "ON" or "OFF"))
        table.insert(configs, "-DDART_BUILD_GUI_OSG=" .. (package:config("openscenegraph") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dart/dart.hpp>
            void test() {
                dart::simulation::WorldPtr world = dart::simulation::World::create();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
