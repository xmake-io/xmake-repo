package("openimageio")
    set_homepage("https://sites.google.com/site/openimageio/home")
    set_description("OpenImageIO is a library for reading and writing images, and a bunch of related classes, utilities, and applications.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AcademySoftwareFoundation/OpenImageIO.git", {alias = "git"})
    add_urls("https://github.com/AcademySoftwareFoundation/OpenImageIO/archive/refs/tags/$(version).tar.gz", {version = function (version) return version:gsub("%+", ".") end})

    add_versions("v3.0.7+0", "2798e398b6ffd836ba7810e8ea510902a4aabc4a373ca0523a3f0d830c5eb103")
    add_versions("v2.5.18+0", "f57481435cec18633d3eba9b2e8c483fc1df6f0a01c5c9f98cbae6d1c52928e5")

    add_versions("git:v2.5.18+0", "v2.5.18.0")

    add_deps("cmake")
    add_deps("boost", {configs = {filesystem = true, system = true, thread = true, stacktrace = true}})
    add_deps("zlib", "libtiff", "openexr", "libjpeg-turbo", "pugixml", "libpng", "robin-map")
    local configdeps = {bzip2    = "BZip2",
                        freetype = "Freetype",
                        hdf5     = "HDF5",
                        opencv   = "OpenCV",
                        tbb      = "TBB",
                        giflib   = "GIF",
                        libheif  = "Libheif",
                        openjpeg = "OpenJPEG",
                        openvdb  = "OpenVDB",
                        ptex     = "Ptex",
                        libwebp  = "WebP",
                        libraw   = "LibRaw",
                        field3d  = "Field3D",
                        dcmtk    = "DCMTK",
                        ffmpeg   = "FFmpeg"}
    for conf, dep in pairs(configdeps) do
        add_configs(conf, {description = "Build with " .. conf .. " support.", default = (conf == "libwebp"), type = "boolean"})
    end
    add_configs("python", {description = "Build python bindings.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_links("OpenImageIO", "OpenImageIO_Util")
    if is_plat("windows") then
        add_syslinks("shell32")
    end

    on_load(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "OIIO_STATIC_DEFINE")
        end
        for conf, dep in pairs(configdeps) do
            if package:config(conf) then
                package:add("deps", conf)
            end
        end
        if package:version() and package:version():lt("2.4.2+3") then
            -- https://github.com/AcademySoftwareFoundation/OpenImageIO/commit/5e67c09ecede66cc26c05d7134934c1b92385e9a
            package:add("deps", "libsquish")
        end

        if package:is_plat("windows") then
            package:add("deps", "fmt <11")
        else
            package:add("deps", "fmt")
        end

        if package:config("python") then
            package:add("deps", "python 3.x")
            package:add("deps", "pybind11")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "NOT ${PROJECT_NAME}_IS_SUBPROJECT", "TRUE", {plain = true})
        io.replace("CMakeLists.txt", "include (packaging)", "", {plain = true})

        local configs = {
            "-DINSTALL_FONTS=OFF",
            "-DBUILD_DOCS=OFF",
            "-DINSTALL_DOCS=OFF",
            "-DOIIO_BUILD_TESTS=OFF",

            "-DCMAKE_DEBUG_POSTFIX=''",
            "-DUSE_CCACHE=OFF",

            "-DLINKSTATIC=ON", -- TODO: If OFF, it will add some define for all deps library, otherwise static link all library. maybe fix the cmake is better
            "-DUSE_QT=OFF",
            "-DUSE_EXTERNAL_PUGIXML=ON",
            "-DCMAKE_DISABLE_FIND_PACKAGE_Nuke=ON",
            "-DCMAKE_DISABLE_FIND_PACKAGE_R3DSDK=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DBoost_USE_STATIC_LIBS=" .. (package:dep("boost"):config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        end
        for conf, dep in pairs(configdeps) do
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. dep .. "=" .. (package:config(conf) and "OFF" or "ON"))
        end
        table.insert(configs, "-DUSE_PYTHON=" .. (package:config("python") and "ON" or "OFF"))
        table.insert(configs, "-DOIIO_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        -- if package:config("python") then
        --     os.vrunv("python", {"-m", "pip", "install", "numpy"})
        -- end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace OIIO;
                unsigned char pixels[640*480*3];
                std::unique_ptr<ImageOutput> out = ImageOutput::create("foo.jpg");
                ImageSpec spec(640, 480, 3, TypeDesc::UINT8);
                out->open("foo.jpg", spec);
                out->write_image(TypeDesc::UINT8, pixels);
                out->close();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "OpenImageIO/imageio.h"}))
    end)
