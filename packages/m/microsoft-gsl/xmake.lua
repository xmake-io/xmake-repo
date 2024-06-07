package("microsoft-gsl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/GSL")
    set_description("Guidelines Support Library")
    set_license("MIT")

    add_urls("https://github.com/microsoft/GSL/archive/$(version).tar.gz",
             "https://github.com/microsoft/GSL.git")
    add_versions("v3.1.0", "d3234d7f94cea4389e3ca70619b82e8fb4c2f33bb3a070799f1e18eef500a083")
    add_versions("v4.0.0", "f0e32cb10654fea91ad56bde89170d78cfbf4363ee0b01d8f097de2ba49f6ce9")

    on_install(function (package)
        os.mv("include/gsl", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <type_traits>
            void test() {
                std::vector<int> v{1,2,3,4};
                gsl::span sp{v};
                static_assert(std::is_same<decltype(sp), gsl::span<int>>::value);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "gsl/span"}))
    end)
