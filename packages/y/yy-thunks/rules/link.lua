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

        local objectfile = "YY_Thunks_for_Win2K.obj"
        local thunks = target:pkg("yy-thunks")
        if thunks then
            local installdir = thunks:installdir()
            table.insert(target:objectfiles(), path.join(installdir, "lib", objectfile))
        end
    end)

    after_link(function (target, opt)
        import("core.project.depend")
        import("lib.detect.find_tool")
        import("utils.progress")

        depend.on_changed(function()
            local msvc = target:toolchain("msvc")
            local editbin = assert(find_tool("editbin", {envs = msvc:runenvs()}), "editbin not found!")

            -- osversion -> Major/Minor OperatingSystemVersion
            -- subsystem -> Major/Minor SubsystemVersion
            os.iorunv(editbin.program, {"/osversion:5.0", "/subsystem:console,5.0", target:targetfile()})
            progress.show(opt.progress, "${color.build.target}editing.$(mode) %s", target:filename())
        end, {files = {target:targetfile()}})
    end)
