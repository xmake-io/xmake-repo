package("cppfront")
    set_kind("toolchain")
    set_homepage("https://github.com/hsutter/cppfront")
    set_description("A personal experimental C++ Syntax 2 -> Syntax 1 compiler")

    add_urls("https://github.com/hsutter/cppfront/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/hsutter/cppfront.git")
    add_versions("v0.8.1", "aff7c8106c1022d74dcd2e66452f8e7cbafeeecb61679f7116a383a1100cc4b5")
    add_versions("v0.8.0", "7fb573599960bc0a46a71ed103ff97adbf938d4a0df754dc952a44fdcacfc571")
    add_versions("v0.7.4", "028f44cc0cad26b51829e4abf7c5aedf8a31f852ab5dfbad54bb232f0a1d7447")
    add_versions("v0.7.2", "fb44c6a65fa19b185ddf385dd3bfea05afe0bc8260382b7a8e3c75b3c9004cd6")
    add_versions("v0.7.0", "d4ffb37d19a2b7c054d005cf4687439577ef2f3d93b340a342704e064cd1d047")

    on_fetch(function (package, opt)
        if opt.system then
            return package:find_tool("cppfront", {check = "-h"})
        end
    end)

    on_check(function (package)
        if package:is_plat("windows") then
            local vs = package:toolchain("msvc"):config("vs")
            assert(vs and tonumber(vs) >= 2022, "package(cppfront): need vs >= 2022.")
        end
        assert(package:check_cxxsnippets({test = [[
            #include <compare>
            void test() {
                std::compare_three_way{};
            }
        ]]}, {configs = {languages = "c++20"}}), "package(cppfront): requires at least C++20.")
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("cppfront")
               set_kind("binary")
               add_files("source/*.cpp")
               add_includedirs("include")
               set_languages("c++20")
        ]])
        import("package.tools.xmake").install(package, configs)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        io.writefile("main.cpp2", [[
            main: () -> int =
                println("Hello world!\n");
    
            println: (msg: _) -> int = {
                std::cout << "msg: " << msg;
                return 0;
            }
        ]])
        os.vrun("cppfront -o main.cpp main.cpp2")
    end)
