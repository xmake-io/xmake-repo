package("coin-or-clp")
    set_homepage("https://github.com/coin-or/Clp")
    set_description("COIN-OR Linear Programming Solver")
    set_license("EPL-2.0")

    add_urls("https://github.com/coin-or/Clp/archive/refs/tags/releases/$(version).tar.gz",
             "https://github.com/coin-or/Clp.git")

    add_versions("1.17.10", "0d79ece896cdaa4a3855c37f1c28e6c26285f74d45f635046ca0b6d68a509885")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::coin-or-clp")
    elseif is_plat("linux") then
        add_extsources("apt::coinor-libclp-dev", "pacman::coin-or-clp")
    elseif is_plat("macosx") then
        add_extsources("brew::clp")
    end

    on_load(function (package)
        package:add("deps", "coin-or-coinutils", "coin-or-osi")
        package:add("defines", "COIN_HAS_COINUTILS", "COIN_HAS_OSI")
        if package:is_plat("linux") then
            package:add("deps", "lapack")
        end
    end)

    add_includedirs("include", "include/coin")

    on_install(function (package)
        io.replace("Clp/src/ClpSolve.cpp", "#define UFL_BARRIER", "", {plain = true})
        io.replace("Clp/src/ClpSolver.cpp", "extern glp_tran *cbc_glp_tran;\nextern glp_prob *cbc_glp_prob;",
                                            "glp_tran *cbc_glp_tran = NULL;\nglp_prob *cbc_glp_prob = NULL;", {plain = true})
        io.replace("Clp/src/CbcOrClpParam.cpp", [[#include "CoinTime.hpp"]],
                                                [[#include "CoinTime.hpp"
                                                  #include "CoinFinite.hpp"]], {plain = true})
        io.gsub("Clp/src/config.h.in", "# *undef (.-)\n", "${define %1}\n")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ClpSimplex.hpp>
            void test() {
                ClpSimplex model;
                double obj[] = {1.0, 1.0};
                CoinPackedMatrix matrix;
                matrix.setDimensions(0, 2);
                double colLB[] = {0.0, 0.0};
                double colUB[] = {COIN_DBL_MAX, COIN_DBL_MAX};
                model.loadProblem(matrix, colLB, colUB, obj, nullptr, nullptr);
                model.primal();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
