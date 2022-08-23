package("dartsim")

    set_homepage("https://dartsim.github.io/")
    set_description("Dynamic Animation and Robotics Toolkit")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/dartsim/dart/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dartsim/dart.git")
    add_versions("v6.12.2", "db1b3ef888d37f0dbc567bc291ab2cdb5699172523a58dd5a5fe513ee38f83b0")

    add_patches("v6.12.2", path.join(os.scriptdir(), "patches", "6.12.2", "static.patch"), "9d242fb75d396e360e4b1d01024c2b27fa4012ca7760e0e0e014505666a1f0c3")

    add_configs("dartpy", {description = "Build dartpy interface.", default = false, type = "boolean"})
    local configdeps = {bullet3 = "Bullet",
                        freeglut = "GLUT",
                        nlopt = "NLOPT",
                        ode = "ODE",
                        openscenegraph = "OpenSceneGraph",
                        tinyxml2 = "tinyxml2",
                        urdfdom = "urdfdom",
                        octomap = "octomap",
                        spdlog = "spdlog"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = false, type = "boolean"})
    end
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("boost", {configs = {system = true, filesystem = true}})
    add_deps("assimp", "libccd", "eigen", "fcl", "fmt")
    on_load("windows", "linux", "macosx", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "if(TARGET dart)", "if(FALSE)", {plain = true})
        io.replace("python/CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        io.replace("python/CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})
        io.replace("python/CMakeLists.txt", "add_subdirectory(tutorials)", "", {plain = true})
        io.replace("cmake/DARTFindBoost.txt", "set(Boost_USE_STATIC_RUNTIME OFF)", "", {plain = true})
        local configs = {
            "-DDART_SKIP_lz4=ON",
            "-DDART_SKIP_flann=ON",
            "-DDART_SKIP_IPOPT=ON",
            "-DDART_SKIP_pagmo=ON",
            "-DDART_SKIP_DOXYGEN=ON",
            "-DBoost_USE_STATIC_LIBS=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            table.insert(configs, "-DDART_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "/MT" or "/MD"))
        end
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DDART_SKIP_" .. dep .. "=" .. (package:config(config) and "OFF" or "ON"))
        end
        table.insert(configs, "-DDART_BUILD_DARTPY=" .. (package:config("dartpy") and "ON" or "OFF"))
        table.insert(configs, "-DDART_BUILD_GUI_OSG=" .. (package:config("openscenegraph") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        print(os.files(package:installdir("include", "**")))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dart/dart.hpp>
            #include <dart/utils/utils.hpp>
            void test() {
                auto world = utils::SkelParser::readWorld("dart://sample/skel/shapes.skel");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
