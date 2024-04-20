package("cuda-samples")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/cuda-samples")
    set_description("CUDA Sample Utility Code")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/NVIDIA/cuda-samples/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/cuda-samples.git")
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
