package("msdfgen")
    set_homepage("https://github.com/Chlumsky/msdfgen")
    set_description("Multi-channel signed distance field generator")
    set_license("MIT")

    add_urls("https://github.com/Chlumsky/msdfgen/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Chlumsky/msdfgen.git")
    add_versions("v1.10", "2754d1687bfb80968d9c682e0c4c04c8fcf72df1421d076baf44ea0d87aa3662")
    add_patches("v1.10", "https://github.com/Chlumsky/msdfgen/commit/839e0e86cb846e3ea0c0a3d5da97321fe81f91e4.patch", "f69096f65edb588dcb50529ac750fd5fb24b716e053cb9c33749e52219fd7df4")

    add_configs("extensions", {description = "Build extensions library (requires freetype, libpng and tinyxml2)", default = false, type = "boolean"})
    add_configs("openmpp", {description = "Build with OpenMP support for multi-threaded code", default = false, type = "boolean"})
    add_configs("skia", {description = "Build with the Skia library", default = false, type = "boolean"})
    add_configs("standalone", {description = "Build standalone executable", default = false, type = "boolean"})

    -- shared compilation is not supported on mingw/msys2 because of the "export all symbol" CMake feature
    if is_plat("mingw") and is_subhost("msys") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_load(function (package)
        if package:is_plat("windows", "mingw") and package:config("shared") then
            package:add("defines", "MSDFGEN_PUBLIC=__declspec(dllimport)")
        else
            package:add("defines", "MSDFGEN_PUBLIC=")
        end
        if package:config("extensions") or package:config("standalone") then
            package:add("deps", "freetype")
            package:add("deps", "libpng")
            package:add("deps", "tinyxml2")
            package:add("links", "msdfgen-ext")
            if package:config("skia") then
                package:add("deps", "skia")
            end
        end
        package:add("links", "msdfgen-core")
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DMSDFGEN_USE_VCPKG=OFF")
        table.insert(configs, "-DMSDFGEN_DYNAMIC_RUNTIME=OFF")
        table.insert(configs, "-DMSDFGEN_INSTALL=ON")
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMSDFGEN_CORE_ONLY=" .. ((package:config("extensions") or package:config("standalone")) and "OFF" or "ON"))
        table.insert(configs, "-DMSDFGEN_BUILD_STANDALONE=" .. (package:config("standalone") and "ON" or "OFF"))
        table.insert(configs, "-DMSDFGEN_USE_SKIA=" .. (package:config("skia") and "ON" or "OFF"))

        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", [[set(MSDFGEN_MSVC_RUNTIME "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], [[set(MSDFGEN_MSVC_RUNTIME, "${CMAKE_MSVC_RUNTIME_LIBRARY}")]], {plain = true})
        elseif package:is_plat("mingw") then
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_SUPPORT_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
            io.replace("CMakeLists.txt", [[if(BUILD_SHARED_LIBS AND WIN32)]], [[if(BUILD_SHARED_LIBS AND (WIN32 OR MINGW))]], {plain = true})
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace msdfgen;
                BitmapRef<float, 3> bitmap;
                Shape shape;
                Projection project;
                generateMSDF(bitmap, shape, project, 1.0);
            }
        ]]}, {configs = { languages = "c++11" }, includes = {"msdfgen/msdfgen.h"}}))

        if package:config("extensions") or package:config("standalone") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    using namespace msdfgen;
                    FreetypeHandle* ft = initializeFreetype();
                    FontHandle* font = loadFont(ft, "arialbd.ttf");

                    Shape shape;
                    loadGlyph(shape, font, 'A');
                    shape.normalize();
                    Bitmap<float, 3> msdf(32, 32);
                    generateMSDF(msdf, shape, 4.0, 1.0, Vector2(4.0, 4.0));
                    savePng(msdf, "output.png");

                    destroyFont(font);
                    deinitializeFreetype(ft);
                }
            ]]}, {configs = { languages = "c++11" }, includes = {"msdfgen/msdfgen.h", "msdfgen/msdfgen-ext.h"}}))

            if package:config("standalone") then
                os.vrun("msdfgen -help")
            end
        end
    end)
