package("policycoreutils")
    set_kind("binary")
    set_homepage("https://github.com/SELinuxProject/selinux")
    set_description("SELinux policy core utilities.")

    add_urls("https://github.com/SELinuxProject/selinux/releases/download/$(version)/policycoreutils-$(version).tar.gz")
    add_versions("3.9", "44a294139876cf4c7969cb6a75d1932cb42543d74a7661760ded44a20bf7ebe8")

    add_deps("gettext")
    on_load(function (package)
        package:add("deps", "libsemanage >=" .. package:version_str())
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

        local links_missing_in_cascading = ""
        if package:dep("audit"):config("libcap_ng") then
            links_missing_in_cascading = links_missing_in_cascading .. " -lcap-ng"
        end
        if package:dep("libselinux"):config("pcre2") then
            links_missing_in_cascading = links_missing_in_cascading .. " -lpcre2-8"
        end
        for _, file in ipairs(os.files("**/Makefile")) do
            io.replace(file, "-laudit", "-laudit" .. links_missing_in_cascading, {plain = true})
            io.replace(file, "$(LIBSELINUX_LDLIBS)", "$(LIBSELINUX_LDLIBS) -lsepol" .. links_missing_in_cascading, {plain = true})
            io.replace(file, "$(LIBSEMANAGE_LDLIBS)", "$(LIBSEMANAGE_LDLIBS) -laudit -lbz2", {plain = true})
        end


        envs.CFLAGS = envs.CFLAGS .. " " .. table.concat(cflags, " ")
        envs.LDFLAGS = envs.LDFLAGS .. " " .. table.concat(ldflags, " ")

        make.build(package, configs, {envs = envs})

        table.insert(configs, "install")
        make.make(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(os.isexec(package:installdir("bin/sestatus")), "policycoreutils executable not found!")
    end)
