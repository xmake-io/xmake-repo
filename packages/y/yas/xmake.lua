package("yas")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/niXman/yas")
    set_description("Yet Another Serialization")

    add_urls("https://github.com/niXman/yas.git")
    add_versions("2023.09.13", "7c5ced1d940ddc6826cf537468e65ea1f592bfe4")

    on_install(function (package)
        io.replace("include/yas/detail/config/endian.hpp",
        "|| defined(__ARM_ARCH_7S__)",
        "|| defined(__ARM_ARCH_7S__) || defined(_M_ARM64)", {plain = true})
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <yas/serialize.hpp>
            #include <yas/std_types.hpp>
            void test() {
                int a = 3, aa{};
                short b = 4, bb{};
                float c = 3.14, cc{};
                constexpr std::size_t flags = 
                    yas::mem // IO type
                    |yas::json; // IO format
                auto buf = yas::save<flags>(
                    YAS_OBJECT("myobject", a, b, c)
                );
                yas::load<flags>(buf,
                    YAS_OBJECT_NVP("myobject"
                        ,("a", aa)
                        ,("b", bb)
                        ,("c", cc)
                    )
                );
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
