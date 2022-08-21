package("openscenegraph")

    set_homepage("https://www.openscenegraph.com/")
    set_description("The OpenSceneGraph is an open source high performance 3D graphics toolkit.")

    add_urls("https://github.com/openscenegraph/OpenSceneGraph/archive/refs/tags/OpenSceneGraph-$(version).tar.gz",
             "https://github.com/openscenegraph/OpenSceneGraph.git")
    add_versions("3.6.5", "aea196550f02974d6d09291c5d83b51ca6a03b3767e234a8c0e21322927d1e12")

    add_configs("tools", {description = "Enable to build OSG Applications.", default = false, type = "boolean"})

    local configdeps = {fontconfig = "fontconfig",
                        freetype   = "Freetype",
                        jasper     = "Jasper",
                        openexr    = "OpenEXR",
                        colladadom = "COLLADA",
                        dcmtk      = "DCMTK",
                        ffmpeg     = "FFmpeg",
                        glib       = "GLIB",
                        libsdl     = "SDL2",
                        nvtt       = "NVTT"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable the " .. config .. " plugin.", default = false, type = "boolean"})
    end

    add_deps("cmake")
    add_deps("libjpeg-turbo", "libpng", "giflib", "libtiff")
    on_load("windows", "linux", "macosx", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_OSG_EXAMPLES=OFF"}
        local disabled_packages = {"ilmbase", "Inventor", "OpenCascade", "FBX", "GDAL", "GTA", "CURL", "LibVNCServer", "GStreamer", "SDL", "Poppler", "RSVG", "GtkGl", "Asio", "ZeroConf", "LIBLAS"}
        for _, pkg in ipairs(disabled_packages) do
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. pkg .. "=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DDYNAMIC_OPENSCENEGRAPH=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDYNAMIC_OPENTHREADS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_OSG_APPLICATIONS=" .. (package:config("tools") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. dep .. "=" .. (package:config(config) and "OFF" or "ON"))
        end
        import("package.tools.cmake").install(package, configs)
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
