package("universal_stacktrace")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/MisterTea/UniversalStacktrace")
    set_description("C++ Stacktrace for windows linux and os/x")
    set_license("Apache-2.0")

    add_urls("https://github.com/MisterTea/UniversalStacktrace.git", {submodules = false})
    add_versions("2022.11.06", "28f5230d75e677ce8e4e140b2f3e0b8550195c85")
    add_versions("2023.10.15", "88281dcc43c169afd5eea9fe26f68999656140e3")


    if is_plat("windows") then
        add_syslinks("dbghelp")
    end

    on_install("linux", "macosx", "windows", "mingw", function (package)
        io.replace("ust/ust.hpp", "#include <vector>", "#include <vector>\n#include <cstring>", {plain = true})
        io.replace("ust/ust.hpp", "#include <DbgHelp.h>\n#include <windows.h>", "#include <windows.h>\n#include <DbgHelp.h>", {plain = true})
        os.cp("ust", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ust::generate();
            }
        ]]}, {includes = {"ust/ust.hpp"}}))
    end)
