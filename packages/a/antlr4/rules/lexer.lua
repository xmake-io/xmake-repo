rule("lexer")
    set_extensions(".g4")

    add_deps("@find_antlr4")

    on_config(function (target)
        local includedirs = {}
        local autogendir = path.join(target:autogendir(), "rules/antlr4/lexer")
        for _, sourcebatch in pairs(target:sourcebatches()) do
            if sourcebatch.rulename == "@antlr4/lexer" then
                local sourcefiles = {}
                for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
                    -- remove parser g4
                    if not sourcefile:lower():find("parser", 1, true) then
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
        table.join2(argv, target:values("antlr4.lexer.flags"))

        local autogendir = path.join(target:autogendir(), "rules/antlr4/lexer")
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
