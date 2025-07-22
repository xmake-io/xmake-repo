package("pffft")

    set_homepage("https://bitbucket.org/jpommier/pffft/")
    set_description("PFFFT, a pretty fast Fourier Transform.")
    set_license("BSD-like (FFTPACK license)")

    add_urls("https://bitbucket.org/jpommier/pffft/$(version)", {version = function (version)
        local hash = "02fe7715a5bf8bfd914681c53429600f94e0f536"
        if version:le("2024.11.29") then
            hash = "02fe7715a5bf8bfd914681c53429600f94e0f536"
        end
        return "get/" .. hash .. ".tar.gz"
    end})
    add_versions("2024.11.29", "9adeb18ac7bb52e9fb921c31c0c6a4e9ae150cc6fcb20a899d4b3a2275176ded")

    add_configs("simd", {description = "Build with SIMD support.", default = true, type = "boolean"})

    if not is_plat("windows") then
        add_syslinks("m")
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        configs.simd = package:config("simd")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pffft_simd_size", {includes = "pffft.h"}))
    end)
