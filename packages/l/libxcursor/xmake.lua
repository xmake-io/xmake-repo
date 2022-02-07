package("libxcursor")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X Window System Cursor management library")

    set_urls("https://www.x.org/archive/individual/lib/libXcursor-$(version).tar.bz2")
    add_versions("1.2.0", "3ad3e9f8251094af6fe8cb4afcf63e28df504d46bfa5a5529db74a505d628782")

    if is_plat("linux") then
        add_extsources("apt::libxcursor-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "libx11", "libxfixes", "libxrender")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XcursorFileHeader", {includes = "X11/Xcursor/Xcursor.h"}))
    end)
