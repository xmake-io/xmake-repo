
package("xcb-util")
    set_homepage("https://xcb.freedesktop.org")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-util-$(version).tar.gz")
    add_versions("0.3.6", "ebb4064db813bfbfedfa30086483e73404f5358fab38698e584c195dc74bd609")
    add_versions("0.3.8", "e9e7f68d60ddd1bab6da714399dd1d91c78cb900c88427d3b8436a013178b3be")
    add_versions("0.3.9", "c3f9e8921998d92b3709baeb6c0b78179d0d8b6f592efdb11120584c5dfedc7e")
    add_versions("0.4.0", "0ed0934e2ef4ddff53fcc70fc64fb16fe766cd41ee00330312e20a985fd927a7")

    if is_plat("linux") then
        add_extsources("apt::libxcb-util-dev", "pacman::xcb-util")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config")
        add_deps("libxcb")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"), 
                         "--localstatedir=" .. package:installdir("var"), 
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_atom_name_by_screen", {includes = "xcb/xcb_atom.h"}))
    end)

