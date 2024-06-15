rule("lexer")
    set_extensions(".g4")

    add_deps("@find_antlr4")

    before_buildcmd_file(function (target, batchcmds, sourcefile_g4, opt)
        local java = target:data("antlr4.tool")
        local argv = target:data("antlr4.tool.argv")
        table.join2(argv, target:values("antlr4.lexer.flags"))

        local autogendir = path.join(target:autogendir(), "rules", "antlr4", "lexer")
        local sourcefile_cxx = path.join(autogendir, path.directory(sourcefile_g4), path.basename(sourcefile_g4) .. ".cpp")
        local sourcefile_dir = path.directory(sourcefile_cxx)

        batchcmds:mkdir(sourcefile_dir)
        table.insert(argv, "-o")
        table.insert(argv, autogendir)
        table.insert(argv, "-lib")
        table.insert(argv, sourcefile_dir)

        target:add("includedirs", sourcefile_dir, {public = true})

        table.insert(argv, sourcefile_g4)
        batchcmds:vrunv(java.program, argv)
        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.g4 %s", sourcefile_g4)

        local objectfile = target:objectfile(sourcefile_cxx)
        table.insert(target:objectfiles(), objectfile)
        batchcmds:compile(sourcefile_cxx, objectfile)

        batchcmds:add_depfiles(sourcefile_g4)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)
