package("srell")
    set_kind("library", {headeronly = true})
    set_homepage("https://akenotsuki.com/misc/srell")
    set_description("Unicode-aware regular expression template library for C++")
    set_license("BSD-2-Clause")

    add_urls("https://akenotsuki.com/misc/srell/srell$(version).zip", {version = function(version)
        return version:gsub("%.", "_")
    end})
    add_versions("4.019", "b4281825c529c7f63b61917782b33066a93cd40b55efbcac13c1ef615cd29835")
    add_versions("3.018", "0cb7587b3613085204ed847259cb46a54f7328aef90a0ce85a1eaa895a755ccf")

    on_install(function(package)
        os.cp("*.hpp", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                srell::regex e{ "\\d+[^-\\d]+" };
                srell::cmatch m;
                if (srell::regex_search("1234-5678-90ab-cdef", m, e)) {
                    const std::string s(m[0].first, m[0].second);
                    std::printf("result: %s\n", s.c_str());
                }
            }
        ]]}, {configs = {languages = "c++11"}, includes = "srell.hpp"}))
    end)
