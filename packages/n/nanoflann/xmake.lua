package("nanoflann")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jlblancoc/nanoflann/")
    set_description("nanoflann: a C++11 header-only library for Nearest Neighbor (NN) search with KD-trees")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jlblancoc/nanoflann/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jlblancoc/nanoflann.git")
    add_versions("v1.3.2", "e100b5fc8d72e9426a80312d852a62c05ddefd23f17cbb22ccd8b458b11d0bea")
    add_versions("v1.4.2", "97fce650eb644a359a767af526cab9ba31842e53790a7279887e1ae2fffe7319")
    add_versions("v1.5.0", "89aecfef1a956ccba7e40f24561846d064f309bc547cc184af7f4426e42f8e65")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DNANOFLANN_BUILD_EXAMPLES=OFF", "-DNANOFLANN_BUILD_TESTS=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const size_t num_results = 1;
                size_t ret_index;
                float out_dist_sqr;
                nanoflann::KNNResultSet<float> resultSet(num_results);
                resultSet.init(&ret_index, &out_dist_sqr);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "nanoflann.hpp"}))
    end)
