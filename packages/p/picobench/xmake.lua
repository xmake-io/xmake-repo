package("picobench")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/iboB/picobench")
    set_description("A micro microbenchmarking library for C++11 in a single header file")
    set_license("MIT")

    add_urls("https://github.com/iboB/picobench/archive/refs/tags/v$(version).tar.gz")
    add_versions("2.08", "7002cede527d661bc599a59dcd492ec6a0943f695603f581bf9f0569dcd9c866")
    add_versions("2.07", "c7f8e279cd5138a66a9a417caf1012ed7b15ba2652aec96ef8dd5e6e3e07d7a0")
    add_versions("2.06", "2f5d9b53260322b422a1834bbbe4947109039ee518353a8cc8dd57bbd1999b57")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <cstdlib>
            #include "picobench/picobench.hpp"
            static void rand_vector(picobench::state& s)
            {
                std::vector<int> v;
                for (auto _ : s)
                {
                    v.push_back(rand());
                }
            }
            PICOBENCH(rand_vector); // Register the above function with picobench
        ]]}))
    end)
