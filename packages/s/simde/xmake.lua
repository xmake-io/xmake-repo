package("simde")
    set_kind("library", {headeronly = true})
    set_homepage("simd-everywhere.github.io/blog/")
    set_description("Implementations of SIMD instruction sets for systems which don't natively support them.")
    set_license("MIT")

    add_urls("https://github.com/simd-everywhere/simde/releases/download/v$(version)/simde-amalgamated-$(version).tar.xz")
    add_urls("https://github.com/simd-everywhere/simde.git", {submodules = false})

    -- add_versions("0.8.0", "7c8dd4d613b18724b7ef3dcd1d58739a91501ed80ace916cbca9b8c13e5b92bb")
    -- add_versions("0.7.6", "703eac1f2af7de1f7e4aea2286130b98e1addcc0559426e78304c92e2b4eb5e1")
    add_versions("0.7.2", "544c8aac764f0e24e444b1a7842d0314fa0231802d3b1b2020a03677b5be6142")

    on_install(function (package)
        if package:gitref() or (not package:version()) then
            os.cp("simde/*", package:installdir("include"))
        else
            os.cp("*", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("x86/sse.h"))
        assert(package:has_cincludes("arm/neon.h"))
    end)
