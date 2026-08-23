package("xoshiro-cpp")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/Reputeless/Xoshiro-cpp")
    set_description("Xoshiro-cpp is a header-only pseudorandom number generator library for modern C++.")
    set_license("MIT")

    add_urls("https://github.com/Reputeless/Xoshiro-cpp.git")
    add_versions("2021.08.04", "19bcbb2ce0ed158233187f524fd0964c105a65b3")

    on_install("windows", function(package)
        os.cp("XoshiroCpp.hpp", package:installdir("include"))
    end)

    on_test("windows", function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <XoshiroCpp.hpp>

            void test() {
                XoshiroCpp::Xoshiro256PlusPlus rng();
            }
        ]]}, { configs = { languages = "c++23" } }))
    end)
