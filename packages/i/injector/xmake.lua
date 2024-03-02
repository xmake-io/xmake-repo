package("injector")
    set_homepage("https://github.com/kubo/injector")
    set_description("Library for injecting a shared library into a Linux or Windows process")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kubo/injector.git")
    add_versions("2024.02.18", "c719b4f6b3bde75fd18d4d0c6b752a68dce593aa")

    on_install("windows", function (package)
        io.replace("Makefile.win32", "cd cmd && $(MAKE_CMD)", "", {plain = true})
        import("package.tools.nmake").build(package, {"-f", "Makefile.win32"})
        os.cp("include/*.h", package:installdir("include"))
        if package:config("shared") then
            os.cp("src/windows/injector.dll", package:installdir("bin"))
            os.cp("src/windows/injector.lib", package:installdir("lib"))
        else
            os.cp("src/windows/injector-static.lib", package:installdir("lib"))
        end
    end)

    on_install("linux", function (package)
        os.cd("src/linux")
        os.vrunv("make", {"install", "PREFIX=" .. package:installdir()})
        os.cp("include/*.h", package:installdir("include"))
    end)

    on_install("macosx",function (package)
        os.cd("src/macos")
        os.vrunv("make", {"install", "PREFIX=" .. package:installdir()})
        os.cp("include/*.h", package:installdir("include"))
    end)

    on_install("mingw",function (package)
        os.cd("src/windows")
        os.vrunv("make", {"install", "all", "PREFIX=" .. package:installdir()})
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
