package("scope_guard")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Neargye/scope_guard")
    set_description("Scope Guard & Defer C++")
    set_license("MIT")

    add_urls("https://github.com/Neargye/scope_guard.git")
    add_versions("2022.04.05", "fa60305b5805dcd872b3c60d0bc517c505f99502")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <scope_guard.hpp>
            void test() {
                int* x = new int;
                SCOPE_EXIT{ delete x; };
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
