package("libselinux")
    set_homepage("https://github.com/SELinuxProject/selinux")
    set_description("SELinux library and simple utilities.")

    add_urls("https://github.com/SELinuxProject/selinux/releases/download/$(version)/libselinux-$(version).tar.gz")
    add_versions("3.9", "e7ee2c01dba64a0c35c9d7c9c0e06209d8186b325b0638a0d83f915cc3c101e8")

    add_configs("utils", {description = "Build utilities.", default = true, type = "boolean"})

    add_configs("setrans", {description = "Enable selinux translation daemon support.", default = true, type = "boolean"})
    add_configs("rpm",     {description = "Enable rpm_execcon support.", default = true, type = "boolean"})
    add_configs("bool",    {description = "Enable selinux boolean support.", default = true, type = "boolean"})
    add_configs("x11",     {description = "Enable X11 media context support.", default = true, type = "boolean"})

    add_configs("pcre2", {description = "Enable use of pcre2.", default = true, type = "boolean"})
    add_configs("lfs",   {description = "Enable large file support.", default = true, type = "boolean"})

    on_load(function (package)
        package:add("deps", "libsepol >=" .. package:version_str())
        if package:config("pcre2") then
            package:add("deps", "pcre2")
        end
    end)

    on_install("linux", function (package)
        import("package.tools.make")

        local configs = {"PREFIX="}

        table.insert(configs, "DEBUG=" .. (package:is_debug() and "1" or "0"))
        table.insert(configs, "DESTDIR=" .. package:installdir())

        table.insert(configs, "DISABLE_SETRANS=" .. (package:config("setrans") and "n" or "y"))
        table.insert(configs, "DISABLE_RPM=" .. (package:config("rpm") and "n" or "y"))
        table.insert(configs, "DISABLE_BOOL=" .. (package:config("bool") and "n" or "y"))
        table.insert(configs, "DISABLE_X11=" .. (package:config("x11") and "n" or "y"))

        table.insert(configs, "USE_PCRE2=" .. (package:config("pcre2") and "y" or "n"))
        table.insert(configs, "USE_LFS=" .. (package:config("lfs") and "y" or "n"))

        local subdirs = {"include", "src"}
        if package:config("utils") then
            table.insert(subdirs, "utils")
        end

        table.insert(configs, "DISABLE_SHARED=" .. (package:config("shared") and "n" or "y"))
        if package:config("shared") then
            -- io.replace("src/Makefile", "all: $(LIBA)", "all:", {plain = true})
            io.replace("src/Makefile", "install -m 644 $(LIBA) $(DESTDIR)$(LIBDIR)", "", {plain = true})
        end

        -- fix pkg-config
        io.replace("src/Makefile", "s:@prefix@:$(PREFIX):; s:@libdir@:$(LIBDIR):; s:@includedir@:$(INCLUDEDIR):", "s:@prefix@:$(DESTDIR):; s:@libdir@:$(DESTDIR)$(LIBDIR):; s:@includedir@:$(DESTDIR)$(INCLUDEDIR):", {plain = true})

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

        if package:config("pic") then
            table.insert(cflags, "-fPIC")
        end

        envs.CFLAGS = envs.CFLAGS .. " " .. table.concat(cflags, " ")
        envs.LDFLAGS = envs.LDFLAGS .. " " .. table.concat(ldflags, " ")

        table.insert(configs, "SUBDIRS=" .. table.concat(subdirs, " "))
        make.build(package, configs, {envs = envs})

        table.insert(configs, "install")
        make.make(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("is_selinux_enabled", {includes = {"selinux/selinux.h"}}))
    end)
