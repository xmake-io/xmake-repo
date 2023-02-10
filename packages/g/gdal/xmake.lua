package("gdal")
    set_homepage("https://gdal.org/")
    set_description("GDAL is a translator library for raster and vector geospatial data formats by the Open Source Geospatial Foundation")
    set_license("MIT")

    add_urls("https://github.com/OSGeo/gdal/releases/download/v$(version)/gdal-$(version).tar.gz")
    add_versions("3.5.1", "7c4406ca010dc8632703a0a326f39e9db25d9f1f6ebaaeca64a963e3fac123d1")

    add_configs("apps", {description = "Build GDAL applications.", default = false, type = "boolean"})
    add_deps("cmake", "proj", "openjpeg")

    if is_plat("windows") then
        add_syslinks("wsock32", "ws2_32")
    end
 
    on_install("windows|x86", "windows|x64", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DGDAL_USE_EXTERNAL_LIBS=OFF", "-DGDAL_USE_OPENJPEG=ON",
                         "-DBUILD_JAVA_BINDINGS=OFF", "-DBUILD_CSHARP_BINDINGS=OFF", "-DBUILD_PYTHON_BINDINGS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_APPS=" .. (package:config("apps") and "ON" or "OFF"))
        
        --fix gdal compile on msvc debug mode
        local cxflags
        if package:debug() and package:is_plat("windows") then
            cxflags = "/FS"
        end
        import("package.tools.cmake").install(package, configs,
            {cxflags = cxflags, packagedeps = {"openjpeg", "proj"}})
        if package:config("apps") then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ogrsf_frmts.h>
            void test(int argc, char** argv) {
                GDALAllRegister();
            }]]}, {configs = {languages = "c++11"}, includes = "ogrsf_frmts.h"}))
    end)
