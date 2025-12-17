package("microsoft-gsl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/GSL")
    set_description("Guidelines Support Library")
    set_license("MIT")

    add_urls("https://github.com/microsoft/GSL/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/GSL.git")

    add_versions("v4.2.1", "d959f1cb8bbb9c94f033ae5db60eaf5f416be1baa744493c32585adca066fe1f")
    add_versions("v4.2.0", "2c717545a073649126cb99ebd493fa2ae23120077968795d2c69cbab821e4ac6")
    add_versions("v4.1.0", "0a227fc9c8e0bf25115f401b9a46c2a68cd28f299d24ab195284eb3f1d7794bd")
    add_versions("v4.0.0", "f0e32cb10654fea91ad56bde89170d78cfbf4363ee0b01d8f097de2ba49f6ce9")
    add_versions("v3.1.0", "d3234d7f94cea4389e3ca70619b82e8fb4c2f33bb3a070799f1e18eef500a083")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DGSL_TEST=OFF", "-DGSL_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
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
