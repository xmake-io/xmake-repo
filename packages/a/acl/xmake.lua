package("acl")

    set_homepage("http://savannah.nongnu.org/projects/acl/")
    set_description("Commands for Manipulating POSIX Access Control Lists")
    set_license("GPL-2.0")

    add_urls("http://download.savannah.nongnu.org/releases/acl/acl-$(version).tar.gz")
    add_versions("2.3.2", "5f2bdbad629707aa7d85c623f994aa8a1d2dec55a73de5205bac0bf6058a2f7c")
    add_versions("2.3.1", "760c61c68901b37fdd5eefeeaf4c0c7a26bdfdd8ac747a1edff1ce0e243c11af")

    add_deps("pkgconf", "attr")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local cflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(ldflags, "-l" .. link)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("acl_check", {includes = "acl/libacl.h"}))
    end)
