package("stringbuilder")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Isameru/stringbuilder")
    set_description("Fast, efficient and convenient alternative to std::stringstream and std::string concatenation.")
    set_license("MIT")

    add_urls("https://github.com/Isameru/stringbuilder.git")
    add_versions("2023.7.10", "ab772a6f0db237155d17a68c8f72b48383137872")

    on_install("!windows", function (package)
        io.replace("include/stringbuilder.h", "#pragma once", "#pragma once\n#include <ios>\n#include <stdexcept>", {plain = true})
        io.replace("include/stringbuilder.h", "#include <intrin.h>", "", {plain = true})
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <stringbuilder.h>
            void test() {
                auto sb = sbldr::stringbuilder<5>{};
                sb << "123";
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
