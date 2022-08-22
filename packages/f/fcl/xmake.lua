package("fcl")

    set_homepage("https://github.com/flexible-collision-library/fcl")
    set_description("Flexible Collision Library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/flexible-collision-library/fcl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/flexible-collision-library/fcl.git")
    add_versions("v0.6.1", "c8a68de8d35a4a5cd563411e7577c0dc2c626aba1eef288cb1ca88561f8d8019")
    add_versions("v0.7.0", "90409e940b24045987506a6b239424a4222e2daf648c86dd146cbcb692ebdcbc")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("eigen", "libccd", "octomap")
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DFCL_BUILD_TESTS=OFF"} 
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DFCL_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace fcl;
                VectorN<double, 4> upper, lower;
                for (int i = 0; i < 4; ++i)
                    upper[i] = 1.;
                SamplerR<double, 4> sampler(lower, upper);
                auto sp = sampler.sample();
            }   
        ]]}, {configs = {languages = "c++14"}, includes = "fcl/math/sampler/sampler_r.h"}))
    end)
