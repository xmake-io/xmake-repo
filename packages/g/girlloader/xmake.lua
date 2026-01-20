package("girlloader")
    set_homepage("https://github.com/Lynnette177/GirlLoader")
    set_description("G.I.R.L loader")

    add_urls("https://github.com/Lynnette177/GirlLoader.git")
    add_versions("2025.06.28", "2eba444d4d09c8bbe3c2ba92973131c9467ab78d")

    add_deps("base64-zhicheng")

    on_install("android", function (package)
        os.rm("Utility/base64.cpp", "Utility/base64.h")
        io.replace("Communicate/TcpServer.h", 
           [[#include "../Utility/base64.h"]], 
           [[#ifdef __cplusplus
             extern "C" {
             #endif
             #include <base64.h>
             #ifdef __cplusplus
             }
             #endif]], {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c99", "c++11")

            add_requires("base64-zhicheng")

            target("girlloader")
                set_kind("binary")
                add_files(  
                    "Communicate/Communicate.cpp",
                    "Communicate/TcpServer.cpp",
                    "main.cpp")
                add_includedirs("include")
                add_packages("base64-zhicheng")
                add_syslinks("log")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(os.isfile(package:installdir("bin", "girlloader")))
    end)
