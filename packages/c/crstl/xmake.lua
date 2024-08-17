package("crstl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/redorav/crstl")
    set_description("STL whose aim is to compile fast, run fast, and be clear to read")

    add_urls("https://github.com/redorav/crstl.git")
    add_versions("2024.06.04", "0c31b6c76ff74521b2f50b1643f8f3d207184c6c")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                crstl::fixed_vector<int, 32> v;
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"crstl/fixed_vector.h"}}))
    end)
