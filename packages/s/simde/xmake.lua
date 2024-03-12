package("simde")

    set_kind("library", {headeronly = true})
    set_homepage("simd-everywhere.github.io/blog/")
    set_description("Implementations of SIMD instruction sets for systems which don't natively support them.")

    set_urls("https://github.com/simd-everywhere/simde/releases/download/v$(version)/simde-amalgamated-$(version).tar.xz")

    add_versions("0.7.6", "703eac1f2af7de1f7e4aea2286130b98e1addcc0559426e78304c92e2b4eb5e1")
    add_versions("0.7.2", "544c8aac764f0e24e444b1a7842d0314fa0231802d3b1b2020a03677b5be6142")

    on_install(function (package)
        os.cp("*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("x86/sse.h"))
        assert(package:has_cincludes("arm/neon.h"))
    end)
