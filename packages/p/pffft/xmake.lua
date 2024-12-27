package("pffft")

    set_homepage("https://bitbucket.org/jpommier/pffft/")
    set_description("PFFFT, a pretty fast Fourier Transform.")
    set_license("BSD-like (FFTPACK license)")

    add_urls("https://bitbucket.org/jpommier/pffft.git")

    add_configs("simd", {description = "Build with SIMD support.", default = true, type = "boolean"})

    if not is_plat("windows") then
        add_syslinks("m")
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pffft_simd_size", {includes = "pffft.h"}))
    end)
