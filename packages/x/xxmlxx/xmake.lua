package("xxmlxx")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/luckydu-henry/xxmlxx")
    set_description("A very lightweight and efficient modern C++ xml library")
    set_license("MIT")

    add_urls("https://github.com/luckydu-henry/xxmlxx.git")

    add_versions("2025.09.30", "8439462a3eb59d4f3f2b83f4ddeb724e9e2bbd18")
    add_versions("2025.09.14", "8e290102820b75aacc60d5419ff955aea52d6514")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <vector>
                #include <format>
                #include <ranges>
                void test() {
                    std::vector nums{1, 2, 3};
                    auto fmt_nums = nums | std::views::transform([](int x) {
                        return std::format("{:02d}", x);
                    });
                }
            ]]}, {configs = {languages = "c++20"}}), "package(xxmlxx) Require at least C++20.")
        end)
    end

    on_install(function(package)
        os.cp("xxmlxx.hpp", package:installdir("include"))
    end)
    
    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                xxmlxx::document_parser parser(R"(
                    <?xml version="1.0" encoding="utf-8"?>
                    <XMLRoot>
                        <Data one="1.0"/>
                        <HelloMessage>Hello world!</HelloMessage>
                    </XMLRoot>
                )");
            }
        ]]}, {configs = {languages = "c++20"}, includes = "xxmlxx.hpp"}))
    end)
