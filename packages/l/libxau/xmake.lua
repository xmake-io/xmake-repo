package("libxau")

    set_homepage("https://www.x.org/")
    set_description("X.Org: A Sample Authorization Protocol for X")

    set_urls("https://www.x.org/archive/individual/lib/libXau-$(version).tar.gz")
    add_versions("1.0.10", "51a54da42475d4572a0b59979ec107c27dacf6c687c2b7b04e5cf989a7c7e60c")
    add_versions("1.0.11", "3a321aaceb803577a4776a5efe78836eb095a9e44bbc7a465d29463e1a14f189")
    add_versions("1.0.12", "2402dd938da4d0a332349ab3d3586606175e19cb32cb9fe013c19f1dc922dcee")

    if is_plat("linux") then
        add_extsources("apt::libxau-dev", "pacman::libxau")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "util-macros", "xorgproto")
    end

    on_install("macosx", "linux", "bsd", "cross", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--disable-specs"}
        if package:config("shared") then
            table.insert(configs, "--disable-static")
        end
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("Xauth", {includes = "X11/Xauth.h"}))
    end)
