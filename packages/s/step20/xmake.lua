package("step20")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/storm-ptr/step20")
    set_description("Step20 is a C++20, header-only library of STL-like algorithms and data structures")
    set_license("MIT")

    add_urls("https://github.com/storm-ptr/step20.git")
    add_versions("2023.08.21", "4b163b99f05da6de96fe67879c200d80055adc87")

    on_install(function (package)
        os.cp("*.hpp", package:installdir("include/step20"))
        os.cp("detail/*.hpp", package:installdir("include/step20/detail"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <step20/to.hpp>
            #include <array>
            #include <vector>
            void test() {
                std::array arr{1, 2, 3, 4, 5};
                auto vec = step20::to<std::vector<int>>(arr);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)

