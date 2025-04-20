package("pycdc")
    set_homepage("https://github.com/zrax/pycdc")
    set_description("C++ python bytecode disassembler and decompiler")
    set_license("GPL-3.0")

    add_urls("https://github.com/zrax/pycdc.git")

    add_versions("2024.08.12", "dc6ca4ae36128f2674b5b4c9b0ce6fdda97d4df0")

    if is_plat("windows") and is_arch("arm.*") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

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
