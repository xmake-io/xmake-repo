package("plf_colony")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/colony.htm")
    set_description("An unordered C++ data container providing fast iteration/insertion/erasure while maintaining pointer/iterator validity to non-erased elements regardless of insertions/erasures. Provides higher-performance than std:: library containers for high-modification scenarios with unordered data.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_colony.git")
    add_versions("2023.08.25", "394c787ecf5a541b66d08b90f22cebc954f0599c")

    on_install(function (package)
        os.cp("plf_colony.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <plf_colony.h>
            void test() {
                plf::colony<int> i_colony;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
