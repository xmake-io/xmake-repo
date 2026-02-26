package("manifold")
    set_homepage("https://github.com/elalish/manifold")
    set_description("A Geometry library for topological robustness")
    set_license("Apache-2.0")

    set_urls("https://github.com/elalish/manifold/archive/refs/tags/$(version).tar.gz",
             "https://github.com/elalish/manifold.git")

    add_versions("v3.3.2", "92a37034c407156f71446f9ca03bd4487adeb1b8246a03d1c047b859b1b9d211")
    add_versions("v3.2.1", "c2fddb0f4b2289caff660b29677883f0324415a9901f8f2aed4c83851f994c13")

    add_configs("parallel", { description = "Enable parallel processing", default = false, type = "boolean"})
    add_configs("cross_section", { description = "Enable 2d simple operation", default = false, type = "boolean" })
    add_configs("exporter", { description = "Enable exporting models", default = false, type = "boolean" })
    add_configs("tracy", { description = "Enable profiling", default = false, type = "boolean" })
    add_configs("cbind", { description = "Enable c binding", default = true, type = "boolean" })

    add_deps("cmake")
    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 26, "package(manifold): need ndk api level >= 26 for android")
        end)
    end

    on_load(function(package)
        if package:config("exporter") then
            package:add("deps", "assimp")
        end

        if package:config("parallel") then
            package:add("deps", "tbb")
        end

        if package:config("cross_section") then
            package:add("deps", "clipper2")
        end
    end)

    on_install(function (package)
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "return()", "", {plain = true})
        end

        io.replace("src/quickhull.cpp", [[#include <limits>]], [[#include <limits>
#include <unordered_map>
#include <cstddef>]], {plain = true})
        io.replace("src/smoothing.cpp", [[#include "parallel.h"]], [[#include "parallel.h"
#include <unordered_map>]], {plain = true})
        io.replace("src/subdivision.cpp", [[#include "parallel.h"]], [[#include "parallel.h"
#include <unordered_map>]], {plain = true})
        io.replace("src/disjoint_sets.h", "for (size_t", "for (std::size_t", {plain = true})

        local configs = {
            "-DMANIFOLD_STRICT=OFF",
            "-DMANIFOLD_TEST=OFF",
            "-DMANIFOLD_DOWNLOADS=OFF",
            "-DMANIFOLD_JSBIND=OFF",
            "-DMANIFOLD_PYBIND=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DMANIFOLD_CBIND=" .. (package:config("cbind") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_PAR=" .. (package:config("parallel") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_CROSS_SECTION=" .. (package:config("cross_section") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_EXPORT=" .. (package:config("exporter") and "ON" or "OFF"))
        table.insert(configs, "-DTRACY_ENABLE=" .. (package:config("tracy") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_ASSERT=" .. (package:is_debug() and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <manifold/manifold.h>
            void test() {
                manifold::Manifold cube = manifold::Manifold::Cube({1, 1, 1});
                (void)cube;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
