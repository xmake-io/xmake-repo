rule("xp")
    on_config(function (target)
        local objectfile = "YY_Thunks_for_WinXP.obj"
        local thunks = target:pkg("yy-thunks")
        if thunks then
            local installdir = thunks:installdir()
            table.insert(target:objectfiles(), path.join(installdir, "lib", objectfile))
        end
    end)

rule("vista")
    on_config(function (target)
        local objectfile = "YY_Thunks_for_Vista.obj"
        local thunks = target:pkg("yy-thunks")
        if thunks then
            local installdir = thunks:installdir()
            table.insert(target:objectfiles(), path.join(installdir, "lib", objectfile))
        end
    end)

rule("2k")
    on_config(function (target)
        if not target:is_arch("x86") then
            raise("Win2K only supports x86 architecture")
        end

        local thunks = target:pkg("yy-thunks")
        if thunks then
            local installdir = thunks:installdir()
            table.insert(target:objectfiles(), path.join(installdir, "lib", objectfile))
        end
    end)
