package("openscenegraph")
    set_homepage("https://www.openscenegraph.com/")
    set_description("The OpenSceneGraph is an open source high performance 3D graphics toolkit.")

    add_urls("https://github.com/openscenegraph/OpenSceneGraph/archive/refs/tags/OpenSceneGraph-$(version).tar.gz",
             "https://github.com/openscenegraph/OpenSceneGraph.git")
    add_versions("3.6.5", "aea196550f02974d6d09291c5d83b51ca6a03b3767e234a8c0e21322927d1e12")

    add_patches("3.6.5", "patches/3.6.5/msvc.patch", "57b2cc3e5017f7932c5d758346ef0ede8be70f3265276fd8e04534367474eb55")

    add_configs("tools", {description = "Enable to build OSG Applications.", default = false, type = "boolean"})

    local configdeps = {fontconfig = "fontconfig",
                        freetype   = "Freetype",
                        jasper     = "Jasper",
                        openexr    = "OpenEXR",
                        colladadom = "COLLADA",
                        dcmtk      = "DCMTK",
                        ffmpeg     = "FFmpeg",
                        glib       = "GLIB",
                        libsdl2    = "SDL2",
                        nvtt       = "NVTT"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable the " .. config .. " plugin.", default = false, type = "boolean"})
    end
    -- deprecated config
    add_configs("libsdl", {description = "Enable the libsdl2 plugin (deprecated, use libsdl2 config instead).", default = nil, type = "boolean"})

    set_policy("platform.longpaths", true)

    on_check("windows", function (package)
        import("core.tool.toolchain")

        local msvc = package:toolchain("msvc")
        if msvc and package:is_arch("arm.*") then
            local vs = msvc:config("vs")
            assert(vs and tonumber(vs) >= 2022, "package(openscenegraph/arm): need vs >= 2022")
        end
    end)

    add_deps("cmake")
    add_deps("libjpeg-turbo", "libpng", "giflib", "libtiff")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_load("windows", "linux", "macosx", function (package)
        if package:config("libsdl") ~= nil then
            wprint("package(openscenegraph): config libsdl has been renamed has been renamed to libsdl2 following the release of SDL3, please use libsdl2 config instead.${clear}")
            package:config_set("libsdl2", package:config("libsdl"))
        end
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "OSG_LIBRARY_STATIC")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "FIND_PACKAGE(TIFF)", "FIND_PACKAGE(TIFF CONFIG)", {plain = true})
        io.replace("src/osgPlugins/cfg/CMakeLists.txt", "-Wno-deprecated-register", "-Wno-deprecated-register -Wno-register", {plain = true})
        io.replace("src/osgPlugins/tiff/CMakeLists.txt", "TARGET_LIBRARIES_VARS TIFF_LIBRARY", "TARGET_EXTERNAL_LIBRARIES TIFF::tiff", {plain = true})
        local configs = {"-DBUILD_OSG_EXAMPLES=OFF", "-DOSG_MSVC_VERSIONED_DLL=OFF", "-DOSG_AGGRESSIVE_WARNINGS=OFF"}
        local disabled_packages = {"ilmbase", "Inventor", "OpenCascade", "FBX", "GDAL", "GTA", "CURL", "LibVNCServer", "GStreamer", "SDL", "Poppler", "RSVG", "GtkGl", "Asio", "ZeroConf", "LIBLAS"}
        for _, pkg in ipairs(disabled_packages) do
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. pkg .. "=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DDYNAMIC_OPENSCENEGRAPH=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDYNAMIC_OPENTHREADS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_OSG_APPLICATIONS=" .. (package:config("tools") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. dep .. "=" .. (package:config(config) and "OFF" or "ON"))
        end
        import("package.tools.cmake").install(package, configs)
        local suffix = package:is_debug() and "d" or ""
        for _, lib in ipairs({"osgPresentation", "osgSim", "osgShadow", "osgParticle", "osgAnimation", "osgManipulator", "osgTerrain", "osgVolume", "osgWidget", "osgUI", "osgViewer", "osgText", "osgFX", "osgGA", "osgDB", "osgUtil", "osg", "OpenThreads"}) do
            package:add("links", lib .. suffix)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char* argv[]) {
                bool help = false;
                osg::ArgumentParser arguments(&argc, argv);
                while(arguments.read("--help")) help = true;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "osg/ArgumentParser"}))
    end)
