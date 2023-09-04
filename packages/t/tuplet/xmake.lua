package("tuplet")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/codeinred/tuplet")
    set_description("A fast, simple tuple implementation that implements tuple as an aggregate")
    set_license("BSL-1.0")

    add_urls("https://github.com/codeinred/tuplet/archive/refs/tags/$(version).tar.gz",
             "https://github.com/codeinred/tuplet.git")
    add_versions("v2.1.1", "2df403ffeed38a9687a3f2a7d2a68419ba029f519244e9bcd30caa0e8ec2ead3")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            void test() {
                tuplet::tuple tup = {1, 2, std::string("Hello, world!")};
            }
        ]]}, {configs = {languages = "c++17"}, includes = "tuplet/tuple.hpp"}))
    end)
