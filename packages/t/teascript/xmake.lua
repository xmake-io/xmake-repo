package("teascript")
    set_kind("library", {headeronly = true})
    set_homepage("https://tea-age.solutions/teascript/overview-and-highlights/")
    set_description("TeaScript C++ Library - embedded scripting language for C++ Applications")
    set_license("MPL-2.0")

    add_urls("https://github.com/Florian-Thake/TeaScript-Cpp-Library/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Florian-Thake/TeaScript-Cpp-Library.git")

    add_versions("v0.16.0", "eee98f5ce8b460b487ccd61fded4cebe5322c2c2b85a4a298919ee2b51cd64cd")
    add_versions("v0.14.0", "9a6fd8eb3099dae092620f015b281ffbc22383969bedf08d54b62b6a2b0a0959")
    add_versions("v0.13.0", "7c8cc05a8775ee2c857278b5e353670bf02442b2fa3a411343e82b2b85eedced")

    add_patches("0.14.0", "patches/0.14.0/macosx.patch", "cae068739506806679f63e316ca4368f5750954d3083e525ae457abf973d672b")
    add_patches("0.16.0", "patches/0.16.0/macosx.patch", "bc0c37cbdbf1d6d2c4b59483cc8e9cde2690014680995020d9e3c7a9850aea78")

    add_configs("fmt", {description = "Use fmt for printing.", default = true, type = "boolean"})
    add_configs("toml++", {description = "Enable toml support.", default = true, type = "boolean"})

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <thread>

                int main() {
                    std::stop_source ss;
                    std::thread t([](std::stop_token st) {
                        while (!st.stop_requested()) {}
                    }, ss.get_token());
                    ss.request_stop();
                    t.join();
                    return 0;
                }
            ]]}, {configs = {languages = "c++20"}}), "package(teascript) Require std::stop_token support.")
        end)
    end

    on_load(function (package)
        if package:config("fmt") then
            package:add("deps", "fmt")
        end
        if package:config("toml++") then
            package:add("deps", "toml++")
        end
    end)

    on_install("windows", "linux", "macosx|arm64", "bsd", "msys", "mingw|i386", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "teascript/Engine.hpp"
            void test() {
                teascript::Engine engine;
                engine.ExecuteCode("println(\"Hello, World!\");");
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
