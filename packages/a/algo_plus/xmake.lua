package("algo_plus")
    set_kind("library", {headeronly = true})
    set_homepage("https://csrt-ntua.github.io/AlgoPlus")
    set_description("AlgoPlus is a C++17 library for complex data structures and algorithms")
    set_license("Apache-2.0")

    add_urls("https://github.com/CSRT-NTUA/AlgoPlus.git")
    add_versions("2024.07.02", "1287dfc5bf666bace15af9c14d03e807b71efa82")

    add_deps("nlohmann_json")

    on_install(function (package)
        for _, file in ipairs(os.files("src/**.h")) do
            io.replace(file, "../../../../third_party/json.hpp", "nlohmann/json.hpp", {plain = true})
        end
        os.cp("src/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::vector<std::vector<double> > data;
                int CLUSTERS;
                kmeans a(data, CLUSTERS);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"machine_learning/clustering/kmeans/kmeans.h"}}))
    end)
