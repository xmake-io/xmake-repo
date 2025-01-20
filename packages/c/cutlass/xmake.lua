package("cutlass")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/cutlass")
    set_description("CUDA Templates for Linear Algebra Subroutines")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/NVIDIA/cutlass/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/cutlass.git")

    add_versions("v3.7.0", "dfcafb7435a1b114ce32faee4f3257e276caf08f55fea04fa8bf3efa3a83c814")
    add_versions("v3.6.0", "7576f3437b90d0de5923560ccecebaa1357e5d72f36c0a59ad77c959c9790010")
    add_versions("v3.5.1", "20b7247cda2d257cbf8ba59ba3ca40a9211c4da61a9c9913e32b33a2c5883a36")
    add_versions("v3.5.0", "ef6af8526e3ad04f9827f35ee57eec555d09447f70a0ad0cf684a2e426ccbcb6")
    add_versions("v3.4.1", "aebd4f9088bdf2fd640d65835de30788a6c7d3615532fcbdbc626ec3754becd4")
    add_versions("v3.2.0", "9637961560a9d63a6bb3f407faf457c7dbc4246d3afb54ac7dc1e014dd7f172f")

    on_install(function (package)
        local source = os.dirs("cutlass*")
        if source and #source ~= 0 then
            os.cd(source[1])
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("cutlass/cutlass.h", {configs = {languages = "c++17"}}))
    end)
