package("libxcursor")
    set_homepage("https://www.x.org/")
    set_description("X.Org: X Window System Cursor management library")

    set_urls("https://www.x.org/archive/individual/lib/libXcursor-$(version).tar.gz")
    add_versions("1.2.1", "77f96b9ad0a3c422cfa826afabaf1e02b9bfbfc8908c5fa1a45094faad074b98")
    add_versions("1.2.3", "74e72da27e61cc2cfd2e267c14f500ea47775850048ee0b00362a55c9b60ee9b")

    if is_plat("linux") then
        add_extsources("apt::libxcursor-dev")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "util-macros")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxfixes", "libxrender", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", "bsd", "cross", function (package)
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
