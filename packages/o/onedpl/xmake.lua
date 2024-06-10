package("onedpl")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-library.html")
    set_description("oneAPI DPC++ Library")

    add_urls("https://github.com/oneapi-src/oneDPL/archive/refs/tags/oneDPL-$(version)-release.tar.gz")
    add_urls("https://github.com/oneapi-src/oneDPL/archive/refs/tags/oneDPL-$(version).tar.gz")
    add_versions("2021.6.1", "4995fe2ed2724b89cdb52c4b6c9af22e146b48d2561abdafdaaa06262dbd67c4")
    add_versions("2022.5.0-rc1", "9180c60331ec5b307dd89a5d8bfcd096667985c6761c52322405d4b69193ed88")

    add_configs("backend", {description = "Choose threading backend.", default = "tbb", type = "string", values = {"tbb", "dpcpp", "dpcpp_only", "omp","serial"}})

    add_deps("cmake")

    on_fetch("fetch")
    on_load("windows", "linux", function (package)
        local backend = package:config("backend")
        if backend == "tbb" or backend == "dpcpp" then
            package:add("deps", "tbb")
	        package:add("defines", "ONEDPL_USE_TBB_BACKEND=1")
            package:add("ldflags", "-ltbb")
        elseif backend == "omp" then
            package:add("deps", "openmp")
	        package:add("defines", "ONEDPL_USE_OPENMP_BACKEND=1")
	    elseif backend == "dpcpp" then
	        package:add("deps", "tbb")
            package:add("ldflags", "-ltbb")
	        package:add("defines", "ONEDPL_USE_DPCPP_BACKEND=1")

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
            #if (__INTEL_COMPILER >= 1900 || !defined(__INTEL_COMPILER) && _PSTL_GCC_VERSION >= 40900 || _OPENMP >= 201307)
            #    define _PSTL_UDR_PRESENT 1
            #else
            #    define _PSTL_UDR_PRESENT 0
            #endif
            #define _PSTL_UDS_PRESENT (__INTEL_COMPILER >= 1900 && __INTEL_COMPILER_BUILD_DATE >= 20180626)
            /* MACROS DUE TO https://github.com/llvm/llvm-project/commit/3b9a1bb1af90db9472340ef2122d3855eb9ba3fc#diff-4c6821476cefc699b801f5fdbeda3341e3c64626dcf39a79621ea02031bdd50eL113 */
            /* ALSO C.F. https://github.com/oneapi-src/oneDPL/issues/1602 */
            /* AND THE USING OF _PSTL_... MACROS IS REMOVED FROM ONEDPL NOWADAYS*/
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
