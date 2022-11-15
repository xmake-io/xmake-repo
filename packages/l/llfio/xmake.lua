package("llfio")
    set_kind("library")
    set_homepage("https://github.com/ned14/llfio")
    set_description("UTF8-CPP: UTF-8 with C++ in a Portable Way")
    set_license("Apache 2")

    add_urls("https://github.com/ned14/llfio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ned14/llfio.git")
    add_versions("all_tests_passed_ae7f9c5a92879285ad5100c89efc47ce1cb0031b", "a921d4c812fe3db98f0d4f7cb28c9fbdc5e2746a6b0283db5be03030557dcea6")

    add_deps("cmake")
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <llfio/llfio.hpp>
            void test () {
                namespace llfio = LLFIO_V2_NAMESPACE;
                llfio::file_handle fh = llfio::file({}, "foo").value();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
