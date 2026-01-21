package("opencolorio")
    set_homepage("https://opencolorio.org/")
    set_description("A complete color management solution geared towards motion picture production with an emphasis on visual effects and computer animation.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AcademySoftwareFoundation/OpenColorIO/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/OpenColorIO.git")

    add_versions("v2.5.0", "124e2bfa8a9071959d6ddbb64ffbf78d3f6fe3c923ae23e96a6bbadde1af55b6")
    add_versions("v2.4.2", "2d8f2c47c40476d6e8cea9d878f6601d04f6d5642b47018eaafa9e9f833f3690")
    add_versions("v2.3.2", "6bbf4e7fa4ea2f743a238cb22aff44890425771a2f57f62cece1574e46ceec2f")
    add_versions("v2.1.1", "16ebc3e0f21f72dbe90fe60437eb864f4d4de9c255ef8e212f837824fc9b8d9c")
    add_versions("v2.1.0", "81fc7853a490031632a69c73716bc6ac271b395e2ba0e2587af9995c2b0efb5f")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows") then
        add_syslinks("user32", "gdi32")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreGraphics", "ColorSync", "IOKit")
    end

    add_deps("cmake")
    add_deps("expat", "yaml-cpp", "imath", "pystring")

    on_check("windows|arm64", function (package)
        if not package:is_cross() then
            raise("package(opencolorio) unsupported windows arm64 native build")
        end
    end)

    on_load(function (package)
        if package:version() and package:version():ge("2.2.0") then
            package:add("deps", "minizip-ng")
        end

        if not package:config("shared") and package:is_plat("windows") then
            package:add("defines", "OpenColorIO_SKIP_IMPORTS")
        end
    end)

    on_install("!mingw and !iphoneos", function (package)
        local minizip_ng = package:dep("minizip-ng")
        local version = package:version()
        if version then
            -- Fix GCC 15
            if version:ge("2.3.0") then
                io.replace("include/OpenColorIO/OpenColorIO.h", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
            end
            if version:lt("2.4.0") then
                io.replace("src/OpenColorIO/FileRules.cpp", "#include <cctype>", "#include <cctype>\n#include <cstring>", {plain = true})
            end
            if version:lt("2.3.0") then
                os.rm("share/cmake/modules/Findyaml-cpp.cmake")
                io.replace("src/OpenColorIO/CMakeLists.txt", "yaml-cpp", "yaml-cpp::yaml-cpp", {plain = true})
            end
        end

        local configs = {"-DOCIO_BUILD_APPS=OFF", "-DOCIO_BUILD_OPENFX=OFF", "-DOCIO_BUILD_PYTHON=OFF", "-DOCIO_BUILD_DOCS=OFF", "-DOCIO_BUILD_TESTS=OFF", "-DOCIO_BUILD_GPU_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local opt = {}
        if minizip_ng then
            opt.packagedeps = "minizip-ng"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <OpenColorIO/OpenColorIO.h>
            namespace OCIO = OCIO_NAMESPACE;
            void test() {
                OCIO::ConstConfigRcPtr config = OCIO::GetCurrentConfig();
                OCIO::ConstProcessorRcPtr processor =
                    config->getProcessor(OCIO::ROLE_COMPOSITING_LOG, OCIO::ROLE_SCENE_LINEAR);
                OCIO::ConstCPUProcessorRcPtr cpu = processor->getDefaultCPUProcessor();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
