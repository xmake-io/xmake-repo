package("plf_reorderase")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/reorderase.htm")
    set_description("A faster method for singular erasures, ranged erasures, and erase_if-style erasures for vector/deque/static_vector when element order is not important.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_reorderase.git")
    add_versions("v1.11", "34728e5dca312e3263addd5394235a33def4a3f4")

    on_install(function (package)
        os.cp("plf_reorderase.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <plf_reorderase.h>
            void test() {
                std::vector<int> vec{1};
                plf::reorderase_all(vec, 1);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
