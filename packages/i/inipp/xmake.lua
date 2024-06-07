package("inipp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mcmtroffaes/inipp")
    set_description("Simple C++ ini parser.")
    set_license("MIT")

    add_urls("https://github.com/mcmtroffaes/inipp.git")
    add_versions("2022.02.03", "c61e699682d3f1091209c2179f1d03f5fc593327")

    on_install(function (package)
        os.cp("inipp/inipp.h", package:installdir("include/inipp"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <inipp/inipp.h>
            void test() {
                inipp::Ini<char> ini;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
