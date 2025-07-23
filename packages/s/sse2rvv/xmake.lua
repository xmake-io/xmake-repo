package("sse2rvv")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/pattonkan/sse2rvv")
    set_description("A translator from Intel SSE intrinsics to RISCV-V Extension implementation")
    set_license("MIT")

    add_urls("https://github.com/pattonkan/sse2rvv/archive/58b524e3f3cb8732118194f2920a343a5c5ce530.tar.gz",
             "https://github.com/pattonkan/sse2rvv.git")

    add_versions("2024.02.18", "e41e24195fda914c0ef85671c202e43d0e3bf86a63ece6564c539ad60f571bd1")

    on_install(function (package)
        assert(package:is_arch("riscv.*"), "package(sse2rvv): only support riscv")
        os.vcp("sse2rvv.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("sse2rvv.h"))
    end)
