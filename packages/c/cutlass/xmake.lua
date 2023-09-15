package("cutlass")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/cutlass")
    set_description("CUDA Templates for Linear Algebra Subroutines")

    add_urls("https://github.com/NVIDIA/cutlass/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/cutlass.git")

    add_versions("v3.2.0", "9637961560a9d63a6bb3f407faf457c7dbc4246d3afb54ac7dc1e014dd7f172f")

    on_install(function (package)
        local source = os.dirs("cutlass*")
        if source then
            os.cd(source[1])
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("cutlass/cutlass.h", {configs = {languages = "c++17"}}))
    end)
