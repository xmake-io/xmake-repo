package("clara")

    set_homepage("https://github.com/catchorg/Clara")
    set_description("A simple to use, composable, command line parser for C++ 11 and beyond.")
    set_license("BSL-1.0")

    add_urls("https://github.com/catchorg/Clara/archive/v$(version).tar.gz")
    add_versions("1.1.5", "767dc1718e53678cbea00977adcd0a8a195802a505aec3c537664cf25a173142")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                bool flag = false;
                auto p = clara::Opt(flag, "true|false")["-f"]("A flag");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "clara.hpp"}))
    end)
