package("fast_io")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cppfastio/fast_io")
    set_description("Significantly faster input/output for C++20")
    set_license("MIT")

    add_urls("https://github.com/cppfastio/fast_io.git")
    add_urls("https://bitbucket.org/ejsvifq_mabmip/fast_io.git")
    add_urls("https://gitee.com/qabeowjbtkwb/fast_io.git")

    on_install(function (package)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                print("Hello, fast_io world!\n");
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"fast_io.h"}}))
    end)
