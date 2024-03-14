package("pagmo")

    set_homepage("https://esa.github.io/pagmo2/index.html")
    set_description("pagmo is a C++ scientific library for massively parallel optimization.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/esa/pagmo2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/esa/pagmo2.git")
    add_versions("v2.19.0", "701ada528de7d454201e92a5d88903dd1c22ea64f43861d9694195ddfef82a70")
    add_versions("v2.18.0", "5ad40bf3aa91857a808d6b632d9e1020341a33f1a4115d7a2b78b78fd063ae31")

    local configdeps = {eigen = "EIGEN3", nlopt = "NLOPT", --[[ipopt = "IPOPT"]]}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable features against " .. config .. ".", default = true, type = "boolean"})
    end

    add_deps("cmake", "tbb <2021.0")
    add_deps("boost", {configs = {serialization = true}})
    on_load("windows", "macosx", "linux", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DCMAKE_INSTALL_LIBDIR=lib", "-DPAGMO_BUILD_TESTS=OFF", "-DBoost_USE_STATIC_LIBS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DPAGMO_BUILD_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DPAGMO_WITH_" .. dep .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <pagmo/algorithm.hpp>
            #include <pagmo/algorithms/sade.hpp>
            #include <pagmo/archipelago.hpp>
            #include <pagmo/problem.hpp>
            #include <pagmo/problems/schwefel.hpp>
            void test() {
                using namespace pagmo;
                problem prob{schwefel(30)};
                algorithm algo{sade(100)};
                archipelago archi{16u, algo, prob, 20u};
                archi.evolve(10);
                archi.wait_check();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
