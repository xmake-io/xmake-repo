package("openexr")

    set_homepage("https://www.openexr.com/")
    set_description("OpenEXR provides the specification and reference implementation of the EXR file format, the professional-grade image storage format of the motion picture industry.")

    add_urls("https://github.com/AcademySoftwareFoundation/openexr/archive/v$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/openexr.git")

    add_versions("2.5.3", "6a6525e6e3907715c6a55887716d7e42d09b54d2457323fcee35a0376960bebf")

    add_deps("cmake")
    add_deps("zlib")

    on_install("macosx", "linux", "windows", "mingw", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_OPENEXR_EXAMPLES=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
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
        ]]}, {configs = {defines = "c++14"},
              includes = {"OpenEXR/OpenEXRConfig.h"}}))
    end)
