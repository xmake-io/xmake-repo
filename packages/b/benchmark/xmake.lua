package("benchmark")

    set_homepage("https://github.com/google/benchmark")
    set_description("A microbenchmark support library")

    add_urls("https://github.com/google/benchmark/archive/v$(version).tar.gz",
             "https://github.com/google/benchmark.git")
    add_versions("1.5.2", "dccbdab796baa1043f04982147e67bb6e118fe610da2c65f88912d73987e700c")
    add_versions("1.5.5", "3bff5f237c317ddfd8d5a9b96b3eede7c0802e799db520d38ce756a2a46a18a0")

    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_syslinks("shlwapi")
    end

    add_deps("cmake")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DBENCHMARK_ENABLE_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void BM_empty(benchmark::State& state) {
              for (auto _ : state) {
                benchmark::DoNotOptimize(state.iterations());
              }
            }
            BENCHMARK(BM_empty);
            BENCHMARK(BM_empty)->ThreadPerCpu();
        ]]}, {configs = {languages = "c++11"}, includes = "benchmark/benchmark.h"}))
    end)
