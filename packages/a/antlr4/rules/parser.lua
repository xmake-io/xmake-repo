rule("parser")
    set_extensions(".g4")

    add_deps("@lexer", {order = true})

    on_config(function (target)
        local includedirs = {}
        local autogendir = path.join(target:autogendir(), "rules/antlr4/parser")
        for _, sourcebatch in pairs(target:sourcebatches()) do
            if sourcebatch.rulename == "@antlr4/parser" then
                local sourcefiles = {}
                for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
                    -- remove lexer g4
                    if not sourcefile:lower():find("lexer", 1, true) then
                        table.insert(sourcefiles, sourcefile)
                        table.insert(includedirs, path.normalize(path.join(autogendir, path.directory(sourcefile))))
                    end
                end
                sourcebatch.sourcefiles = sourcefiles
                break
            end
        end
        target:add("includedirs", table.unique(includedirs), {public = true})
    end)

    before_buildcmd_file(function (target, batchcmds, sourcefile_g4, opt)
        local java = target:data("antlr4.tool")
        local argv = target:data("antlr4.tool.argv")

        local visitor = target:extraconf("rules", "@antlr4/parser", "visitor")
        local listener = target:extraconf("rules", "@antlr4/parser", "listener")
        
        table.insert(argv, (visitor and "-visitor" or "-no-visitor"))
        table.insert(argv, (listener and "-listener" or "-no-listener"))

        table.join2(argv, target:values("antlr4.parser.flags"))

        local autogendir = path.join(target:autogendir(), "rules/antlr4/parser")
        local sourcefile_cxx = path.normalize(path.join(autogendir, path.directory(sourcefile_g4), path.basename(sourcefile_g4) .. ".cpp"))
        local sourcefile_dir = path.directory(sourcefile_cxx)

        batchcmds:mkdir(sourcefile_dir)
        table.insert(argv, "-o")
        table.insert(argv, autogendir)
        table.insert(argv, "-lib")
        table.insert(argv, sourcefile_dir)

        table.insert(argv, sourcefile_g4)
        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.g4 %s", sourcefile_g4)
        batchcmds:vrunv(java.program, argv)

        local objectfile = target:objectfile(sourcefile_cxx)
        table.insert(target:objectfiles(), objectfile)
        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.$(mode) %s", sourcefile_cxx)
        batchcmds:compile(sourcefile_cxx, objectfile)

        batchcmds:add_depfiles(sourcefile_g4)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)
