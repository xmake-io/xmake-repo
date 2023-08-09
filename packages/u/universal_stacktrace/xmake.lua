package("universal_stacktrace")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/MisterTea/UniversalStacktrace")
    set_description("C++ Stacktrace for windows linux and os/x")
    set_license("Apache-2.0")

    add_urls("https://github.com/MisterTea/UniversalStacktrace.git")
    add_versions("2022.11.06", "28f5230d75e677ce8e4e140b2f3e0b8550195c85")

    if is_plat("windows") then
        add_syslinks("dbghelp")
    end

    on_install("linux", "macosx", "windows", function (package)
        io.replace("ust/ust.hpp", "#include <vector>", "#include <vector>\n#include <cstring>", {plain = true})
        os.cp("ust", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ust::generate();
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"ust/ust.hpp"}}))
    end)
