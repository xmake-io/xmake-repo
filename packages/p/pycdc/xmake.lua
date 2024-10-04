package("pycdc")
    set_homepage("https://github.com/zrax/pycdc")
    set_description("C++ python bytecode disassembler and decompiler")
    set_license("GPL-3.0")

    add_urls("https://github.com/zrax/pycdc.git")

    add_versions("2024.08.12", "dc6ca4ae36128f2674b5b4c9b0ce6fdda97d4df0")
    add_versions("2022.10.04", "44a730f3a889503014fec94ae6e62d8401cb75e5")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.run("pycdc --help")
            os.run("pycdas --help")
        end
        assert(package:check_cxxsnippets({test = [[
            #include "ASTree.h"
            void test() {
                PycModule mod;
                mod.loadFromFile("");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
