package("libxext")
    set_homepage("https://www.x.org/")
    set_description("X.Org: Library for common extensions to the X11 protocol")
    set_license("X11")

    set_urls("https://www.x.org/archive/individual/lib/libXext-$(version).tar.gz")
    add_versions("1.3.5", "1a3dcda154f803be0285b46c9338515804b874b5ccc7a2b769ab7fd76f1035bd")
    add_versions("1.3.6", "1a0ac5cd792a55d5d465ced8dbf403ed016c8e6d14380c0ea3646c4415496e3d")
    add_versions("1.3.7", "6564608dc3b816b0cfddf0c7ddc62bc579055dd70b2f28113a618df2acb64189")

    if is_plat("linux") then
        add_extsources("apt::libxext-dev")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", "bsd", "cross", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-specs=no"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        if package:is_cross() then
            table.insert(configs, "--disable-malloc0returnsnull")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XShapeEvent", {includes = "X11/extensions/shape.h"}))
    end)
