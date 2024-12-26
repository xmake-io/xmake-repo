package("pffft")

    set_homepage("https://bitbucket.org/jpommier/pffft/")
    set_description("PFFFT, a pretty fast Fourier Transform.")
    set_license("BSD-like (FFTPACK license)")
    add_urls("https://bitbucket.org/jpommier/pffft.git")
    add_configs("nosimd", {description = "Build without SIMD support.", default = false, type = "boolean"})

    if not is_plat("windows") then
        add_syslinks("m")
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        if package:config("nosimd") then
            table.insert(configs, "-DPFFFT_SIMD_DISABLE=ON")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pffft_simd_size", {includes = "pffft.h"}))
    end)
