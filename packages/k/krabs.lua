package("krabs")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Microsoft/krabsetw")
    set_description("Krabs ETW provides a modern C++ wrapper around the ETW API")
    set_license("MIT")

    add_urls("https://github.com/Microsoft/krabsetw.git")
    add_versions("2025.10.20", "62a3dea877f436f2e63d5234f3ab64493b240c8e")

    on_install("windows", function (package)
        os.cp("krabs/krabs", package:installdir("include"))
        os.cp("krabs/krabs.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <krabs/krabs.hpp>
            #include <iostream>
            
            void test() {
                krabs::provider<> provider(12345);
                std::cout << "Krabs ETW test" << std::endl;
            }
        ]]}, {configs = {languages = "c++14", defines = "WIN32_LEAN_AND_MEAN"}}))
    end)
