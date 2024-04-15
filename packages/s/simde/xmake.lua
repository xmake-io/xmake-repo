package("simde")

    set_kind("library", {headeronly = true})
    set_homepage("simd-everywhere.github.io/blog/")
    set_description("Implementations of SIMD instruction sets for systems which don't natively support them.")

    set_urls("https://github.com/simd-everywhere/simde/releases/download/v$(version)/simde-amalgamated-$(version).tar.xz")

    add_versions("0.8.0", "7c8dd4d613b18724b7ef3dcd1d58739a91501ed80ace916cbca9b8c13e5b92bb")
    add_versions("0.7.2", "544c8aac764f0e24e444b1a7842d0314fa0231802d3b1b2020a03677b5be6142")

    on_install(function (package)
        os.cp("*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("x86/sse.h"))
        assert(package:has_cincludes("arm/neon.h"))
    end)
