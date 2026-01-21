package("dartsim")

    set_homepage("https://dartsim.github.io/")
    set_description("Dynamic Animation and Robotics Toolkit")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/dartsim/dart/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dartsim/dart.git")
    add_versions("v6.16.1", "aa500b222d9ebc7cf98eae2e6531dd82b4f1fa6ae09be09fb7205795bedd4db5")
    add_versions("v6.15.0", "bbf954e283f464f6d0a8a5ab43ce92fd49ced357ccdd986c7cb4c29152df8692")
    add_versions("v6.14.5", "eb89cc01f4f48c399b055d462d8ecd2a3f846f825a35ffc67f259186b362e136")
    add_versions("v6.14.4", "f5fc7f5cb1269cc127a1ff69be26247b9f3617ce04ff1c80c0f3f6abc7d9ab70")
    add_versions("v6.13.0", "4da3ff8cee056252a558b05625a5ff29b21e71f2995e6d7f789abbf6261895f7")
    add_versions("v6.14.2", "6bbaf452f8182b97bf22adeab6cc7f3dc1cd2733358543131fa130e07c0860fc")

    add_patches("6.x", "patches/6.14.5/dartpy.patch", "c8f989317ac8e20259a91e76d28b986b3d4bda01a8e4d0fc13704f6e4f0e144b")

    add_configs("dartpy", {description = "Build dartpy interface.", default = false, type = "boolean"})
    add_configs("gui",   {description = "Build GLUT GUI.", default = false, type = "boolean"})
    local configdeps = {bullet3 = "Bullet",
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
        -- https://gitlab.kitware.com/cmake/cmake/-/issues/20222
        set_policy("package.cmake_generator.ninja", false)
    end

    set_policy("platform.longpaths", true)

    add_deps("cmake")
    add_deps("assimp", "libccd", "eigen", "fcl", "octomap", "fmt")
    on_load("windows|x64", "linux", "macosx", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
        if package:config("gui") or package:config("dartpy") then
            package:add("deps", "glut")
        end
        if package:config("dartpy") then
            package:add("deps", "tinyxml2")
            package:add("deps", "urdfdom")
            package:add("deps", "openscenegraph")
            package:add("deps", "imgui", {configs = {opengl2 = true}})
            package:add("deps", "python 3.x")
            package:add("deps", "pybind11")
        end
        if package:config("openscenegraph") then
            package:add("deps", "imgui", {configs = {opengl2 = true}})
        end
    end)

    on_install("windows|x64", "linux", "macosx", function (package)
        import("detect.tools.find_python3")

        -- remove after xmake 2.9.7
        io.insert("CMakeLists.txt", 1, "set(CMAKE_MODULE_LINKER_FLAGS \"${CMAKE_SHARED_LINKER_FLAGS}\")\n")
        io.replace("CMakeLists.txt", "/GL", "", {plain = true})
        io.replace("CMakeLists.txt", "if(TARGET dart)", "if(FALSE)", {plain = true})
        io.replace("CMakeLists.txt", "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32 -D_CRT_SECURE_NO_WARNINGS", {plain = true})
        io.replace("CMakeLists.txt", "CMAKE_SHARED_LINKER_FLAGS \"-Wl,--no-undefined\"", "CMAKE_SHARED_LINKER_FLAGS \"${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined\"", {plain = true})
        io.replace("dart/CMakeLists.txt", "/LTCG", "", {plain = true})
        io.replace("cmake/DARTFindDependencies.cmake", "dart_check_required_package(assimp \"assimp\")", "dart_check_required_package(assimp \"assimp\")\nfind_package(ZLIB)\ntarget_link_libraries(assimp INTERFACE ZLIB::ZLIB)", {plain = true})
        io.replace("cmake/DARTFindDependencies.cmake", "dart_check_required_package(fcl \"fcl\")", "dart_check_required_package(fcl \"fcl\")\ntarget_link_libraries(fcl INTERFACE ccd)", {plain = true})
        io.replace("cmake/DARTFindDependencies.cmake", "check_cxx_source_compiles%(.-\".-\".-(ASSIMP.-DEFINED)%)", "set(%1 1)")
        io.replace("cmake/DARTFindOpenSceneGraph.cmake", "osg osgViewer osgManipulator osgGA osgDB osgShadow osgUtil", "osgManipulator osgShadow osgViewer osgGA osgDB osgUtil osg", {plain = true})
        io.replace("cmake/DARTFindOpenSceneGraph.cmake", "target_link_libraries(osg::osg", "target_compile_definitions(osg::osg INTERFACE OSG_LIBRARY_STATIC)\ntarget_link_libraries(osg::osg", {plain = true})
        local glut_extra = "find_package(GLUT QUIET MODULE)\ntarget_compile_definitions(GLUT::GLUT INTERFACE FREEGLUT_STATIC)"
        if package:is_plat("linux") then
            glut_extra = glut_extra .. "\ntarget_link_libraries(GLUT::GLUT INTERFACE Xrandr Xrender Xxf86vm X11)"
        end
        io.replace("cmake/DARTFindGLUT.cmake", "find_package(GLUT QUIET MODULE)", glut_extra, {plain = true})
        local configs = {
            "-DDART_USE_SYSTEM_IMGUI=ON",
            "-DDART_SKIP_lz4=ON",
            "-DDART_SKIP_flann=ON",
            "-DDART_SKIP_IPOPT=ON",
            "-DDART_SKIP_pagmo=ON",
            "-DDART_SKIP_DOXYGEN=ON",
            "-DDART_TREAT_WARNINGS_AS_ERRORS=OFF",
            "-DDART_VERBOSE=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DDART_SKIP_" .. dep .. "=" .. (package:dep(config) and "OFF" or "ON"))
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DDART_RUNTIME_LIBRARY=" .. (package:has_runtime("MT", "MTd") and "/MT" or "/MD"))
        end
        table.insert(configs, "-DDART_BUILD_DARTPY=" .. (package:config("dartpy") and "ON" or "OFF"))
        table.insert(configs, "-DDART_SKIP_GLUT=" .. ((package:config("gui") or package:config("dartpy")) and "OFF" or "ON"))
        table.insert(configs, "-DDART_BUILD_GUI_OSG=" .. (package:dep("openscenegraph") and "ON" or "OFF"))
        if package:config("dartpy") then
            local python = find_python3()
            local pythondir = path.directory(python)
            if pythondir and path.is_absolute(pythondir) then
                table.insert(configs, "-DPython_ROOT_DIR=" .. pythondir)
                table.insert(configs, "-DPython3_ROOT_DIR=" .. pythondir)
            end
        end
        local deps = {"imgui"}
        if package:is_plat("linux") then
            table.insert(deps, "freeglut")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = deps})
        local suffix = package:is_debug() and "d" or ""
        for _, lib in ipairs({"dart-collision-bullet", "dart-collision-ode", "dart-gui-osg", "dart-gui", "dart-optimizer-ipopt", "dart-optimizer-nlopt", "dart-optimizer-pagmo", "dart-utils-urdf", "dart-utils", "dart", "dart-external-odelcpsolver", "dart-external-lodepng"}) do
            package:add("links", lib .. suffix)
        end
        if package:config("dartpy") then
            os.vrunv("python", {"-m", "pip", "install", "numpy"})
            local pythonpath = path.join(package:installdir("lib"), "site-packages")
            package:addenv("PYTHONPATH", pythonpath)
            if package:is_plat("windows") then
                -- after python3.8 dll can not be loaded from PATH
                for _, lib in ipairs(package:librarydeps()) do
                    if lib:name() ~= "python" then
                        local fetchinfo = lib:fetch()
                        local libfiles = fetchinfo and fetchinfo.libfiles or {}
                        for _, file in ipairs(libfiles) do
                            if file:endswith(".dll") then
                                os.trycp(file, pythonpath)
                            end
                        end
                    end
                end
                if package:config("shared") then
                    os.trycp(path.join(package:installdir("bin"), "*.dll"), pythonpath)
                end
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dart/dart.hpp>
            void test() {
                dart::simulation::WorldPtr world = dart::simulation::World::create();
            }
        ]]}, {configs = {languages = "c++17"}}))
        if package:config("dartpy") then
            local python = package:is_plat("windows") and "python" or "python3"
            os.vrunv(python, {"-c", "import dartpy"})
        end
    end)
