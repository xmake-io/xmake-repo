package("libxcomposite")
    set_homepage("https://www.x.org/")
    set_description("libXcomposite provides an X Window System client interface to the Composite extension to the X protocol.")

    set_urls("https://www.x.org/archive/individual/lib/libXcomposite-$(version).tar.gz")

    add_versions("0.4.6", "3599dfcd96cd48d45e6aeb08578aa27636fa903f480f880c863622c2b352d076")

    if is_plat("linux") then
        add_extsources("apt::libxcomposite-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxext", "libxfixes", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XCompositeRedirectWindow", {includes = "X11/extensions/Xcomposite.h"}))
    end)