package("duilib_ultimate")
    set_homepage("https://github.com/qdtroy/DuiLib_Ultimate")
    set_description("DuiLib_Ultimate is the Optimized version for duilib library")
    set_license("MIT")

    add_urls("https://github.com/qdtroy/DuiLib_Ultimate/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qdtroy/DuiLib_Ultimate.git")

    add_versions("0.3", "4a650267e98d8b19818bdeb7675dcf1403017732b961620678e1d2d81f81db91")

    add_configs("unicode", {description = "Enable Unicode support.", default = true, type = "boolean"})

    add_syslinks("gdi32", "comctl32", "imm32", "uuid", "winmm")

    on_install("windows|!arm64", function (package)
        local configs = {unicode = package:config("unicode")}
        if not package:config("shared") then
            package:add("defines", "UILIB_STATIC")
        end
        if configs.unicode then
            package:add("defines", "UNICODE", "_UNICODE")
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
        os.cp("bin", package:installdir())
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
