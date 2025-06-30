package("fast_io")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cppfastio/fast_io")
    set_description("Significantly faster input/output for C++20")
    set_license("MIT")

    add_urls("https://github.com/cppfastio/fast_io.git")
    add_urls("https://bitbucket.org/ejsvifq_mabmip/fast_io.git")
    add_urls("https://gitee.com/qabeowjbtkwb/fast_io.git")

    add_versions("2023.1.28", "b99b32ab429eb6256fd8de1e17fe38e4c54eb49c")
    add_versions("2024.3.31", "a13c3ed1cd6da64b381322f3466f3b4fc9a80ff2")
    add_versions("2025.06.13", "8ba32f95ad3904d4b86704225e5d8527fc2202b2")

    on_load("mingw", function (package)
        package:add("defines", "_UCRT=0")
    end)

    on_install("windows", "linux", "macosx", "msys", "mingw", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        if package:version() == "2023.1.28" then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    print("Hello, fast_io world!\n");
                }
            ]]}, {configs = {languages = "c++20"}, includes = {"fast_io.h"}}))
        else 
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    fast_io::io::print("Hello, fast_io world!\n");
                }
            ]]}, {configs = {languages = "c++20"}, includes = {"fast_io.h"}}))
        end
    end)
