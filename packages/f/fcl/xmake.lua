package("fcl")
    set_homepage("https://github.com/flexible-collision-library/fcl")
    set_description("Flexible Collision Library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/flexible-collision-library/fcl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/flexible-collision-library/fcl.git")

    add_versions("0.7.0", "90409e940b24045987506a6b239424a4222e2daf648c86dd146cbcb692ebdcbc")
    add_versions("0.6.1", "c8a68de8d35a4a5cd563411e7577c0dc2c626aba1eef288cb1ca88561f8d8019")

    add_patches("0.6.1", "patches/0.6.1/fix_arm.diff", "57b7a0d6f5991a5d26fadd3ff2968a5192906aa922703723865f7da0a1cfac58")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("octomap", {description = "Enable OctoMap library support.", default = false, type = "boolean"})

    add_deps("cmake", "eigen", "libccd")

    on_load(function (package)
        if package:config("octomap") then
            package:add("deps", "octomap")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DFCL_BUILD_TESTS=OFF"} 
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DFCL_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DFCL_WITH_OCTOMAP=" .. (package:config("octomap") and "ON" or "OFF"))
        if package:dep("eigen") and package:dep("eigen"):version() and package:dep("eigen"):version():ge("5.0.0") then
            io.replace("CMakeLists.txt", [[set(PKG_CFLAGS "-std=c++11")]], [[set(PKG_CFLAGS "-std=c++14")]], {plain=true})
            local content, err = io.replace("CMakeModules/CompilerSettings.cmake", "-std=c++11", "-std=c++14", {plain=true})
            io.replace("include/fcl/geometry/shape/convex-inl.h", "#include <map>", "#include <cassert>\n#include <map>", {plain = true})
            io.replace("include/fcl/math/motion/taylor_model/taylor_model-inl.h", [[#include "fcl/math/motion/taylor_model/taylor_model.h"]], [[#include <cassert>
#include "fcl/math/motion/taylor_model/taylor_model.h"]], {plain = true})
            io.replace("include/fcl/math/geometry-inl.h", [[#include "fcl/math/geometry.h"]], [[#include <cassert>
#include "fcl/math/geometry.h"]], {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local eigen_ver = package:dep("eigen") and package:dep("eigen"):version()
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace fcl;
                VectorN<double, 4> upper, lower;
                for (int i = 0; i < 4; ++i)
                    upper[i] = 1.;
                SamplerR<double, 4> sampler(lower, upper);
                auto sp = sampler.sample();
            }   
        ]]}, {configs = {languages = (eigen_ver and eigen_ver:lt("5.0.0") and "c++11" or "c++14")}, includes = "fcl/math/sampler/sampler_r.h"}))
    end)
