package("muda")
    set_kind("library", {headeronly = true})
    set_homepage("https://mugdxy.github.io/muda-doc")
    set_description("μ-Cuda, COVER THE LAST MILE OF CUDA. With features: intellisense-friendly, structured launch, automatic cuda graph generation and updating.")
    set_license("Apache-2.0")

    add_urls("https://github.com/MuGdxy/muda/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MuGdxy/muda.git", {includes = "src"})

    add_versions("2025.10.9", "8bce036e931ef3d46ac473d13ff684ac65f40b2d2d4caa8d5c81a1d721fd5251")

    add_deps("cuda")

    add_cuflags("--extended-lambda", "--expt-relaxed-constexpr")

    on_install(function (package)
        os.vcp("src/muda", package:installdir("include"))
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("include"), "muda/muda.h")))
    end)
