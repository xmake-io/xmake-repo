package("nameof")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Neargye/nameof")
    set_description("Nameof operator for modern C++, simply obtain the name of a variable, type, function, macro, and enum")
    set_license("MIT")

    add_urls("https://github.com/Neargye/nameof/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/Neargye/nameof.git")

    add_versions("0.10.3", "f31dd02841adfbb98949454005a308174645957d2b8d4dc06a7c15e1039e46e6")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nameof.hpp>
            void test() {
                int x;
                static_assert(NAMEOF(x) == "x");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
