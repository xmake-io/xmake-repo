package("injector")
    set_homepage("https://github.com/kubo/injector")
    set_description("Library for injecting a shared library into a Linux or Windows process")

    add_urls("https://github.com/kubo/injector.git")
    add_versions("2024.02.18", "c719b4f6b3bde75fd18d4d0c6b752a68dce593aa")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        if is_plat("windows") then
            import("package.tools.nmake").build(package, {"-f", "Makefile.win32"})
        elseif is_plat("linux", "macosx", "mingw") then
            os.vrunv("make", {})
        end
        os.cp("include/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <injector.h>
            void test() {
                injector_t *injector;
                injector_attach(&injector, 1234);
            }
        ]]}, {configs = {languages = "c"}}))
    end)
