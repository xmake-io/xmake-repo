rule("xp")
    on_config(function (target)
        import("core.project.project")

        local objectfile = "YY_Thunks_for_WinXP.obj"
        local installdir = project.required_package("yy-thunks"):installdir()
        table.insert(target:objectfiles(), path.join(installdir, "lib", objectfile))
    end)

rule("vista")
    on_config(function (target)
        import("core.project.project")

        local objectfile = "YY_Thunks_for_Vista.obj"
        local installdir = project.required_package("yy-thunks"):installdir()
        table.insert(target:objectfiles(), path.join(installdir, "lib", objectfile))
    end)

rule("2k")
    on_config(function (target)
        import("core.project.project")

        if not target:is_arch("x86") then
            raise("Win2K only supports x86 architecture")
        end

        local objectfile = "YY_Thunks_for_Win2K.obj"
        local installdir = project.required_package("yy-thunks"):installdir()
        table.insert(target:objectfiles(), path.join(installdir, "lib", objectfile))
    end)
