package("cuda-samples")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/cuda-samples")
    set_description("CUDA Sample Utility Code")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/NVIDIA/cuda-samples/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/cuda-samples.git")
    add_versions("v13.1", "03d7748a773fcd2350c2de88f2d167252c78ea90a52e229e7eb2a6922e3ba350")
    add_versions("v13.0", "63cc9d5d8280c87df3c1f4e2276234a0f42cc497c52b40dd5bdda2836607db79")
    add_versions("v12.9", "2e67e1f6bdb15bf11b21e07e988e2f9f60fb054eff51ef01cebdd47229788015")
    add_versions("v12.8", "fe82484f9a87334075498f4e023a304cc70f240a285c11678f720f0a1e54a89d")
    add_versions("v12.5", "5c40cc096706045b067ec5897f039403014aa7a39b970905698466a2d029b972")
    add_versions("v12.4.1", "01bb311cc8f802a0d243700e4abe6a2d402132c9d97ecf2c64f3fbb1006c304c")
    add_versions("v11.8", "1bc02c0ca42a323f3c7a05b5682eae703681a91e95b135bfe81f848b2d6a2c51")
    add_versions("v12.3", "a40e4d3970185f38477dd8b5bdbd81642b04648d8b812af914333b8f83355efe")

    on_fetch(function (package, opt)
        if opt.system and package:is_plat("windows") then
            import("lib.detect.find_path")
            local paths = {
                "C:\\ProgramData\\NVIDIA Corporation\\CUDA Samples\\v*\\common"
            }
            local headerpath = find_path("helper_cuda.h", paths, {suffixes = {"inc"}})
            if headerpath then
                vprint("CUDA Samples Found: " .. path.directory(headerpath))
                return {includedirs = {headerpath}}
            end
        end
    end)

    add_includedirs("include/Common")
    on_install(function (package)
        os.cp("Common", package:installdir("include"))
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("include"), "Common", "helper_cuda.h")))
    end)
