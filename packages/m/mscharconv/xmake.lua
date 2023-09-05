package("mscharconv")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/iboB/mscharconv")
    set_description("<charconv> from Microsoft STL, but multi-platform ")

    add_urls("https://github.com/iboB/mscharconv.git")
    add_versions("latest", "5d2e3a6e9663a41207561c9510ad1e3d557b5c5e")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int test(){
                double pi = 3.14159265359;
                char pi_str[256];
                auto [p, ec] = msstl::to_chars(pi_str, pi_str + sizeof(pi_str), pi);

                if (ec != std::errc{}) {
                    std::cerr << "Error converting \"" << pi << "\" to string\n";
                    return 1;
                }

                *p = 0; // terminate string
                std::cout << "Got string " << pi_str << "\n";
                return 0;
            }
        ]]}, {configs = {languages = "cxx17"}, includes = {"msstl/charconv.hpp", "iostream", "string_view"}}))
        assert(package:check_cxxsnippets({test = [[
            int test(){
                std::string_view pi_str = "3.14159 is pi";
                double pi;
                auto [p, ec] = msstl::from_chars(pi_str.data(), pi_str.data() + pi_str.length(), pi);
                if (ec != std::errc{}) {
                    std::cerr << "Error converting \"" << pi_str << "\" to double\n";
                    return 1;
                }
                std::cout << "Got double " << pi << ". The rest is \"" << p << "\".\n";
                return 0;
            }
        ]]}, {configs = {languages = "cxx17"}, includes = {"msstl/charconv.hpp", "iostream", "string_view"}}))
    end)
