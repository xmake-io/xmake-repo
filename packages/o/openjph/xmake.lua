package("openjph")
    set_homepage("https://github.com/aous72/OpenJPH")
    set_description("Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K) ")
    set_license("BSD-2-Clause")
    
    add_urls("https://github.com/aous72/OpenJPH/archive/refs/tags/$(version).zip"
        ,"https://github.com/aous72/OpenJPH.git")
    add_versions("0.24.1","c9914d98c40262fb10941ff5d263bd671d133cd3572ec8d4c62151700ffa580e")
    add_deps("cmake")
        on_check("android",function (package)
        -- 检查 NDK 版本
        --local ndk_version = os.getenv("NDK_VERSION") or "unknown"
        local config_ndk_version = package:config("ndk_version")
        if config_ndk_version < 24 then
            assert(false,"ndk ver too low")
        end
    end)
    on_install(function (package)
	    local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ojph::point x;
                x.x;
            }
        ]]}, {languages = "c++11",includes = {"openjph/ojph_base.h"}}))
    end)