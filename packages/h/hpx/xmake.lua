package("hpx")
    set_homepage("https://hpx.stellar-group.org")
    set_description("The C++ Standard Library for Parallelism and Concurrency")
    set_license("BSL-1.0")

    add_urls("https://github.com/STEllAR-GROUP/hpx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/STEllAR-GROUP/hpx.git")

    add_versions("v1.11.0", "01ec47228a2253b41e318bb09c83325a75021eb6ef3262400fbda30ac7389279")
    add_versions("v1.10.0", "5720ed7d2460fa0b57bd8cb74fa4f70593fe8675463897678160340526ec3c19")
    add_versions("v1.9.1", "1adae9d408388a723277290ddb33c699aa9ea72defadf3f12d4acc913a0ff22d")

    add_configs("malloc", {description = "Use a custom allocator", default = "system", values = {"system", "tcmalloc", "jemalloc", "mimalloc"}})
    add_configs("cuda", {description = "Enable support for CUDA", default = false})
    add_configs("mpi", {description = "Enable the MPI parcelport", default = false})
    add_configs("tcp", {description = "Enable the TCP parcelport", default = false})
    add_configs("lci", {description = "Enable the LCI parcelport", default = false})
    add_configs("apex", {description = "Enable APEX integration", default = false})
    add_configs("context", {description = "Enable Boost. Context for task context switching", default = false})
    add_configs("cpu_count", {description = "Set the maximum CPU count supported by HPX", default = "64"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "hwloc", "asio >=1.12.0")

    on_load("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        local malloc = package:config("malloc")
        if malloc ~= "system" then
            package:add("deps", malloc)
        end
        if package:config("context") then
            package:add("deps", "boost >=1.71.0", {configs = {context = true}})
        else
            package:add("deps", "boost >=1.71.0")
        end
    end)

    on_install("windows|x64", function (package)
        local configs = {"-DHPX_WITH_EXAMPLES=OFF", "-DHPX_WITH_TESTS=OFF", "-DHPX_WITH_UNITY_BUILD=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_MALLOC=" .. package:config("malloc"))
        table.insert(configs, "-DHPX_WITH_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_PARCELPORT_MPI=" .. (package:config("mpi") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_PARCELPORT_TCP=" .. (package:config("tcp") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_PARCELPORT_LCI=" .. (package:config("lci") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_APEX=" .. (package:config("apex") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_GENERIC_CONTEXT_COROUTINES=" .. (package:config("context") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_MAX_CPU_COUNT=" .. package:config("cpu_count"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <hpx/iostream.hpp>
            void test() {
                hpx::cout << "Hello World!\n" << std::flush;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
