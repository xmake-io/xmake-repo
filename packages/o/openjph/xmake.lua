package("OpenJPH")
    set_homepage("https://github.com/aous72/OpenJPH")
    set_description("Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K) ")
    set_license("BSD-2")
    
    add_urls("https://github.com/aous72/OpenJPH/archive/refs/tags/$(version).zip","https://github.com/aous72/OpenJPH.git")
    add_versions("0.24.1","c9914d98c40262fb10941ff5d263bd671d133cd3572ec8d4c62151700ffa580e")
    add_deps("cmake")
    on_install(function (package)
        --table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ojph::point x;
                x.x;
            }
        ]]}, {includes = {"openjph/ojph_base.h"}}))
    end)