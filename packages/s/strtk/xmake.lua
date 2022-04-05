package("strtk")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.partow.net/programming/strtk/index.html")
    set_description("C++ String Toolkit Library")
    set_license("MIT")

    add_urls("https://github.com/ArashPartow/strtk.git")
    add_versions("2020.01.01", "d2b446bf1f7854e8b08f5295ec6f6852cae066a2")

    on_install(function (package)
        os.cp("strtk.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define strtk_no_tr1_or_boost
            #include <strtk.hpp>
            void test() {
                std::string s = "abc|123|xyz|789";
                strtk::single_delimiter_predicate<std::string::value_type> predicate('|');
                strtk::std_string::tokenizer<>::type tokenizer(s,predicate);
                strtk::std_string::tokenizer<>::type::iterator itr = tokenizer.begin();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
