package("cutlass")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/cutlass")
    set_description("CUDA Templates for Linear Algebra Subroutines")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/NVIDIA/cutlass/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/cutlass.git")

    add_versions("v4.3.5", "73d8c3914a6049ff5c43b7dfb9d70f26e44dc9e10e36049db5a999b9faf6dbf0")
    add_versions("v4.3.4", "8b3ce84c63ab070fc7e0cc1ea093b92c2a83a1002f4833b8e41d5d3167310c33")
    add_versions("v4.3.3", "f232806a955f91b47c005f30ad2b384ac8ab7c50bafdf25e95b821ffcbae84a8")
    add_versions("v4.2.1", "a4513ba33ae82fd754843c6d8437bee1ac71a6ef1c74df886de2338e3917d4df")
    add_versions("v4.2.0", "6a3d78bb59202cd4e086d8d4b4ecb5767773c83c87c2c0dee03e7128c3472eea")
    add_versions("v4.1.0", "8d4675b11e9e5207e3940eaac0f46db934ada371cbb3627c9fda642d912b6230")
    add_versions("v4.0.0", "44a121c5878827875856c175ebe82e955062e37cd61fcdf31ebe2e8874f2fc5c")
    add_versions("v3.9.0", "0ea98a598d1f77fade5187ff6ec6d9e6ef3acd267ee68850aae6e800dcbd69c7")
    add_versions("v3.8.0", "14a5e6314f23e41295d8377b6fa6028b35392757a0ee4538a4eacaaa5d7eee37")
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
