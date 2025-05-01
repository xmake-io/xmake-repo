
package("xcb-util-cursor")
    set_homepage("https://xcb.freedesktop.org")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-util-cursor-$(version).tar.gz")
    add_versions("0.1.0", "fe856df5cfd37ac1a574293790fb93b1414f0d06e3bd3b087ad7da6bba685e11")
    add_versions("0.1.1", "3f89a77e1a7bd29bd82b935225f640dee02daf46cb0394bfafb180412b5b7252")
    add_versions("0.1.2", "b9e55161eb283ce14b5f73d09aba58c7ccadebc010984db659ae2d95d2ada02e")
    add_versions("0.1.3", "a322332716a384c94d3cbf98f2d8fe2ce63c2fe7e2b26664b6cea1d411723df8")
    add_versions("0.1.4", "cc8608ebb695742b6cf84712be29b2b66aa5f6768039528794fca0fa283022bf")
    add_versions("0.1.5", "0e9c5446dc6f3beb8af6ebfcc9e27bcc6da6fe2860f7fc07b99144dfa568e93b")

    if is_plat("linux") then
        add_extsources("apt::libxcb-cursor-dev", "pacman::xcb-util-cursor")
    end

    if is_plat("macosx", "linux") then
        add_deps("m4", "pkg-config")
        add_deps("libxcb", "xcb-util-renderutil", "xcb-util-image")
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
        assert(package:has_cfuncs("xcb_cursor_context_new", {includes = "xcb/xcb_cursor.h"}))
    end)

