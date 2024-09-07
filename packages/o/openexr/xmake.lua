package("openexr")

    set_homepage("https://www.openexr.com/")
    set_description("OpenEXR provides the specification and reference implementation of the EXR file format, the professional-grade image storage format of the motion picture industry.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/openexr.git")
    add_versions("v3.2.4", "81e6518f2c4656fdeaf18a018f135e96a96e7f66dbe1c1f05860dd94772176cc")
    add_versions("v3.2.3", "f3f6c4165694d5c09e478a791eae69847cadb1333a2948ca222aa09f145eba63")
    add_versions("v2.5.3", "6a6525e6e3907715c6a55887716d7e42d09b54d2457323fcee35a0376960bebf")
    add_versions("v2.5.5", "59e98361cb31456a9634378d0f653a2b9554b8900f233450f2396ff495ea76b3")
    add_versions("v2.5.7", "36ecb2290cba6fc92b2ec9357f8dc0e364b4f9a90d727bf9a57c84760695272d")
    add_versions("v3.1.0", "8c2ff765368a28e8210af741ddf91506cef40f1ed0f1a08b6b73bb3a7faf8d93")
    add_versions("v3.1.1", "045254e201c0f87d1d1a4b2b5815c4ae54845af2e6ec0ab88e979b5fdb30a86e")
    add_versions("v3.1.3", "6f70a624d1321319d8269a911c4032f24950cde52e76f46e9ecbebfcb762f28c")
    add_versions("v3.1.4", "cb019c3c69ada47fe340f7fa6c8b863ca0515804dc60bdb25c942c1da886930b")
    add_versions("v3.1.5", "93925805c1fc4f8162b35f0ae109c4a75344e6decae5a240afdfce25f8a433ec")
    add_versions("v3.2.1", "61e175aa2203399fb3c8c2288752fbea3c2637680d50b6e306ea5f8ffdd46a9b")

    add_deps("cmake")
    add_deps("zlib")

    add_configs("build_both", {description = "Build both static library and shared library. (deprecated)", default = false, type = "boolean"})

    add_includedirs("include/OpenEXR", "include")

    on_load("windows", "macosx", "linux", "mingw@windows", "mingw@msys", function (package)
        local ver = package:version()
        local suffix = format("-%d_%d", ver:major(), ver:minor())
        local links = {}
        if ver:ge("3.0") then
            package:add("deps", "imath")
            links = {"OpenEXRUtil", "OpenEXR", "OpenEXRCore", "IlmThread", "Iex"}
        else
            links = {"IlmImfUtil", "IlmImf", "IlmThread", "Imath", "Half", "IexMath", "Iex"}
        end
        for _, link in ipairs(links) do
            package:add("links", link .. suffix)
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "OPENEXR_DLL")
        end
    end)

    on_install("macosx", "linux", "windows|x64", "windows|x86", "mingw@windows", "mingw@msys", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DINSTALL_OPENEXR_EXAMPLES=OFF", "-DINSTALL_OPENEXR_DOCS=OFF", "-DOPENEXR_BUILD_UTILS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:version():ge("3.0") then
            if package:is_plat("windows") and package:version():le("3.1.4") then
                local vs_toolset = import("core.tool.toolchain").load("msvc"):config("vs_toolset")
                if vs_toolset then
                    local toolsetver = vs_toolset:match("(%d+%.%d+)%.%d+")
                    assert(tonumber(toolsetver) < 14.31, "This version is incompatible with MSVC 14.31.")
                end
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
