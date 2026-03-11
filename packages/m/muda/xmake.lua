package("muda")
    set_kind("library", {headeronly = true})
    set_homepage("https://mugdxy.github.io/muda-doc")
    set_description("μ-Cuda, COVER THE LAST MILE OF CUDA. With features: intellisense-friendly, structured launch, automatic cuda graph generation and updating.")
    set_license("Apache-2.0")

    add_urls("https://github.com/MuGdxy/muda/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MuGdxy/muda.git", {includes = "src"})

    add_versions("2025.12.25", "09f8a0beca898b5325c7b0c1e4cf67ea4781f3b9")

    add_configs("check", {description = "Enable muda check", default = true, type = "boolean"})
    add_configs("compute_graph", {description = "Enable muda compute graph", default = false, type = "boolean"})

    add_cuflags("--extended-lambda", "--expt-relaxed-constexpr", "-rdc=true")

    on_install(function (package)
        package:add("defines", "MUDA_CHECK_ON=" .. (package:config("check") and "1" or "0"))
        package:add("defines", "MUDA_COMPUTE_GRAPH_ON=" .. (package:config("compute_graph") and "1" or "0"))

        os.cp("src/muda", package:installdir("include"))
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("include"), "muda/muda.h")))
    end)
