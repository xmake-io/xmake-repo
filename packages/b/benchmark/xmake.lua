package("benchmark")

    set_homepage("https://github.com/google/benchmark")
    set_description("A microbenchmark support library")

    add_urls("https://github.com/google/benchmark/archive/v$(version).tar.gz",
             "https://github.com/google/benchmark.git")
    add_versions("1.5.2", "dccbdab796baa1043f04982147e67bb6e118fe610da2c65f88912d73987e700c")

    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_syslinks("shlwapi")
    end

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
