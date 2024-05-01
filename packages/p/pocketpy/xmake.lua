package("pocketpy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/blueloveTH/pocketpy")
    set_description("C++17 header-only Python interpreter for game engines.")
    set_license("MIT")

    add_urls("https://github.com/pocketpy/pocketpy/releases/download/$(version)/pocketpy.h")

    add_versions("v1.4.5", "144f63ed8a21fd2a65e252df53939f7af453d544eb35570603af319ce1af5a46")
    add_versions("v0.9.0", "0da63afb3ea4ebb8b686bfe33b4c7556c0a927cd98ccf3c7a3fb4aa216fbf30b")

    on_install("windows|x64", "linux", "macosx", "android", function (package)
        os.cp("../pocketpy.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                // Create a virtual machine
                VM* vm = new VM();

                // Hello world!
                vm->exec("print('Hello world!')");

                // Create a list
                vm->exec("a = [1, 2, 3]");

                // Dispose the virtual machine
                delete vm;
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"pocketpy.h"}}))
    end)
