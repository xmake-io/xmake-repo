package("pocketpy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/blueloveTH/pocketpy")
    set_description("C++17 header-only Python interpreter for game engines.")
    set_license("MIT")

    add_urls("https://github.com/pocketpy/pocketpy/releases/download/$(version)/pocketpy.h")
    add_resources("v2.1.1", "c", "https://github.com/pocketpy/pocketpy/releases/download/v2.1.1/pocketpy.c", "587a83977525e11616d1bae748ae80dc50960e567b8c000a9ca6610b20681623")

    add_versions("v2.1.1", "d54aec6d75f7f7d03b862d4370e0014f9723715da901623bedc82ac72566caae")
    add_versions("v1.4.6", "fbbe335e55fabfd41146ba3287bd93c992135da057e2da09e47dd7dc77682a04")
    add_versions("v1.4.5", "144f63ed8a21fd2a65e252df53939f7af453d544eb35570603af319ce1af5a46")
    add_versions("v0.9.0", "0da63afb3ea4ebb8b686bfe33b4c7556c0a927cd98ccf3c7a3fb4aa216fbf30b")

    on_install("windows|x64", "linux", "macosx", "android", function (package)
        os.cp("../pocketpy-" .. package:version(), package:installdir("include") .. "/pocketpy.h")
        os.cp("../resources/c/pocketpy.c", package:installdir("include"))
    end)

    on_test("linux", "macosx", "android", function (package)
        if package:version():lt("v2.0.0") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    VM* vm = new VM();
                    vm->exec("print('Hello world!')");
                    vm->exec("a = [1, 2, 3]");
                    delete vm;
                }
            ]]}, {configs = {languages = "c++17"}, includes = {"pocketpy.h"}}))
        else
            assert(package:check_csnippets({test = [[
                void test() {
                    py_initialize();
                    py_exec("print('Hello world!')", "<string>", EXEC_MODE, NULL);
                    py_finalize();
                }
            ]]}, {configs = {languages = "c11"}, includes = {"pocketpy.h"}}))
        end
    end)

    on_test("windows|x64", function (package)
        if package:version():lt("v2.0.0") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    VM* vm = new VM();
                    vm->exec("print('Hello world!')");
                    vm->exec("a = [1, 2, 3]");
                    delete vm;
                }
            ]]}, {configs = {languages = "c++17", cxflags = "/utf-8"}, includes = {"pocketpy.h"}}))
        else
            assert(package:check_csnippets({test = [[
                void test() {
                    py_initialize();
                    py_exec("print('Hello world!')", "<string>", EXEC_MODE, NULL);
                    py_finalize();
                }
            ]]}, {configs = {languages = "c11", cflags = {"/utf-8", "/experimental:c11atomics"}}, includes = {"pocketpy.h"}}))
        end
    end)
