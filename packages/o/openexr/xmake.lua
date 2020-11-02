package("openexr")

    set_homepage("https://www.openexr.com/")
    set_description("OpenEXR provides the specification and reference implementation of the EXR file format, the professional-grade image storage format of the motion picture industry.")

    add_urls("https://github.com/AcademySoftwareFoundation/openexr/archive/v$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/openexr.git")

    add_versions("2.5.3", "6a6525e6e3907715c6a55887716d7e42d09b54d2457323fcee35a0376960bebf")

    add_deps("cmake")
    add_deps("zlib")

    add_configs("build_both", {description = "Build both static library and shared library.", default = true, type = "boolean"})

    on_install("macosx", "linux", "windows", "mingw", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DINSTALL_OPENEXR_EXAMPLES=OFF", "-DINSTALL_OPENEXR_DOCS=OFF", "-DOPENEXR_BUILD_UTILS=ON"}
        if package:config("build_both") then
            table.insert(configs, "-DOPENEXR_BUILD_BOTH_STATIC_SHARED=ON")
            table.insert(configs, "-DILMBASE_BUILD_BOTH_STATIC_SHARED=ON")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DPYILMBASE_ENABLE=" .. "OFF")
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <stdio.h>
            void test() {
                printf( OPENEXR_PACKAGE_STRING );
            }
        ]]}, {configs = {languages = "c++14"},
              includes = {"OpenEXR/OpenEXRConfig.h"}}))
    end)
