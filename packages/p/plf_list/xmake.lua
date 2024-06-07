package("plf_list")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/list.htm")
    set_description("A data container replicating std::list functionality but with (on average) 333% faster insertion, 81% faster erasure and 16% faster iteration.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_list.git")
    add_versions("2.73", "b5bbcec628b149c57c56887e6ba0a55caf61fc95")

    on_install(function (package)
        os.cp("plf_list.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <plf_list.h>
            void test() {
                plf::list<int> i_list;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
