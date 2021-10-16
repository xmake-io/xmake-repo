package("libspectre")

    set_homepage("https://www.freedesktop.org/wiki/Software/libspectre/")
    set_description("libspectre is a small library for rendering Postscript documents.")
    set_license("GPL-2.0")

    add_urls("http://libspectre.freedesktop.org/releases/libspectre-$(version).tar.gz")
    add_versions("0.2.9", "49ae9c52b5af81b405455c19fe24089d701761da2c45d22164a99576ceedfbed")

    add_deps("ghostscript")
    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:is_plat("macosx") then
            -- patch configure to make ci happy
            io.replace("configure", "have_libgs=no", "have_libgs=yes", {plain = true})
        end
        local cppflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cppflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cppflags = cppflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("spectre_document_get_format", {includes = "libspectre/spectre.h"}))
    end)
