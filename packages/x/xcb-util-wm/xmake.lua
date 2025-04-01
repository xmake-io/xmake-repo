
package("xcb-util-wm")
    set_homepage("https://xcb.freedesktop.org")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-util-wm-$(version).tar.gz")
    add_versions("0.3.8", "ed73bbecb2c1b523396ddbdbd8063f04a13e56b96e34515ef6af5826c84b4ef1")
    add_versions("0.3.9", "7a2f032f0f791dda6e75f2dc7b6cf347f62f27234fab58308124feff5f27be69")
    add_versions("0.4.0", "48c9b2a8c5697e0fde189706a6fa4b09b7b65762d88a495308e646eaf891f42a")
    add_versions("0.4.1", "038b39c4bdc04a792d62d163ba7908f4bb3373057208c07110be73c1b04b8334")
    add_versions("0.4.2", "dcecaaa535802fd57c84cceeff50c64efe7f2326bf752e16d2b77945649c8cd7")

    if is_plat("linux") then
        add_extsources("apt::libxcb-icccm4-dev", "pacman::xcb-util-wm")
    end

    if is_plat("macosx", "linux") then
        add_deps("m4", "pkg-config")
        add_deps("libxcb")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"), 
                         "--localstatedir=" .. package:installdir("var"), 
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_icccm_get_wm_name", {includes = "xcb/xcb_icccm.h"}))
    end)

