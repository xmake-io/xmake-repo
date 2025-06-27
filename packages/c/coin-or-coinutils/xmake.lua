package("coin-or-coinutils")
    set_homepage("https://github.com/coin-or/CoinUtils")
    set_description("COIN-OR Utilities")
    set_license("EPL-2.0")

    add_urls("https://github.com/coin-or/CoinUtils/archive/refs/tags/releases/$(version).tar.gz",
             "https://github.com/coin-or/CoinUtils.git")

    add_versions("2.11.12", "eef1785d78639b228ae2de26b334129fe6a7d399c4ac6f8fc5bb9054ba00de64")

    add_deps("bzip2", "zlib")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("Accelerate")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "COINLIBAPI=__declspec(dllexport)", "COINLINKAGE=__stdcall", "COINLINKAGE_CB=__cdecl")
        end
    end)

    on_install(function (package)
        io.replace("CoinUtils/src/CoinFinite.cpp", [[#include "CoinUtilsConfig.h"]], [[#include "CoinUtilsConfig.h"
#include <cfloat>]], {plain = true})
        io.gsub("CoinUtils/src/config.h.in", "# *undef (.-)\n", "${define %1}\n")
        io.gsub("CoinUtils/src/config_coinutils.h.in", "# *undef (.-)\n", "${define %1}\n")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <coin/CoinPackedVector.hpp>
            void test() {
                const int ne = 4;
                const int inx[ne] =   {  1,   4,  0,   2 };
                const double el[ne] = { 10., 40., 1., 50. };
                CoinPackedVector r(ne, inx, el);
                r.sortIncrElement();
                r.sortOriginalOrder();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
