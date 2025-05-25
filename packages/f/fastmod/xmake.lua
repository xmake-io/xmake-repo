package("fastmod")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/lemire/fastmod")
    set_description("A header file for fast 32-bit division remainders on 64-bit hardware.")
    set_license("Apache-2.0")

    add_urls("https://github.com/lemire/fastmod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lemire/fastmod.git")

    add_versions("v0.1.0", "b80e759208d6b4318caa14b1851352c69e8c7a1f7895639e3af1d86944d2973b")

    add_deps("cmake")
    on_install("windows|x64", "windows|arm64", "android|arm64*", "macosx", "iphoneos", "linux", "bsd", "wasm", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fastmod_u32", {includes = "fastmod.h"}))
    end)
