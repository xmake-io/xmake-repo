package("jpcre2")
    set_kind("library", {headeronly = true})
    set_homepage("https://docs.neurobin.org/jpcre2/latest/")
    set_description("C++ wrapper  for PCRE2 Library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/jpcre2/jpcre2/archive/867af2d36413cf5f69c2e224f4f96f56f876d889.tar.gz",
             "https://github.com/jpcre2/jpcre2.git")

    add_versions("2021.06.15", "8df87579bda9b56ff23eceafcd2a5604938e3e299e0206b88a8f4ee1ba29c0e3")

    add_deps("pcre2")

    on_install(function (package)
        os.cp("src/jpcre2.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            typedef jpcre2::select<char> jp;
            void test() {
                jp::Regex re;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "jpcre2.hpp"}))
    end)
