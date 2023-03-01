package("argparse")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/argparse")
    set_description("A single header argument parser for C++17")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/argparse/archive/refs/tags/v$(version).zip",
             "https://github.com/p-ranav/argparse.git")
    add_versions("2.6", "ce4e58d527b83679bdcc4adfa852af7ec9df16b76c11637823ef642cb02d2618")
    add_versions("2.7", "58cf098fd195895aeb9b9120d96f1e310994b2f44d72934c438ec91bf2191f46")
    add_versions("2.8", "9381b9ec2bdd2a350d1a0bf96d631969e3fda0cf2696e284d1359b5ee4ebb465")
    add_versions("2.9", "55396ae05d9deb8030b8ad9babf096be9c35652d5822d8321021bcabb25f4b72")

    on_install(function (package)
        os.cp("include/argparse/argparse.hpp", package:installdir("include/argparse"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                argparse::ArgumentParser test("test");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "argparse/argparse.hpp"}))
    end)
