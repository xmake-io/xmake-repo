package("rapidfuzz")
    set_kind("library", {headeronly = true})
    set_homepage("https://rapidfuzz.github.io/rapidfuzz-cpp")
    set_description("Rapid fuzzy string matching in C++ using the Levenshtein Distance")
    set_license("MIT")

    add_urls("https://github.com/rapidfuzz/rapidfuzz-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rapidfuzz/rapidfuzz-cpp.git")

    add_versions("v3.3.3", "fa0fbd40110df8134cf05bddbaa4e237dbc4fd915ab9a3029ff481a8d3e8b757")
    add_versions("v3.3.2", "cf619bb1e7a525472077e76287041d9cd89e97073a24095bcb97f81897b0c1d4")
    add_versions("v3.1.1", "5a72811a9f5a890c69cb479551c19517426fb793a10780f136eb482c426ec3c8")
    add_versions("v3.0.5", "e32936cc66333a12f659553b5fdd6d0c22257d32ac3b7a806ac9031db8dea5a1")
    add_versions("v3.0.4", "18d1c41575ceddd6308587da8befc98c85d3b5bc2179d418daffed6d46b8cb0a")
    add_versions("v3.0.2", "4fddce5c0368e78bd604c6b820e6be248d669754715e39b4a8a281bda4c06de1")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using rapidfuzz::fuzz::ratio;
                double score1 = rapidfuzz::fuzz::ratio("this is a test", "this is a test!");
                double score2 = rapidfuzz::fuzz::partial_ratio("this is a test", "this is a test!");
                double score3 = rapidfuzz::fuzz::ratio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear");
                double score4 = rapidfuzz::fuzz::token_sort_ratio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear");
                double score5 = rapidfuzz::fuzz::token_sort_ratio("fuzzy was a bear", "fuzzy fuzzy was a bear");
                double score6 = rapidfuzz::fuzz::token_set_ratio("fuzzy was a bear", "fuzzy fuzzy was a bear");
            }
        ]]},{includes = "rapidfuzz/fuzz.hpp", configs = {languages = "c++17"}}))
    end)
