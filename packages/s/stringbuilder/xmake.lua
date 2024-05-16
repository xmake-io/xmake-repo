package("stringbuilder")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Isameru/stringbuilder")
    set_description("Fast, efficient and convenient alternative to std::stringstream and std::string concatenation.")
    set_license("MIT")

    add_urls("https://github.com/Isameru/stringbuilder.git")
    add_versions("2023.7.23", "ab772a6f0db237155d17a68c8f72b48383137872")

    on_install(function (package)
        os.cp("include/stringbuilder.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <stringbuilder.h>
            auto sb = sbldr::stringbuilder<5>{};
            sb << "123 ";
            sb << sb;
            sb << sb;
            sb << sb;
            assert(std::to_string(sb) == "123 123 123 123 123 123 123 123 ");
        ]]}, {configs = {languages = "c++17"}}))
    end)
