package("boost_reflect")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/boost-ext/reflect")
    set_description("C++20 static reflection library")

    add_urls("https://github.com/boost-ext/reflect/archive/refs/tags/$(version).tar.gz",
             "https://github.com/boost-ext/reflect.git")

    add_versions("v1.0.0", "a4a65b94013008a215e639ed0bf334f848209ad2694d3645a154b28962d88e3b")

    on_install(function (package)
        os.cp("reflect", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <reflect>
            void test() {
                struct foo { int a; int b; };
                static_assert(2 == reflect::visit([](auto&&... args) { return sizeof...(args); }, foo{}));
                static_assert(2 == reflect::size<foo>);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
