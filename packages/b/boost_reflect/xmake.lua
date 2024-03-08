package("boost_reflect")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/boost-ext/reflect")
    set_description("C++20 static reflection library")

    add_urls("https://github.com/boost-ext/reflect/archive/refs/tags/$(version).tar.gz",
             "https://github.com/boost-ext/reflect.git")

    add_versions("v1.0.9", "459e6f42bea5aa9cbf94ac32900d01454a6f65f2d426f2c89f6881bf187f3464")

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
