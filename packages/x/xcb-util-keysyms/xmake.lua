
package("xcb-util-keysyms")
    set_homepage("https://xcb.freedesktop.org")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-util-keysyms-$(version).tar.gz")
    add_versions("0.3.8", "99fcf9273f9866c1682bcf8a51df41296fe239e0f1df14f55350a33fd0e948b0")
    add_versions("0.3.9", "9fda86f6a26be8872f33c10f47505c40c9305758d320b170aa976b7201533a42")
    add_versions("0.4.0", "0807cf078fbe38489a41d755095c58239e1b67299f14460dec2ec811e96caa96")
    add_versions("0.4.1", "1fa21c0cea3060caee7612b6577c1730da470b88cbdf846fa4e3e0ff78948e54")

    if is_plat("linux") then
        add_extsources("apt::libxcb-keysyms1-dev", "pacman::xcb-util-keysyms")
    end

    if is_plat("macosx", "linux") then
        add_deps("m4", "pkg-config")
        add_deps("xcb-proto", "libxcb")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"), 
                         "--localstatedir=" .. package:installdir("var"), 
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_key_symbols_get_keycode", {includes = "xcb/xcb_keysyms.h"}))
    end)

