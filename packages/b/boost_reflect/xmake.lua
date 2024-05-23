package("boost_reflect")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/boost-ext/reflect")
    set_description("C++20 static reflection library")

    add_urls("https://github.com/boost-ext/reflect/archive/refs/tags/$(version).tar.gz",
             "https://github.com/boost-ext/reflect.git")

    add_versions("v1.1.1", "49b20cbc0e5d9f94bcdc96056f8c5d91ee2e45d8642e02cb37e511079671ad48")

    on_install("linux", function (package)
        os.cp("reflect", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <reflect>
            enum E { A, B };
            struct foo { int a; E b; };
            void test() {
                constexpr auto f = foo{.a = 42, .b = B};
                static_assert(2 == reflect::size(f));
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
