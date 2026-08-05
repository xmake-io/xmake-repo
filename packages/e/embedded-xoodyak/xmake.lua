package("embedded-xoodyak")
    set_homepage("https://github.com/midnight-wonderer/embedded-xoodyak")
    set_description("A portable, lightweight, and zero-allocation C library implementing the Xoodyak cryptographic scheme")
    set_license("CC0-1.0")

    add_urls("https://github.com/midnight-wonderer/embedded-xoodyak/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/midnight-wonderer/embedded-xoodyak.git")

    add_versions("0.1.0", "37b977a4233efbb86270a67a02aaf6a897548ce4b95e624d532c1296d113e756")

    add_patches("0.1.0", "patches/0.1.0/fix-msvc-asm.patch", "2011966e92938663d5c6df833e5b89096c8a2e861ced040cf164e04b62d36f09")

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})
    end

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Xoodyak_Initialize", {includes = "Xoodyak.h"}))
    end)
