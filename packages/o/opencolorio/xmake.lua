package("opencolorio")

    set_homepage("https://opencolorio.org/")
    set_description("A complete color management solution geared towards motion picture production with an emphasis on visual effects and computer animation.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AcademySoftwareFoundation/OpenColorIO/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/OpenColorIO.git")
    add_versions("v2.3.2", "6bbf4e7fa4ea2f743a238cb22aff44890425771a2f57f62cece1574e46ceec2f")
    add_versions("v2.1.0", "81fc7853a490031632a69c73716bc6ac271b395e2ba0e2587af9995c2b0efb5f")
    add_versions("v2.1.1", "16ebc3e0f21f72dbe90fe60437eb864f4d4de9c255ef8e212f837824fc9b8d9c")

    add_deps("cmake", "expat", "yaml-cpp", "imath", "pystring")
    if is_plat("windows") then
        add_syslinks("user32", "gdi32")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreGraphics", "ColorSync", "IOKit")
    end
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "OpenColorIO_SKIP_IMPORTS")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DOCIO_BUILD_APPS=OFF", "-DOCIO_BUILD_OPENFX=OFF", "-DOCIO_BUILD_PYTHON=OFF", "-DOCIO_BUILD_DOCS=OFF", "-DOCIO_BUILD_TESTS=OFF", "-DOCIO_BUILD_GPU_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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
