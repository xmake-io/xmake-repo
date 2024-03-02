package("injector")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/kubo/injector")
    set_description("Library for injecting a shared library into a Linux or Windows process")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kubo/injector.git")
    add_versions("2024.02.18", "c719b4f6b3bde75fd18d4d0c6b752a68dce593aa")

    on_install("windows", function (package)
        io.replace("Makefile.win32", "cd cmd && $(MAKE_CMD)", "", {plain = true})
        import("package.tools.nmake").build(package, {"-f", "Makefile.win32"})
        os.cp("include/*.h", package:installdir("include"))
    end)

    on_install("linux", "macosx", "mingw",function (package)
        io.replace("Makefile", "cd cmd && $(MAKE_CMD)", "", {plain = true})
        os.vrunv("make", {})
        os.cp("include/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <injector.h>
            void test() {
                injector_t *injector;
                injector_attach(&injector, 1234);
            }
        ]]}))
    end)
