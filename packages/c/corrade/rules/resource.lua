-- Compile corrade resource files. Substitution for cmake corrade_add_resource.
--
-- Usage:
--
-- add_rules("@corrade/resource")
-- add_files("resources.conf", {rule = "@corrade/resource", single = false})

rule("resource")
    set_extensions(".conf")
    on_buildcmd_file(function (target, batchcmds, sourcefile, opt)
        import("core.base.option")
        import("lib.detect.find_program")

        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.corrade %s", sourcefile)

        -- get corrade-rc program
        local corrade = find_program("corrade-rc", {check = "-h"})
        assert(corrade, "corrade-rc not found! please check your corrade installation.")

        -- generate source file
        local basename = path.basename(sourcefile)
        local sourcefile_cx = path.join(target:autogendir(), "rules", "autogen", basename .. ".cpp")
        local objectfile = target:objectfile(sourcefile_cx)
        table.insert(target:objectfiles(), objectfile)

        -- compile
        batchcmds:mkdir(path.directory(sourcefile_cx))
        local args = {}
        local fileconf = target:fileconfig(sourcefile)
        if fileconf and fileconf.single then
            table.insert(args, "--single")
        end
        if fileconf and fileconf.name then
            table.insert(args, fileconf.name)
        else
            table.insert(args, basename)
        end
        local workdir = path.directory(sourcefile)
        table.insert(args, path.filename(sourcefile))
        table.insert(args, path.relative(sourcefile_cx, workdir))
        if option.get("verbose") then
            batchcmds:show(corrade .. " " ..  os.args(args))
        end
        local currentdir = os.curdir()
        batchcmds:cd(workdir)
        batchcmds:vrunv(corrade, args)
        batchcmds:cd(currentdir)
        batchcmds:compile(sourcefile_cx, objectfile)

        -- add dependency
        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)
