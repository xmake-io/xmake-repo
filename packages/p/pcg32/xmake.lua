package("pcg32")
    set_homepage("https://github.com/wjakob/pcg32")
    set_description("Tiny self-contained C++ version of the PCG32 pseudorandom number generator")
    set_license("Apache-2.0")

    add_urls("https://github.com/wjakob/pcg32.git")

    -- A fake version since no any releases/tags
    add_versions("2016.06.07", "70099eadb86d3999c38cf69d2c55f8adc1f7fe34")

    on_install("windows", "linux", "macosx", function (package)
        os.cp("pcg32.h", package:installdir("include/pcg32"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            pcg32 rng;
        ]]}, {configs = {languages = "cxx17"}, includes = "pcg32/pcg32.h"}))
    end)
