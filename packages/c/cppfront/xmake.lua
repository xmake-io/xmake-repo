package("cppfront")
    set_kind("binary")
    set_homepage("https://github.com/hsutter/cppfront")
    set_description("A personal experimental C++ Syntax 2 -> Syntax 1 compiler")

    add_urls("https://github.com/hsutter/cppfront.git")
    add_versions("2023.08.29", "b757afd9b0051a40278706cdfc57971e371e4e32")

    on_fetch(function (package, opt)
        if opt.system then
            return package:find_tool("cppfront", {check = "-h"})
        end
    end)

    on_install("windows", "linux", function (package)
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
    end)

    on_test(function (package)
        io.writefile("main.cpp2", [[
        main: () -> int =
            println("Hello world!\n");

        println: (msg: _) -> int = {
            std::cout << "msg: " << msg;
            return 0;
        }]])
        os.vrun("cppfront -o main.cpp main.cpp2")
    end)
