package("pocketpy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/blueloveTH/pocketpy")
    set_description("C++17 header-only Python interpreter for game engines.")
    set_license("MIT")

    add_urls("https://github.com/pocketpy/pocketpy/releases/download/$(version)/pocketpy.h")

    add_versions("v2.1.6", "c0386447b589f2234552caeb7ebd1bf0176f7184606c64f49f0003dd080451a2")
    add_versions("v2.1.3", "fb2d1b594ddc46084d5e090e3e907da0d6769287152dba5d51288ac231ff7dfa")
    add_versions("v2.1.1", "d54aec6d75f7f7d03b862d4370e0014f9723715da901623bedc82ac72566caae")
    add_versions("v2.0.8", "9d6dada0fa9b661a44bcaf581f56ad15c7fe9ee18e0c719438f3332ccb3ac76f")
    add_versions("v1.4.6", "fbbe335e55fabfd41146ba3287bd93c992135da057e2da09e47dd7dc77682a04")
    add_versions("v1.4.5", "144f63ed8a21fd2a65e252df53939f7af453d544eb35570603af319ce1af5a46")
    add_versions("v0.9.0", "0da63afb3ea4ebb8b686bfe33b4c7556c0a927cd98ccf3c7a3fb4aa216fbf30b")

    add_resources("v2.1.6", "c", "https://github.com/pocketpy/pocketpy/releases/download/v2.1.6/pocketpy.c", "effd2aa317f2e1086b999d0e2f7d882fc6ff21dc23d9397f2082abbbc042e8f7")
    add_resources("v2.1.3", "c", "https://github.com/pocketpy/pocketpy/releases/download/v2.1.3/pocketpy.c", "ab4cbf3edd50dbbc5ca5a7ec7e7f2d001169541d9912330596400e0d34980d6b")
    add_resources("v2.1.1", "c", "https://github.com/pocketpy/pocketpy/releases/download/v2.1.1/pocketpy.c", "587a83977525e11616d1bae748ae80dc50960e567b8c000a9ca6610b20681623")
    add_resources("v2.0.8", "c", "https://github.com/pocketpy/pocketpy/releases/download/v2.0.8/pocketpy.c", "497f926dc270bfe1f9289db24068e596499c563aa8c946f63763a114c5d2bf5d")

    on_install("windows|x64", "linux", "macosx", "android", function (package)
        os.cp(package:originfile(), package:installdir("include") .. "/pocketpy.h")
        if package:version() and package:version():ge("v2.0.0") then
            os.cp(package:resourcefile("c"), package:installdir("include"))
        end
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
