package("kokkos")
    set_homepage("https://kokkos.github.io/")
    set_description("Kokkos C++ Performance Portability Programming EcoSystem: The Programming Model")
    set_license("Apache-2.0")

    add_urls("https://github.com/kokkos/kokkos/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kokkos/kokkos.git")

    add_versions("4.4.00", "c638980cb62c34969b8c85b73e68327a2cb64f763dd33e5241f5fd437170205a")
    add_versions("4.3.01", "5998b7c732664d6b5e219ccc445cd3077f0e3968b4be480c29cd194b4f45ec70")
    add_versions("4.3.00", "53cf30d3b44dade51d48efefdaee7a6cf109a091b702a443a2eda63992e5fe0d")
    add_versions("4.2.01", "cbabbabba021d00923fb357d2e1b905dda3838bd03c885a6752062fe03c67964")
    add_versions("4.2.00", "ac08765848a0a6ac584a0a46cd12803f66dd2a2c2db99bb17c06ffc589bf5be8")
    add_versions("4.0.01", "bb942de8afdd519fd6d5d3974706bfc22b6585a62dd565c12e53bdb82cd154f0")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("threads", {description = "Enable thread support.", default = true, type = "boolean"})
    add_configs("cuda",    {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("arch",    {description = "Enable architecture-specific optimizations.", default = (is_plat("macosx", "linux") and "native" or nil), type = "string"})

    add_deps("cmake")
    add_links("kokkoscontainers", "kokkossimd", "kokkoscore")
    on_load("windows|x64", "macosx", "linux", function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
    end)

    on_install("windows|x64", "macosx|x86_64", "linux", function (package)
        local configs = {"-DKokkos_ENABLE_SERIAL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DKokkos_ENABLE_THREADS=" .. (package:config("threads") and "ON" or "OFF"))
        table.insert(configs, "-DKokkos_ENABLE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        if package:config("arch") ~= nil then
            table.insert(configs, "-DKokkos_ARCH_" .. package:config("arch"):upper() .. "=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char *argv[]) {
                Kokkos::initialize(argc, argv);
                Kokkos::finalize();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "Kokkos_Core.hpp"}))
    end)
