package("openexr")

    set_homepage("https://www.openexr.com/")
    set_description("OpenEXR provides the specification and reference implementation of the EXR file format, the professional-grade image storage format of the motion picture industry.")

    add_urls("https://github.com/AcademySoftwareFoundation/openexr/archive/v$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/openexr.git")
    add_versions("2.5.3", "6a6525e6e3907715c6a55887716d7e42d09b54d2457323fcee35a0376960bebf")
    add_versions("2.5.5", "59e98361cb31456a9634378d0f653a2b9554b8900f233450f2396ff495ea76b3")
    add_versions("2.5.7", "36ecb2290cba6fc92b2ec9357f8dc0e364b4f9a90d727bf9a57c84760695272d")
    add_versions("3.1.0", "8c2ff765368a28e8210af741ddf91506cef40f1ed0f1a08b6b73bb3a7faf8d93")
    add_versions("3.1.1", "045254e201c0f87d1d1a4b2b5815c4ae54845af2e6ec0ab88e979b5fdb30a86e")

    add_deps("cmake")
    add_deps("zlib")

    -- deprecated
    add_configs("build_both", {description = "Build both static library and shared library.", default = false, type = "boolean"})

    on_load("windows", "macosx", "linux", "mingw@windows", "mingw@msys", function (package)
        if package:version():ge("3.0") then
            package:add("deps", "imath")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "OPENEXR_DLL")
        end
    end)

    on_install("macosx", "linux", "windows", "mingw@windows", "mingw@msys", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DINSTALL_OPENEXR_EXAMPLES=OFF", "-DINSTALL_OPENEXR_DOCS=OFF", "-DOPENEXR_BUILD_UTILS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:version():ge("3.0") then
            if package:is_plat("mingw") then
                raise("mingw is not supported in version 3.0")
            end
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        else
            if package:config("build_both") then
                table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
                table.insert(configs, "-DOPENEXR_BUILD_BOTH_STATIC_SHARED=ON")
                table.insert(configs, "-DILMBASE_BUILD_BOTH_STATIC_SHARED=ON")
            else
                table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
                table.insert(configs, "-DOPENEXR_BUILD_BOTH_STATIC_SHARED=OFF")
                table.insert(configs, "-DILMBASE_BUILD_BOTH_STATIC_SHARED=OFF")
            end
            table.insert(configs, "-DPYILMBASE_ENABLE=OFF")
        end
        table.insert(configs, "-DCMAKE_INSTALL_LIBDIR=lib")
        import("package.tools.cmake").install(package, configs)
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
