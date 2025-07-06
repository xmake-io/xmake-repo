package("libsm")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libsm")
    set_description("X.Org: X Session Management Library")

    add_urls("https://www.x.org/archive/individual/lib/libSM-$(version).tar.gz")
    add_versions("1.2.3", "1e92408417cb6c6c477a8a6104291001a40b3bb56a4a60608fdd9cd2c5a0f320")
    add_versions("1.2.6", "166b4b50d606cdd83f1ddc61b5b9162600034f848b3e32ccbb0e63536b7d6cdd")

    if is_plat("linux") then
        add_extsources("apt::libsm-dev", "pacman::libsm")
    end

    add_deps("libice", "xtrans")

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-docs=no",
                         "--enable-specs=no"}
        -- fix missing xtrans includedir on some linux platforms
        local cflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SmcOpenConnection", {includes = "X11/SM/SMlib.h"}))
    end)
