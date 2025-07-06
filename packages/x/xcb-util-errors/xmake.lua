
package("xcb-util-errors")
    set_homepage("https://xcb.freedesktop.org")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-util-errors-$(version).tar.gz")
    add_versions("1.0", "7752a722e580efdbada30632cb23aed35c18757399ac3b547b59fd7257cf5e33")
    add_versions("1.0.1", "cfbd3b022bdb27a6921a4abd6b41f4071b4e4960447598abd30955d3454f4d99")

    if is_plat("linux") then
        add_extsources("pacman::xcb-util-errors")
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
        assert(package:has_cfuncs("xcb_errors_context_new", {includes = "xcb/xcb_errors.h"}))
    end)

