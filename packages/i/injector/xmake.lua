package("injector")
    set_homepage("https://github.com/kubo/injector")
    set_description("Library for injecting a shared library into a Linux or Windows process")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kubo/injector.git")
    add_versions("2024.02.18", "c719b4f6b3bde75fd18d4d0c6b752a68dce593aa")

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32", "dbghelp", "psapi")
    end

    on_install("windows", "linux", "macosx", "mingw", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <injector.h>
            void test() {
                injector_t *injector;
                injector_attach(&injector, 1234);
            }
        ]]}))
    end)
