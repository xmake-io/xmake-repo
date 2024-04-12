package("teascript")
    set_homepage("https://tea-age.solutions/teascript/overview-and-highlights/")
    set_description("TeaScript C++ Library - embedded scripting language for C++ Applications")
    set_license("MPL-2.0")

    add_urls("https://github.com/Florian-Thake/TeaScript-Cpp-Library/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Florian-Thake/TeaScript-Cpp-Library.git")

    add_versions("v0.13.0", "7c8cc05a8775ee2c857278b5e353670bf02442b2fa3a411343e82b2b85eedced")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "teascript/Engine.hpp"
            void test() {
                teascript::Engine engine;
                engine.ExecuteCode("println(\"Hello, World!\");");
            }
        ]]}, {configs = {languages = "cxx20"}}))
    end)
