package("checkpolicy")
    set_kind("binary")
    set_homepage("https://github.com/SELinuxProject/selinux")
    set_description("SELinux policy compiler.")
    set_license("GPL-2.0")

    add_urls("https://github.com/SELinuxProject/selinux/releases/download/$(version)/checkpolicy-$(version).tar.gz")
    add_versions("3.9", "dd85b0173ca6e96b22ebf472bcbccf04eb10e1aa07add8f1b7e0e9e8e995e027")

    add_deps("flex", "bison")
    on_load(function (package)
        package:add("deps", "libsepol >=" .. package:version_str())
        package:add("deps", "libselinux >=" .. package:version_str())
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

        make.build(package, configs, {envs = envs})

        table.insert(configs, "install")
        make.make(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(os.isexec(package:installdir("bin/checkpolicy")), "checkpolicy executable not found!")
    end)
