package("plf_indiesort")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/indiesort.htm")
    set_description("A sort wrapper enabling both use of random-access sorting on non-random access containers, and increased performance for the sorting of large types.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_indiesort.git")
    add_versions("v1.41", "fce3d54ed1a43e9e7008703f79c4f4d2e5259176")

    on_install(function (package)
        os.cp("plf_indiesort.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <plf_indiesort.h>
            void test() {
                std::vector<int> vec;
                plf::indiesort(vec);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
