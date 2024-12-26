package("pffft")

    set_homepage("https://bitbucket.org/jpommier/pffft/")
    set_description("PFFFT, a pretty fast Fourier Transform.")
    set_license("BSD-like (FFTPACK license)")

    add_urls("https://bitbucket.org/jpommier/pffft/get/$(version).zip")
    add_versions("02fe7715a5bf", "81e1b91bad77092681e5ed6c2eef1a3bae7eb2154d3358a10c663867cd947396")

    add_configs("nosimd", {description = "Build without SIMD support.", default = false, type = "boolean"})

    add_deps("cmake")
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
