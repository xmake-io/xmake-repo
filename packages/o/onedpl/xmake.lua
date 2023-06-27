package("onedpl")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-library.html")
    set_description("oneAPI DPC++ Library")

    add_urls("https://github.com/oneapi-src/oneDPL/archive/refs/tags/oneDPL-$(version)-release.tar.gz")
    add_versions("2021.6.1", "4995fe2ed2724b89cdb52c4b6c9af22e146b48d2561abdafdaaa06262dbd67c4")

    add_configs("backend", {description = "Choose threading backend.", default = "tbb", type = "string", values = {"tbb", "dpcpp", "dpcpp_only", "omp", "serial"}})

    add_deps("cmake")
    on_load("windows", "linux", function (package)
        local backend = package:config("backend")
        if backend == "tbb" or backend == "dpcpp" then
            package:add("deps", "tbb")
        elseif backend == "omp" then
            package:add("deps", "openmp")
        end
        if package:is_plat("windows") then
            package:add("cxxflags", "/Zc:__cplusplus")
        end
    end)

    on_install("windows", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DONEDPL_BACKEND=" .. package:config("backend"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <oneapi/dpl/algorithm>
            #include <oneapi/dpl/execution>
            #include <oneapi/dpl/numeric>
            #include <vector>
            void test() {
                const size_t size = 10000000;
                std::vector<double> v1(size), v2(size);
                double res = std::transform_reduce(oneapi::dpl::execution::par_unseq,
                                                   v1.cbegin(), v1.cend(), v2.cbegin(), .0);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
