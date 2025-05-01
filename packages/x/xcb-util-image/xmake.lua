
package("xcb-util-image")
    set_homepage("https://xcb.freedesktop.org")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-util-image-$(version).tar.gz")
    add_versions("0.3.8", "3d7f6e3e7e73ca0d42154d360ad61a1e16fc62f6bb000f4e69c0d00305d1e00b")
    add_versions("0.3.9", "ac7fa09eddc9ecda6fd872d32b6dc23d451a1c6c201873dfe7cac8362c87acf3")
    add_versions("0.4.0", "cb2c86190cf6216260b7357a57d9100811bb6f78c24576a3a5bfef6ad3740a42")
    add_versions("0.4.1", "0ebd4cf809043fdeb4f980d58cdcf2b527035018924f8c14da76d1c81001293b")

    if is_plat("linux") then
        add_extsources("apt::libxcb-image0-dev", "pacman::xcb-util-image")
    end

    if is_plat("macosx", "linux") then
        add_deps("m4", "pkg-config")
        add_deps("xcb-proto", "libxcb", "xcb-util")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"), 
                         "--localstatedir=" .. package:installdir("var"), 
                         "--disable-silent-rules"}
        if package:config("shared") then
            table.insert(configs, "--disable-static")
        end
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_image_create", {includes = "xcb/xcb_image.h"}))
    end)

