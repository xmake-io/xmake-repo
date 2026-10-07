package("reflect")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qlibs/reflect")
    set_description("C++20 Static Reflection library")
    set_license("MIT")

    add_urls("https://github.com/qlibs/reflect/archive/refs/tags/$(version).tar.gz")

    add_versions("v1.2.6", "2991391d326886a20522ee376c04dceb4ad200ffba909bbce9a4cbe655b61ab8")

    add_patches("v1.2.6", "patches/msvc-1950-fix-constexpr.patch", "22ca6dad37ad4074984787ebeab5c138af5bc1cb0ec5e6eabca86bb01190c4a6")

    on_check(function (package)
        if package:is_plat("android") then
            if not package:check_cxxsnippets({
                test = [[
                    #include <source_location>
                    void test() {
                        auto loc = std::source_location::current();
                    }
                ]]
            }, {configs = {languages = "c++20"}}) then
                raise("Reflect package requires std::source_location (NDK r26+)")
            end
        end
    end)

    on_install(function (package)
        os.cp("reflect", package:installdir("include"))
        os.cp("reflect.cppm", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <reflect>
            struct foo { int a; };
            void test() {
                foo f{42};
                (void)reflect::size(f);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
