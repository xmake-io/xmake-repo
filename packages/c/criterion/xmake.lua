package("criterion")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/criterion")
    set_description("Microbenchmarking for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/criterion.git")
    add_versions("2020.11.02", "c7b27f53f17c9f44abd4b78b1e2bc41783a272e2")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <criterion/criterion.hpp>
            CRITERION_BENCHMARK_MAIN()
        ]]}, {configs = {languages = "c++17"}, tryrun = true}))
    end)
