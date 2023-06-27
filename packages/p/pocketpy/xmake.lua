package("pocketpy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/blueloveTH/pocketpy")
    set_description("C++17 header-only Python interpreter for game engines.")
    set_license("MIT")

    add_urls("https://github.com/blueloveTH/pocketpy/releases/download/$(version)/pocketpy.h")

    add_versions("v0.9.0", "0da63afb3ea4ebb8b686bfe33b4c7556c0a927cd98ccf3c7a3fb4aa216fbf30b")

    on_install("windows|x64", "linux", "macosx", "android", function (package)
        os.cp("../pocketpy.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                VM* vm = pkpy_new_vm(true);
                pkpy_vm_exec(vm, "print('Hello world!')");
                pkpy_vm_exec(vm, "a = [1, 2, 3]");
                char* result = pkpy_vm_eval(vm, "sum(a)");
                printf("%s", result);
                pkpy_delete(result);
                pkpy_delete(vm);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"pocketpy.h"}}))
    end)
