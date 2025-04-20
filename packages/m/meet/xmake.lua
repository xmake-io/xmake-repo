package("meet")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cngege/Meet")
    set_description("A header_only network lib.")
    set_license("MIT")

    add_urls("https://github.com/cngege/Meet/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cngege/Meet.git")

    add_versions("v0.1.2", "29f214601a25cf25fb3130e24a7b3f616aa58e662509a8b48d6a8383c12e6ca1")
	
    on_install("windows", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                meet::TCPClient c;
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"meet/Meet.hpp"}}))
    end)
