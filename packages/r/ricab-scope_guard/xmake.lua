package("ricab-scope_guard")
    set_kind("library", {headeronly = true})
    set_homepage("https://ricab.github.io/scope_guard/")
    set_description("A modern C++ scope guard that is easy to use but hard to misuse.")
    set_license("Unlicense")

    add_urls("https://github.com/ricab/scope_guard/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ricab/scope_guard.git")

    add_versions("v1.1.0", "ddaf22ccd07e59af4698e2b9f912171adb664dc88f34b317f39dde3b88de4507")

    on_install(function (package)
        os.cp("scope_guard.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <scope_guard.hpp>
            void my_callback() {}
            void test() {
                auto guard = sg::make_scope_guard(my_callback);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
