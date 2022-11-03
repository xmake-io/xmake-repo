package("libxau")

    set_homepage("https://www.x.org/")
    set_description("X.Org: A Sample Authorization Protocol for X")

    set_urls("https://www.x.org/archive/individual/lib/libXau-$(version).tar.gz")
    add_versions("1.0.10", "51a54da42475d4572a0b59979ec107c27dacf6c687c2b7b04e5cf989a7c7e60c")

    if is_plat("linux") then
        add_extsources("apt::libxau-dev", "pacman::libxau")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "xorgproto")
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
        assert(package:has_ctypes("Xauth", {includes = "X11/Xauth.h"}))
    end)
