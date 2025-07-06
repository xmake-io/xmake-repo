package("fatal")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/facebook/fatal")
    set_description("Fatal is a library for fast prototyping software in modern C++.")
    set_license("BSD")

    add_urls("https://github.com/facebook/fatal/releases/download/v$(version).00/fatal-v$(version).00.zip",
             "https://github.com/facebook/fatal.git")

    add_versions("2024.06.24", "9b134c46eec2a1fc38cfbfef13de11f7b252ded6d789d2460956d43b89719a8b")

    on_install(function (package)
        os.cp("fatal", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "fatal/type/array.h"
            void test() {
                using arr_t = fatal::c_array<int, 3>;
                arr_t arr{{'b', 'a', 'r'}};
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
