package("nanoflann")

    set_homepage("https://github.com/jlblancoc/nanoflann/")
    set_description("nanoflann: a C++11 header-only library for Nearest Neighbor (NN) search with KD-trees")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jlblancoc/nanoflann/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jlblancoc/nanoflann.git")
    add_versions("v1.3.2", "e100b5fc8d72e9426a80312d852a62c05ddefd23f17cbb22ccd8b458b11d0bea")

    on_install(function (package)
        os.cp("include/nanoflann.hpp", package:installdir("include"))
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
