package("pycdc")
    set_homepage("https://github.com/zrax/pycdc")
    set_description("C++ python bytecode disassembler and decompiler")

    add_urls("https://github.com/zrax/pycdc.git")
    add_versions("2022.10.04", "44a730f3a889503014fec94ae6e62d8401cb75e5")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("python", {kind = "binary"})

    on_install("macosx", "linux", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.cp("*.h", package:installdir("include"))
        os.trycp("build/*.a", package:installdir("lib"))
        os.trycp("build/*.lib", package:installdir("lib"))
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
