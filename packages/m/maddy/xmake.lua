package("maddy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/progsource/maddy")
    set_description("C++ Markdown to HTML header-only parser library")
    set_license("MIT")

    add_urls("https://github.com/progsource/maddy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/progsource/maddy.git")

    add_versions("1.2.1", "b6058bce7ca32506969633ee7a4042e75b07464489f1c44be00913543cd687ef")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <maddy/parser.h>
            void test() {
                auto var = maddy::ParserConfig();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
