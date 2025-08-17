package("boost_reflect")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/boost-ext/reflect")
    set_description("C++20 static reflection library")

    add_urls("https://github.com/boost-ext/reflect/archive/refs/tags/$(version).tar.gz",
             "https://github.com/boost-ext/reflect.git")

    add_versions("v1.2.6", "2991391d326886a20522ee376c04dceb4ad200ffba909bbce9a4cbe655b61ab8")
    add_versions("v1.2.4", "8844faf7e282d9b9841fdee89b3ccfa80a800d7c35b6575c5f64cfa5946e0854")
    add_versions("v1.2.3", "583fe281c3b83f403b7fb18389e64bacc3ca0b30683d550f2ad6159cc0ebb6be")
    add_versions("v1.1.1", "49b20cbc0e5d9f94bcdc96056f8c5d91ee2e45d8642e02cb37e511079671ad48")

    if on_check then
        on_check("windows", function (package)
            import("core.base.semver")

            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            assert(vs_toolset and semver.new(vs_toolset):minor() >= 30, "package(boost_reflect) require vs_toolset >= v143")
        end)
    end

    on_install("windows", "mingw", "linux", function (package)
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
