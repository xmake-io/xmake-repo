package("libsemanage")
    set_homepage("https://github.com/SELinuxProject/selinux")
    set_description("SELinux binary policy manipulation library.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/SELinuxProject/selinux/releases/download/$(version)/libsemanage-$(version).tar.gz")
    add_versions("3.10", "1978894c414769ad77438d26886eaae3fb7bb74578ef2a5ad3130c89cb5cb1fe")
    add_versions("3.9", "ec05850aef48bfb8e02135a7f4f3f7edba3670f63d5e67f2708d4bd80b9a4634")

    add_configs("utils", {description = "Build utilities.", default = true, type = "boolean"})

    add_deps("flex", "bison", "bzip2", "audit")
    on_load(function (package)
        package:add("deps", "libselinux >=" .. package:version_str())
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

        if not package:config("utils") then
            io.replace("Makefile", "$(MAKE) -C utils install", "", {plain = true})
        end

        io.replace("Makefile", "$(MAKE) -C man install", "", {plain = true})

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

        local links_missing_in_cascading = ""
        if package:dep("audit"):config("libcap_ng") then
            links_missing_in_cascading = links_missing_in_cascading .. " -lcap-ng"
        end
        if package:dep("libselinux"):config("pcre2") then
            links_missing_in_cascading = links_missing_in_cascading .. " -lpcre2-8"
        end
        io.replace("src/Makefile", "-lselinux", "-lselinux" .. links_missing_in_cascading, {plain = true})

        envs.CFLAGS = envs.CFLAGS .. " " .. table.concat(cflags, " ")
        envs.LDFLAGS = envs.LDFLAGS .. " " .. table.concat(ldflags, " ")

        make.build(package, configs, {envs = envs})

        table.insert(configs, "install")
        make.make(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("semanage_module_install", {includes = {"semanage/modules.h"}}))
    end)
