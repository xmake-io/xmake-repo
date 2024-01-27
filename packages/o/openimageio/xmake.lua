package("openimageio")

    set_homepage("https://sites.google.com/site/openimageio/home")
    set_description("OpenImageIO is a library for reading and writing images, and a bunch of related classes, utilities, and applications.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/OpenImageIO/oiio/archive/refs/tags/v$(version).zip", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("2.2.19+0", "30a494ccfc2ee951fabbdf308d1b59eddb1a21aa5276887fe6a6fc874454794e")
    add_versions("2.3.10+1", "48ce9b9c3e815885f5634438fed3e240ad186fd9e30d392e17564b5e9eebb089")
    add_versions("2.3.13+0", "4b42e10c93e9954fc89287b9a187c78539c49d16c2947fc140b1452860a54c26")

    add_deps("cmake")
    add_deps("boost", {configs = {filesystem = true, system = true, thread = true}})
    add_deps("zlib", "libtiff", "openexr", "libjpeg-turbo", "pugixml", "libpng", "robin-map", "libsquish", "fmt")
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

    if is_plat("windows") then
        add_syslinks("shell32")
    end
    add_links("OpenImageIO", "OpenImageIO_Util")

    on_load("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "OIIO_STATIC_DEFINE")
        end
        for conf, dep in pairs(configdeps) do
            if package:config(conf) then
                package:add("deps", conf)
            end
        end
        if package:config("python") then
            package:add("deps", "python 3.x")
            package:add("deps", "pybind11")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "NOT ${PROJECT_NAME}_IS_SUBPROJECT", "TRUE", {plain = true})
        local configs = {"-DBUILD_DOCS=OFF",
                         "-DINSTALL_DOCS=OFF",
                         "-DOIIO_BUILD_TESTS=OFF",
                         "-DOIIO_BUILD_TOOLS=OFF",
                         "-DUSE_QT=OFF",
                         "-DUSE_EXTERNAL_PUGIXML=ON",
                         "-DLINKSTATIC=ON",
                         "-DBoost_USE_STATIC_LIBS=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_Nuke=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_R3DSDK=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. ((package:config("runtimes") and package:has_runtime("MT", "MTd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MT")) and "ON" or "OFF"))
        end
        for conf, dep in pairs(configdeps) do
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. dep .. "=" .. (package:config(conf) and "OFF" or "ON"))
        end
        table.insert(configs, "-DUSE_PYTHON=" .. (package:config("python") and "ON" or "OFF"))
        if package:config("python") then
            os.vrunv("python", {"-m", "pip", "install", "numpy"})
        end
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
