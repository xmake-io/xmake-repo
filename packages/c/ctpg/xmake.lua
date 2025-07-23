package("ctpg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/peter-winter/ctpg")
    set_description("Compile Time Parser Generator.")
    set_license("MIT")

    add_urls("https://github.com/peter-winter/ctpg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/peter-winter/ctpg.git")

    add_versions("v1.3.7", "6cc7c34de4983e21070599fd5693b65ef08cd5c8f42612e43b47eda723623429")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {
            "-DBUILD_TESTING=OFF"
        })
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace ctpg;
            using namespace ctpg::buffers;

            constexpr nterm<int> list("list");
            constexpr char number_pattern[] = "[1-9][0-9]*";
            constexpr regex_term<number_pattern> number("number");
            void test() {}
        ]]}, {configs = {languages = "c++17"}, includes = "ctpg/ctpg.hpp"}))
    end)
