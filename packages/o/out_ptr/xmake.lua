package("out_ptr")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/soasis/out_ptr")
    set_description("Repository for a C++11 implementation of std::out_ptr (p1132), as a standalone library!")
    set_license("Apache-2.0")

    add_urls("https://github.com/soasis/out_ptr.git")
    add_versions("2022.10.07", "c9190f7febbcfcb183e34fe8449bcea80efb28d2")

    on_install(function (package)
        os.cp("include/ztd", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <memory>
            #include <ztd/out_ptr.hpp>

            struct S {};

            struct Deleter {
                void operator()(S*) {}
            };

            void withRawPtr(S**) {}

            void test() {
                std::unique_ptr<S, Deleter> ptr;
                withRawPtr(ztd::out_ptr::out_ptr(ptr));
                withRawPtr(ztd::out_ptr::inout_ptr(ptr));
            }
        ]]}, {configs = {languages = "cxx14"}}))
    end)
