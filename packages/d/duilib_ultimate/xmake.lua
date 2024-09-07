package("duilib_ultimate")
    set_homepage("https://github.com/qdtroy/DuiLib_Ultimate")
    set_description("DuiLib_Ultimate is the Optimized version for duilib library")
    set_license("MIT")

    add_urls("https://github.com/qdtroy/DuiLib_Ultimate/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qdtroy/DuiLib_Ultimate.git")

    add_versions("0.3", "4a650267e98d8b19818bdeb7675dcf1403017732b961620678e1d2d81f81db91")

    add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})
    add_configs("runtimes", {description = "Set vs compiler runtime.", default = "MT", type = "string", readonly = true})

    add_syslinks("gdi32", "comctl32", "imm32", "uuid", "winmm")

    on_install("windows|!arm64", function (package)
        if not package:config("shared") then
            package:add("defines", "UILIB_STATIC")
        end

        local configs = {"DuiLib.sln", "-t:DuiLib"}
        table.insert(configs, "/p:Configuration=" .. (package:is_debug() and "SDebug" or "SRelease"))
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))
        import("package.tools.msbuild").build(package, configs, {upgrade = {"DuiLib.sln"}})

        io.replace("DuiLib/Utils/downloadmgr.h", [[#pragma comment(lib,"uuid.lib")]], "", {plain = true})
        io.replace("DuiLib/UIlib.h", [[#pragma comment( lib, "comctl32.lib" )]], "", {plain = true})
        io.replace("DuiLib/UIlib.h", [[#pragma comment( lib, "GdiPlus.lib" )]], "", {plain = true})
        io.replace("DuiLib/UIlib.h", [[#pragma comment( lib, "Imm32.lib" )]], "", {plain = true})

        os.cp("Lib/*", package:installdir("lib"))
        os.cp("bin", package:installdir())
        os.cp ("DuiLib/**.h", package:installdir("include"), {rootdir="DuiLib"})
        os.cp ("DuiLib/Utils/Flash11.tlb", package:installdir("include") .. "/Utils/")
        os.cp ("DuiLib/Utils/flash11.tlh", package:installdir("include") .. "/Utils/")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "UIlib.h"
            using namespace DuiLib;
            void test() {
                CButtonUI *pButton = new CButtonUI();
            }
        ]]}))
    end)
