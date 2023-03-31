package("nanobench")
    set_homepage("https://nanobench.ankerl.com")
    set_description("Simple, fast, accurate single-header microbenchmarking functionality for C++11/14/17/20")
    set_license("MIT")

    add_urls("https://github.com/martinus/nanobench/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinus/nanobench.git")
    add_versions("v4.3.11", "53a5a913fa695c23546661bf2cd22b299e10a3e994d9ed97daf89b5cada0da70")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                double d = 1.0;
                ankerl::nanobench::Bench().run("some double ops", [&] {
                    d += 1.0 / d;
                    if (d > 5.0) {
                        d -= 5.0;
                    }
                    ankerl::nanobench::doNotOptimizeAway(d);
                });
            }
        ]]}, {configs = {languages = "c++11"}, defines = "ANKERL_NANOBENCH_IMPLEMENT", includes = "nanobench.h"}))
    end)
