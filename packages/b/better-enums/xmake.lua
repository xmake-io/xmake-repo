package("better-enums")
    set_kind("library", { headeronly = true })
    set_homepage("http://aantron.github.io/better-enums")
    set_description("C++ compile-time enum to string, iteration, in a single header file")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/aantron/better-enums/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aantron/better-enums.git")
    add_versions("0.11.3", "1b1597f0aa5452b971a94ab13d8de3b59cce17d9c43c8081aa62f42b3376df96")

    on_install(function (package)
        os.cp("enum.h", package:installdir(path.join("include", "better-enums")))
        os.cp("extra/better-enums/*.h", package:installdir(path.join("include", "better-enums")))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>

            BETTER_ENUM(Word, int, Hello, World)

            void test() {
                std::cout << (+Word::Hello)._to_string() << ", " << (+Word::World)._to_string() << "!" << std::endl;
            }
        ]]}, {configs = {languages = "cxx11"}, includes = "better-enums/enum.h"}))

        assert(package:check_cxxsnippets({test = [[
            #ifndef BETTER_ENUMS_CONSTEXPR_TO_STRING
            #define BETTER_ENUMS_CONSTEXPR_TO_STRING
            #endif

            #include <iostream>
            #include <better-enums/enum.h>
            #include <better-enums/n4428.h>

            BETTER_ENUM(Channel, char, Red = 1, Green, Blue)

            constexpr std::size_t size = std::enum_traits<Channel>::enumerators::size;
            constexpr Channel value_0 = std::enum_traits<Channel>::enumerators::get<0>::value;
            constexpr Channel value_1 = std::enum_traits<Channel>::enumerators::get<1>::value;
            constexpr const char *identifier_2 = std::enum_traits<Channel>::enumerators::get<2>::identifier;

            static_assert(size == 3, "");
            static_assert(value_0 == +Channel::Red, "");
            static_assert(value_1 == +Channel::Green, "");

            void test()
            {
                std::cout << identifier_2 << std::endl;
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
