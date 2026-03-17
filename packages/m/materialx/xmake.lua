package("materialx")
    set_homepage("http://www.materialx.org/")
    set_description("MaterialX is an open standard for the exchange of rich material and look-development content across applications and renderers.")
    set_license("Apache-2.0")

    set_urls("https://github.com/AcademySoftwareFoundation/MaterialX/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/MaterialX.git", {submodules = false})

    add_versions("v1.39.4", "ce9c1a3b84a060d6280d355a72bf42b53837ee7bcc5a566cab1e927c64078fd9")
    add_versions("v1.39.3", "1f299d14c1243a4834e2363921d98465cc002b37e7f5cddb6f8747ab58fbf6d1")
    add_versions("v1.39.0", "cc470da839cdc0e31e4b46ee46ff434d858c38c803b1d4a1012ed12546ace541")
    add_versions("v1.38.10", "706f44100188bc283a135ad24b348e55b405ac9e70cb64b7457c381383cc2887")

    add_configs("glsl", {description = "Build the GLSL shader generator back-end.", default = false, type = "boolean"})
    add_configs("osl", {description = "Build the OSL shader generator back-end.", default = false, type = "boolean"})
    add_configs("mdl", {description = "Build the MDL shader generator back-end.", default = false, type = "boolean"})
    add_configs("msl", {description = "Build the MSL shader generator back-end.", default = false, type = "boolean"})
    add_configs("render", {description = "Build the MaterialX Render modules.", default = false, type = "boolean"})
    add_configs("render_platforms", {description = "Build platform-specific render modules for each shader generator.", default = true, type = "boolean"})
    add_configs("openimageio", {description = "Build OpenImageIO support for MaterialXRender.", default = false, type = "boolean"})
    add_configs("opencolorio", {description = "Build OpenColorIO support for shader generators.", default = false, type = "boolean"})
    add_configs("monolithic", {description = "Build single shared library", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "dl")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("render") and package:config("render_platforms") then
            if package:is_plat("linux") then
                package:add("deps", "libx11", "libxt")
            elseif package:is_plat("macosx") then
                package:add("deps", "opengl", {optional = true})
                package:add("frameworks", "Cocoa")
            end
        end
        
        if package:config("openimageio") then
            package:add("deps", "openimageio")
        end
        if package:config("opencolorio") then
            package:add("deps", "opencolorio")
        end

        if package:config("shared") then
            package:add("defines", "MATERIALX_BUILD_SHARED_LIBS")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)", "", {plain = true})
        if package:version() and package:version():lt("1.39.4") then
            -- fix gcc15
            io.replace("source/MaterialXCore/Library.h", "#include <algorithm>", "#include <algorithm>\n#include <cstdint>", {plain = true})
        end

        local configs = {
            "-DMATERIALX_BUILD_TESTS=OFF",
            "-DMATERIALX_TEST_RENDER=OFF",
            "-DMATERIALX_BUILD_USE_CCACHE=OFF",
            "-DMATERIALX_INSTALL_RESOURCES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMATERIALX_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_MONOLITHIC=" .. (package:config("monolithic") and "ON" or "OFF"))

        table.insert(configs, "-DMATERIALX_BUILD_GEN_GLSL=" .. (package:config("glsl") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_GEN_OSL=" .. (package:config("osl") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_GEN_MDL=" .. (package:config("mdl") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_GEN_MSL=" .. (package:config("msl") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_RENDER=" .. (package:config("render") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_RENDER_PLATFORMS=" .. (package:config("render_platforms") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_OIIO=" .. (package:config("openimageio") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_OCIO=" .. (package:config("opencolorio") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        os.trycp(path.join(package:buildir(), "source/MaterialXCore/Generated.h"), package:installdir("include/MaterialXCore"))
        os.tryrm(package:installdir("*.md"))
        os.tryrm(package:installdir("LICENSE"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <MaterialXCore/Document.h>
            void test() {
                MaterialX::DocumentPtr doc = MaterialX::createDocument();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
