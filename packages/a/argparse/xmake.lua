package("argparse")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/argparse")
    set_description("A single header argument parser for C++17")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/argparse/archive/refs/tags/$(version).zip",
             "https://github.com/p-ranav/argparse.git")
    add_versions("v3.2", "14c1a0e975d6877dfeaf52a1e79e54f70169a847e29c7e13aa7fe68a3d0ecbf1")
    add_versions("v3.1", "3e5a59ab7688dcd1f918bc92051a10564113d4f36c3bbed3ef596c25e519a062")
    add_versions("v3.0", "674e724c2702f0bfef1619161815257a407e1babce30d908327729fba6ce4124")
    add_versions("v2.6", "ce4e58d527b83679bdcc4adfa852af7ec9df16b76c11637823ef642cb02d2618")
    add_versions("v2.7", "58cf098fd195895aeb9b9120d96f1e310994b2f44d72934c438ec91bf2191f46")
    add_versions("v2.8", "9381b9ec2bdd2a350d1a0bf96d631969e3fda0cf2696e284d1359b5ee4ebb465")
    add_versions("v2.9", "55396ae05d9deb8030b8ad9babf096be9c35652d5822d8321021bcabb25f4b72")

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
