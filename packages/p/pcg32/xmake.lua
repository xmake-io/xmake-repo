package("pcg32")
    set_homepage("https://github.com/wjakob/pcg32")
    set_description("Tiny self-contained C++ version of the PCG32 pseudorandom number generator")
    set_license("Apache-2.0")

    add_urls("https://github.com/wjakob/pcg32.git")

    on_install("windows", "linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            target("pcg32")
                set_kind("headeronly")
                add_headerfiles("pcg32.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <pcg32.h>
            pcg32 rng;
        ]]}, {configs = {languages = "cxx11"}}))
    end)
