package("ssp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/red0124/ssp")
    set_description("C++ CSV parser")
    set_license("MIT")

    add_urls("https://github.com/red0124/ssp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/red0124/ssp.git")

    add_versions("v1.6.1", "4cdf75959b0a5fabd0b3e6ec1bad41d7c3f298d5b7f822d6e12b7e4d7dfcdd34")

    add_deps("cmake", "fast_float")

    on_install(function (package)
        import("package.tools.cmake").install(package, configs)
        os.tryrm(package:installdir("include", "fast_float"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ss/converter.hpp>
            void test() {
                auto converter = ss::converter{};
                auto val = converter.convert<int>("5");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
