package("libsepol")
    set_homepage("https://github.com/SELinuxProject/selinux")
    set_description("SELinux binary policy manipulation library.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/SELinuxProject/selinux/releases/download/$(version)/libsepol-$(version).tar.gz")
    add_versions("3.9", "ba630b59e50c5fbf9e9dd45eb3734f373cf78d689d8c10c537114c9bd769fa2e")

    add_configs("cil",   {description = "Build with CIL support.", default = true, type = "boolean"})
    add_configs("utils", {description = "Build utilities.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("cil") then
            package:add("deps", "flex")
        end
    end)

    on_install("linux", function (package)
        import("package.tools.make")

        local configs = {"PREFIX="}
        table.insert(configs, "DEBUG=" .. (package:is_debug() and "1" or "0"))
        table.insert(configs, "DESTDIR=" .. package:installdir())

        table.insert(configs, "DISABLE_SHARED=" .. (package:config("shared") and "n" or "y"))
        if package:config("shared") then
            io.replace("src/Makefile", "all: $(LIBA)", "all:", {plain = true})
            io.replace("src/Makefile", "install -m 644 $(LIBA) $(DESTDIR)$(LIBDIR)", "", {plain = true})
        end

        table.insert(configs, "DISABLE_CIL=" .. (package:config("cil") and "n" or "y"))
        if not package:config("utils") then
            io.replace("Makefile", "$(MAKE) -C utils install", "", {plain = true})
            io.replace("Makefile", "$(MAKE) -C utils", "", {plain = true})
        end

        io.replace("Makefile", "$(MAKE) -C man install", "", {plain = true})

        -- fix pkg-config
        io.replace("src/Makefile", "s:@prefix@:$(PREFIX):; s:@libdir@:$(LIBDIR):; s:@includedir@:$(INCLUDEDIR):", "s:@prefix@:$(DESTDIR):; s:@libdir@:$(DESTDIR)$(LIBDIR):; s:@includedir@:$(DESTDIR)$(INCLUDEDIR):", {plain = true})

        local envs = make.buildenvs(package)
        local cflags = {}
        if package:config("pic") then
            table.insert(cflags, "-fPIC")
        end
        envs.CFLAGS = envs.CFLAGS .. " " .. table.concat(cflags, " ")

        make.build(package, configs, {envs = envs})

        table.insert(configs, "install")
        make.make(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sepol_set_policydb_from_file", {includes = {"sepol/sepol.h"}}))
    end)
