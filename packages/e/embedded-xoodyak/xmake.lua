package("embedded-xoodyak")
    set_homepage("https://github.com/midnight-wonderer/embedded-xoodyak")
    set_description("A portable, lightweight, and zero-allocation C library implementing the Xoodyak cryptographic scheme")
    set_license("CC0-1.0")

    add_urls("https://github.com/midnight-wonderer/embedded-xoodyak/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/midnight-wonderer/embedded-xoodyak.git")

    add_versions("0.1.0", "37b977a4233efbb86270a67a02aaf6a897548ce4b95e624d532c1296d113e756")

    add_patches("0.1.0", "patches/0.1.0/fix-msvc-asm.patch", "0dae945231b4f141868387e0508ef213ea1f5771b0116a9736a614f87375ef61")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Xoodyak_Initialize", {includes = "Xoodyak.h"}))
    end)
