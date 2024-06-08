package("sse2neon")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/DLTcollab/sse2neon")
    set_description("A translator from Intel SSE intrinsics to Arm/Aarch64 NEON implementation")
    set_license("MIT")

    add_urls("https://github.com/DLTcollab/sse2neon/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DLTcollab/sse2neon.git")

    add_versions("v1.7.0", "cee6d54922dbc9d4fa57749e3e4b46161b7f435a22e592db9da008051806812a")

    if is_plat("windows") then
        add_cxxflags("/Zc:preprocessor")
    end

    on_check(function (package)
        assert(package:is_arch("arm.*"), "package(sse2neon): only support arm")
    end)

    on_install(function (package)
        assert(package:is_arch("arm.*"), "package(sse2neon): only support arm")
        os.vcp("sse2neon.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("sse2neon.h"))
    end)
