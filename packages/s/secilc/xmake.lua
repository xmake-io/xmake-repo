package("secilc")
    set_kind("binary")
    set_homepage("https://github.com/SELinuxProject/selinux")
    set_description("SELinux Common Intermediate Language Compiler")

    add_urls("https://github.com/SELinuxProject/selinux/releases/download/$(version)/secilc-$(version).tar.gz")
    add_versions("3.10", "6658071d6f1044184d3973062a798187537ae1c3ddb4c31afd417df333316c10")
    add_versions("3.9", "c53fb7218ac158c05f28de186e48404857eb191bd4f9415802f85449fdf6da7f")

    on_load(function (package)
        package:add("deps", "libsepol >=" .. package:version_str())
    end)

    on_install("linux", function (package)
        import("package.tools.make")

        local configs = {"PREFIX="}
        table.insert(configs, "DEBUG=" .. (package:is_debug() and "1" or "0"))
        table.insert(configs, "DESTDIR=" .. package:installdir())

        local envs = make.buildenvs(package)
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
            end
        end

        envs.CFLAGS = envs.CFLAGS .. " " .. table.concat(cflags, " ")
        envs.LDFLAGS = envs.LDFLAGS .. " " .. table.concat(ldflags, " ")

        io.replace("Makefile", "$(SECIL2TREE) man", "$(SECIL2TREE)", {plain = true})
        io.replace("Makefile", "install: all man", "install: all", {plain = true})
        io.replace("Makefile", "-mkdir -p $(DESTDIR)$(MANDIR)/man8", "", {plain = true})
        io.replace("Makefile", [[	install -m 644 $(SECILC_MANPAGE) $(DESTDIR)$(MANDIR)/man8
	install -m 644 $(SECIL2CONF_MANPAGE) $(DESTDIR)$(MANDIR)/man8
	install -m 644 $(SECIL2TREE_MANPAGE) $(DESTDIR)$(MANDIR)/man8]], "", {plain = true})

        make.build(package, configs, {envs = envs})

        table.insert(configs, "install")
        make.make(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(os.isexec(package:installdir("bin/secilc")), "secilc executable not found!")
    end)
