package("mathfu")
    set_kind("library", {headeronly = true})
    set_homepage("http://google.github.io/mathfu")
    set_description("C++ math library developed primarily for games focused on simplicity and efficiency.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/mathfu.git")
    add_versions("2022.5.10", "da23a1227bb65fbb7f2f5b6c504fbbdd1dfdab4b")

    add_deps("vectorial")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "mathfu/vector.h"
            void test() {
                mathfu::Vector<int, 1> vector;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
