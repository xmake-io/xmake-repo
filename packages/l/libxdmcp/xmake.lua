package("libxdmcp")
    set_homepage("https://www.x.org/")
    set_description("X.Org: X Display Manager Control Protocol library")

    add_urls("https://www.x.org/archive/individual/lib/libXdmcp-$(version).tar.gz", {alias = "xorg"})
    add_urls("https://www.rro.rs/gentoo-distfiles/distfiles/25/libXdmcp-$(version).tar.xz", {alias = "mirror"})

    add_versions("xorg:1.1.3", "2ef9653d32e09d1bf1b837d0e0311024979653fe755ad3aaada8db1aa6ea180c")
    add_versions("xorg:1.1.4", "55041a8ff8992ab02777478c4b19c249c0f8399f05a752cb4a1a868a9a0ccb9a")
    add_versions("xorg:1.1.5", "31a7abc4f129dcf6f27ae912c3eedcb94d25ad2e8f317f69df6eda0bc4e4f2f3")
    add_versions("mirror:1.1.5", "d8a5222828c3adab70adf69a5583f1d32eb5ece04304f7f8392b6a353aa2228c")

    if is_plat("linux") then
        add_extsources("apt::libxdmcp-dev", "pacman::libxmdcp")
    end

    on_load("macosx", "linux", "bsd", "cross", function (package)
        package:add("deps", "pkg-config", "xorgproto")
    end)

    on_install("macosx", "linux", "bsd", "cross", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-docs=no"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("xdmOpCode", {includes = "X11/Xdmcp.h"}))
    end)
