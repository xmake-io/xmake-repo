package("nowide_standalone")
    set_homepage("https://github.com/boostorg/nowide/tree/standalone")
    set_description("C++ implementation of the Python Numpy library")
    set_license("Boost Software License, Version 1.0")

    add_urls("https://github.com/boostorg/nowide/releases/download/v$(version)/nowide_standalone_v$(version).tar.gz",
             "https://github.com/boostorg/nowide/tree/standalone")
    add_versions("11.2.0", "1869d176a8af389e4f7416f42bdd15d6a5db3c6e4ae77269ecb071a232304e1d")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    end

    on_install("windows", "macosx", "linux", "mingw", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nowide/args.hpp>
            int test(int argc, char **argv)
            {
                nowide::args _(argc, argv); // Must use an instance!
                return argc;
            }
        ]]}))
    end)
