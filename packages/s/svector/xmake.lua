package("svector")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinus/svector")
    set_description("Compact SVO optimized vector for C++17 or higher")
    set_license("MIT")

    add_urls("https://github.com/martinus/svector/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinus/svector.git")

    add_versions("v1.0.3", "40d597f5d8ade27059bef49012f23f2147c1a7dfbcd45492bb1057620c434b4f")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ankerl/svector.h>
            void test() {
                ankerl::svector<int, 3>{};
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
