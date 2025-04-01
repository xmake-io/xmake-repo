
package("xcb-util-renderutil")
    set_homepage("https://xcb.freedesktop.org")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-util-renderutil-$(version).tar.gz")
    add_versions("0.3.8", "cfa1130bfff8f281e10285ae063475dd172c78dad609ac10bce3924b5ca11484")
    add_versions("0.3.9", "55eee797e3214fe39d0f3f4d9448cc53cffe06706d108824ea37bb79fcedcad5")
    add_versions("0.3.10", "e04143c48e1644c5e074243fa293d88f99005b3c50d1d54358954404e635128a")

    if is_plat("linux") then
        add_extsources("apt::libxcb-render-util0-dev", "pacman::xcb-util-renderutil")
    end

    if is_plat("macosx", "linux") then
        add_deps("m4", "pkg-config")
        add_deps("libxcb", "xcb-util")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"), 
                         "--localstatedir=" .. package:installdir("var"), 
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_render_util_find_format", {includes = "xcb/xcb_renderutil.h"}))
    end)

