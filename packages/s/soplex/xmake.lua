package("soplex")

    set_homepage("https://soplex.zib.de/")
    set_description("SoPlex is an optimization package for solving linear programming problems (LPs) based on an advanced implementation of the primal and dual revised simplex algorithm.")

    add_urls("https://soplex.zib.de/download/release/soplex-$(version).tgz")
    add_versions("5.0.2", "eaaf3b1d0e8832b25e9f4c1e44bd935c869a487b26e86c2c41856f850b22f4dd")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake", "zlib")
    if is_plat("macosx", "linux") then
        add_deps("gmp")
    end
    add_links("soplex")
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBOOST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DMT=" .. ((package:config("runtimes") and package:has_runtime("MT", "MTd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MT")) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <soplex.h>
            void test() {
                using namespace soplex;
                SoPlex mysoplex;
                mysoplex.setIntParam(SoPlex::OBJSENSE, SoPlex::OBJSENSE_MINIMIZE);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
