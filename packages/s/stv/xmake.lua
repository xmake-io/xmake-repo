package("stv")
    set_kind("library", {headeronly = true})
    set_description("A Lightweight C String-View Library")
    set_homepage("https://github.com/AkarinATCP/stv")
    set_license("MIT")

    set_urls("https://github.com/AkarinATCP/stv/archive/refs/tags/v$(version).tar.gz")
    add_versions("2.2.0", "5beed1ca3fa388266ad26130175b31811c8e4eb6ee7e1613dc7e761291e77da5")

    on_install(function (package)
        os.cp("include/stv.h", package:installdir("include"))
    end)

    on_test(function (package)
        local language = (package:is_plat("windows") and "c11" or "c99")
        assert(package:check_csnippets({test = [[
            #include <stv.h>
            void test() {
                stv_new("Hello world");
            }
        ]]}, {configs = {languages = language}}))
    end)
