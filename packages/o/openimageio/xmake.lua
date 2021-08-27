package("openimageio")

    set_homepage("https://sites.google.com/site/openimageio/home")
    set_description("OpenImageIO is a library for reading and writing images, and a bunch of related classes, utilities, and applications.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/OpenImageIO/oiio/archive/refs/tags/v$(version).tar.gz", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("2.2.17+0", "b570da8928c3e8cde29bdb0e0320e727789e141c48375fb69a2548d642462396")

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
                        field3d  = "Field3D"}
    for conf, dep in pairs(configdeps) do
        add_configs(conf, {description = "Build with " .. conf .. " support.", default = (conf == "libwebp"), type = "boolean"})
    end
    add_configs("python", {description = "Build python bindings.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("shell32")
    end

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
                         "-DUSE_QT=OFF",
                         "-DUSE_EXTERNAL_PUGIXML=ON",
                         "-DLINKSTATIC=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_Nuke=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_DCMTK=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_R3DSDK=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
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
        ]]}, {configs = {languages = "c++11"}, includes = "OpenImageIO/imageio.h"}))
    end)
