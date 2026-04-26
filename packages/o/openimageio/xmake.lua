package("openimageio")

    set_homepage("https://sites.google.com/site/openimageio/home")
    set_description("OpenImageIO is a library for reading and writing images, and a bunch of related classes, utilities, and applications.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AcademySoftwareFoundation/OpenImageIO/releases/download/v$(version)/OpenImageIO-$(version).tar.gz", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("2.5.19+1", "8e3d7473d7a42e527426c38c35187519488ea2a34e994782bd3e6504a209719f")
    add_versions("3.1.12+0", "704511376faf32767cdcd9aa9a6d0be2b03b91f849ad9008227dc9f0e14bc265")

    add_deps("cmake")
    add_deps("boost", {configs = {filesystem = true, system = true, thread = true, stacktrace = true}})
    add_deps("opencolorio", "zlib", "libtiff", "openexr", "libjpeg-turbo", "pugixml", "libpng", "robin-map", "fmt")
    local configdeps = {bzip2       = "BZip2",
                        freetype    = "Freetype",
                        opencv      = "OpenCV",
                        tbb         = "TBB",
                        giflib      = "GIF",
                        libheif     = "Libheif",
                        openjpeg    = "OpenJPEG",
                        openvdb     = "OpenVDB",
                        ptex        = "Ptex",
                        libwebp     = "WebP",
                        libraw      = "LibRaw",
                        libultrahdr = "libuhdr",
                        dcmtk       = "DCMTK",
                        ffmpeg      = "FFmpeg"}
    for conf, dep in pairs(configdeps) do
        add_configs(conf, {description = "Build with " .. conf .. " support.", default = false, type = "boolean"})
    end
    add_configs("tools",  {description = "Build OpenImageIO tools.", default = false, type = "boolean"})
    add_configs("python", {description = "Build python bindings.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("shell32")
    end

    on_load("windows|!arm64", "macosx", "linux", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "OIIO_STATIC_DEFINE")
        end
        for conf, dep in pairs(configdeps) do
            if package:config(conf) then
                if (conf == "libwebp") then
                    package:add("deps", conf, {configs = {libwebpmux = true}})
                else
                    package:add("deps", conf)
                end
            end
        end
        if package:config("python") then
            package:add("deps", "python 3.x")
            package:add("deps", "pybind11")
        end
        if package:config("debug") then
            package:add("links", "OpenImageIO_d", "OpenImageIO_Util_d")
        else
            package:add("links", "OpenImageIO", "OpenImageIO_Util")
        end
    end)

    on_install("windows|!arm64", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "NOT ${PROJECT_NAME}_IS_SUBPROJECT", "TRUE", {plain = true})
        io.replace("src/png.imageio/png_pvt.h", "#include <libpng16/png.h>", "#include <png.h>", {plain = true})
        local configs = {"-DBUILD_DOCS=OFF",
                         "-DINSTALL_DOCS=OFF",
                         "-DOIIO_BUILD_TESTS=OFF",
                         "-DUSE_QT=OFF",
                         "-DUSE_EXTERNAL_PUGIXML=ON",
                         "-DLINKSTATIC=ON",
                         "-DBoost_USE_STATIC_LIBS=ON",
                         "-DCMAKE_FIND_FRAMEWORK=LAST",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_Nuke=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_R3DSDK=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end
        for conf, dep in pairs(configdeps) do
            table.insert(configs, "-DUSE_" .. dep .. "=" .. (package:config(conf) and "ON" or "OFF"))
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. dep .. "=" .. (package:config(conf) and "OFF" or "ON"))
        end
        table.insert(configs, "-DOIIO_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_PYTHON=" .. (package:config("python") and "ON" or "OFF"))
        if package:config("python") then
            os.vrunv("python", {"-m", "pip", "install", "numpy"})
        end
        ext = {packagedeps = {"minizip-ng", "openssl"}}
        if package:is_plat("windows") then
            ext.cxflags = "/utf-8"
        end
        import("package.tools.cmake").install(package, configs, ext)
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
