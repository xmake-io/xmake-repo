package("msdfgen")
    set_homepage("https://github.com/Chlumsky/msdfgen")
    set_description("Multi-channel signed distance field generator")
    set_license("MIT")

    add_urls("https://github.com/Chlumsky/msdfgen/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Chlumsky/msdfgen.git")

    add_versions("v1.13", "93cd1ad8918c1a78c5c96e82d4f4c77f0eb86c2e7e8579a0967e54196c4b7167")
    add_versions("v1.12.1", "24541c9fbb459e8c62adeb3eb22cb21fa07a4b5091e2ae1f041d144a4baf08cd")
    add_versions("v1.12", "f058117496097217d12e4ea86adbff8467adaf6f12af793925d243b86b0c4f57")
    add_versions("v1.11", "fad74e33274f591e72511bc0546189e7aec439f2a512ef1b2fde243554d457cb")
    add_versions("v1.10", "2754d1687bfb80968d9c682e0c4c04c8fcf72df1421d076baf44ea0d87aa3662")

    add_patches("v1.10", "https://github.com/Chlumsky/msdfgen/commit/839e0e86cb846e3ea0c0a3d5da97321fe81f91e4.patch", "8b8ab53b66b4b8c27d78c2e617795e9818c5ba72a7a7cb7a75bc416fe4bfb26c")

    add_configs("extensions", {description = "Build extensions library (requires freetype, libpng and tinyxml2)", default = false, type = "boolean"})
    add_configs("openmp", {description = "Build with OpenMP support for multi-threaded code", default = false, type = "boolean"})
    add_configs("skia", {description = "Build with the Skia library", default = false, type = "boolean"})
    add_configs("standalone", {description = "Build standalone executable", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
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
        package:add("includedirs", "include", "include/msdfgen")
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
            io.replace("CMakeLists.txt", [[set(MSDFGEN_MSVC_RUNTIME "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")]], "", {plain = true})
            io.replace("CMakeLists.txt", [[set(MSDFGEN_MSVC_RUNTIME "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
        elseif package:is_plat("mingw") then
            io.replace("CMakeLists.txt", [[target_compile_definitions(msdfgen-core PRIVATE "MSDFGEN_PUBLIC=__declspec(dllexport)")]], "target_compile_definitions(msdfgen-core PRIVATE MSDFGEN_PUBLIC=)", {plain = true})
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

            if package:config("standalone") and (not package:is_cross()) then
                os.vrun("msdfgen -help")
            end
        end
    end)
