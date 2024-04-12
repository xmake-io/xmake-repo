package("plf_hive")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/colony.htm")
    set_description("plf::hive is a fork of plf::colony to match the current C++ standards proposal.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_hive.git")
    add_versions("latest", "bebd22a4fa017c09bfa0100603e5c7ff4af6c01e")

    on_install(function (package)
        os.cp("plf_hive.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
// plf_hive requires C++20 ranges compatibility.
#ifdef __cpp_lib_containers_ranges
            #include <plf_hive.h>
            void test() {
                plf::hive<int> i_hive;
            }
#else
void test() { return; }
#endif
        ]]}, {configs = {languages = "c++20"}}))
    end)
