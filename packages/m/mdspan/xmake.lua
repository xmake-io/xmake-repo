package("mdspan")
    set_kind("library", {headeronly = true})

    set_homepage("https://github.com/kokkos/mdspan")
    set_description("Reference implementation of mdspan targeting C++23")
    set_license("Apache-2.0")

    add_urls("https://github.com/kokkos/mdspan/archive/refs/tags/mdspan-$(version).tar.gz",
             "https://github.com/kokkos/mdspan.git")
    add_versions("0.6.0", "79f94d7f692cbabfbaff6cd0d3434704435c853ee5087b182965fa929a48a592")
    add_versions("0.5.0", "ffa73e5e0dcd78e5279cd3b51a4d983a1fbef696e630fd1287ce32d93d6642d1")
    add_versions("0.4.0", "7b89db3c7a9c206c8447499456fdea9c9c1b3a34f58fd0b4c4dd87176b3fe20b")
    add_versions("0.3.0", "275ac02b456a31a5b8c0cb773fca3fe59f6df8a441124dcc1e7a88ef8069f974")
    add_versions("0.2.0", "1ce8e2be0588aa6f2ba34c930b06b892182634d93034071c0157cb78fa294212")

    on_install("!windows", function (package)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
        local test = [[
            #include <cstddef>
            void test() {
                double data[6] = {0, 1, 2, 3, 4, 5};
                std::experimental::mdspan<double, std::experimental::extents<std::size_t, 2, 3>> a(data);
            }
        ]]
        if package:version():lt("0.4.0") then
            -- extents has no index_type template parameter before 0.4.0
            test = [[
                void test() {
                    double data[6] = {0, 1, 2, 3, 4, 5};
                    std::experimental::mdspan<double, std::experimental::extents<2, 3>> a(data);
                }
            ]]
        end
        assert(package:check_cxxsnippets({test = test}, {configs = {languages = "c++17"}, includes = "experimental/mdspan"}))
    end)
