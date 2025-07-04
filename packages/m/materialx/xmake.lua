package("materialx")
    set_homepage("http://www.materialx.org/")
    set_description("MaterialX is an open standard for the exchange of rich material and look-development content across applications and renderers.")
    set_license("Apache-2.0")

    set_urls("https://github.com/AcademySoftwareFoundation/MaterialX/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/MaterialX.git", {submodules = false})

    add_versions("v1.39.3", "a72ac8470dea1148c0258d63b5b34605cbac580e4a3f2c624c5bdf4df7204363")
    add_versions("v1.39.0", "cc470da839cdc0e31e4b46ee46ff434d858c38c803b1d4a1012ed12546ace541")
    add_versions("v1.38.10", "706f44100188bc283a135ad24b348e55b405ac9e70cb64b7457c381383cc2887")

    add_configs("openimageio", {description = "Build OpenImageIO support for MaterialXRender.", default = false, type = "boolean"})
    add_configs("opencolorio", {description = "Build OpenColorIO support for shader generators.", default = false, type = "boolean"})
    add_configs("monolithic", {description = "Build single shared library", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "dl")
    end

    add_deps("cmake")
    if is_plat("linux") then
        add_deps("libxt")
    end

    on_load(function (package)
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

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)", "", {plain = true})

        local configs = {
            "-DMATERIALX_BUILD_TESTS=OFF",
            "-DMATERIALX_TEST_RENDER=OFF",
            "-DMATERIALX_BUILD_USE_CCACHE=OFF",
            "-DMATERIALX_INSTALL_RESOURCES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMATERIALX_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMATERIALX_BUILD_MONOLITHIC=" .. (package:config("monolithic") and "ON" or "OFF"))

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
