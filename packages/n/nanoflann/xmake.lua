package("nanoflann")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jlblancoc/nanoflann/")
    set_description("nanoflann: a C++11 header-only library for Nearest Neighbor (NN) search with KD-trees")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jlblancoc/nanoflann/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jlblancoc/nanoflann.git")
    add_versions("v1.9.0", "14dc863ec47d52ec3272b4fd409fd198a52e6cab58ece70b1da9c3dc2e478942")
    add_versions("v1.8.0", "14e82a1de64a8b26486322d36817449a8bc2e63ea3b91bfee64f320155790a9c")
    add_versions("v1.7.1", "887e4e57e9c5fbf1c2937f9f5a9bc461c4786d54729b57a9c19547bdedb46986")
    add_versions("v1.7.0", "5e0b05a209aa61e0b0377bcad8b6978862b17f096f67dbab1630ec9593aa075d")
    add_versions("v1.6.2", "c1b8f2e4d32c040249dad14a89dd03c5106a8c56f3e9ca4e60a0836a59259c0c")
    add_versions("v1.6.1", "e258d6fd6ad18e1809fa9c081553e78036fd6e7b418d3762875c2c5a015dd431")
    add_versions("v1.6.0", "f889026fbcb241e1e9d71bab5dfb9cc35775bf18a6466a283e2cbcd60edb2705")
    add_versions("v1.5.5", "fd28045eabaf0e7f12236092f80905a1750e0e6b580bb40eadd64dc4f75d641d")
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
