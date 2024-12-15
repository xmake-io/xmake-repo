package("onedpl")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-library.html")
    set_description("oneDPL is part of the UXL Foundation and is an implementation of the oneAPI specification for the oneDPL component.")

    add_urls("https://github.com/oneapi-src/oneDPL/archive/refs/tags/oneDPL-$(version).tar.gz")
    add_urls("https://github.com/oneapi-src/oneDPL/archive/refs/tags/oneDPL-$(version)-release.tar.gz")
    add_versions("2021.6.1", "4995fe2ed2724b89cdb52c4b6c9af22e146b48d2561abdafdaaa06262dbd67c4")
    add_versions("2022.5.0-rc1", "9180c60331ec5b307dd89a5d8bfcd096667985c6761c52322405d4b69193ed88")
    add_versions("2022.6.0-rc1", "45698e2f97de085806aa685ec1fe3ccecc28251d744b016fca112aa3ecc90c9a")
    add_versions("2022.7.0", "095be49a9f54633d716e82f66cc3f1e5e858f19ef47639e4c94bfc6864292990")
    add_versions("2022.7.1", "0e6a1bee7a4f4375091c98b0b5290edf3178bb810384e0e106bf96c03649a754")

    add_configs("backend", {description = "Choose threading backend.", default = "tbb", type = "string", values = {"tbb", "dpcpp", "dpcpp_only", "omp", "serial"}})

    add_deps("cmake")

    on_fetch("fetch")
    on_load("windows", "linux", function (package)
        local backend = package:config("backend")
        if backend == "tbb"  then
            package:add("deps", "tbb")
	        package:add("defines", "ONEDPL_USE_TBB_BACKEND=1")
            package:add("ldflags", "-ltbb")
        elseif backend == "omp" then
            package:add("deps", "openmp")
	        package:add("defines", "ONEDPL_USE_OPENMP_BACKEND=1")
	    elseif backend == "dpcpp" then
	        package:add("deps", "tbb")
            package:add("ldflags", "-ltbb")
            package:add("defines", "ONEDPL_USE_TBB_BACKEND=1")
	        package:add("defines", "ONEDPL_USE_DPCPP_BACKEND=1")
        elseif backend == "dpcpp_only" then
            package:add("defines", "ONEDPL_USE_TBB_BACKEND=0")
	        package:add("defines", "ONEDPL_USE_DPCPP_BACKEND=1")
        elseif backend == "serial" then
            package:add("defines", "ONEDPL_USE_OPENMP_BACKEND=0")
            package:add("defines", "ONEDPL_USE_TBB_BACKEND=0")
	        package:add("defines", "ONEDPL_USE_DPCPP_BACKEND=0")
        end
        if package:is_plat("windows") then
            package:add("cxxflags", "/Zc:__cplusplus")
        end
    end)

    on_install("windows", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        -- c.f. https://github.com/oneapi-src/oneDPL/issues/1602  and https://github.com/oneapi-src/oneDPL/commit/e25afef957b50536c5091ed23150fff10921b18f
        io.replace("include/oneapi/dpl/pstl/algorithm_impl.h", "(_PSTL_UDR_PRESENT || _ONEDPL_UDR_PRESENT)", "_ONEDPL_UDR_PRESENT // _PSTL_UDR_PRESENT", {plain = true})
        io.replace("include/oneapi/dpl/pstl/numeric_impl.h", "(_PSTL_UDS_PRESENT || _ONEDPL_UDS_PRESENT)", "_ONEDPL_UDS_PRESENT // PSTL_UDS_PRESENT", {plain = true})
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
