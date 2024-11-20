rule("parser")
    set_extensions(".g4")

    add_deps("@lexer", {order = true})

    on_config(function (target)
        -- remove lexer g4
        for _, sourcebatch in pairs(target:sourcebatches()) do
            if sourcebatch.rulename == "@antlr4/parser" then
                local sourcefiles = {}
                for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
                    if not sourcefile:lower():find("lexer") then
                        table.insert(sourcefiles, sourcefile)
                    end
                end
                sourcebatch.sourcefiles = sourcefiles
                break
            end
        end
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
        local sourcefile_cxx = path.join(autogendir, path.directory(sourcefile_g4), path.basename(sourcefile_g4) .. ".cpp")
        local sourcefile_dir = path.directory(sourcefile_cxx)

        batchcmds:mkdir(sourcefile_dir)
        table.insert(argv, "-o")
        table.insert(argv, autogendir)
        table.insert(argv, "-lib")
        table.insert(argv, sourcefile_dir)

        target:add("includedirs", sourcefile_dir, {public = true})

        table.insert(argv, sourcefile_g4)
        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.g4 %s", sourcefile_g4)
        batchcmds:vrunv(java.program, argv)

        local sourcefiles_cxx = {sourcefile_cxx}

        local sourcefile_file_dir = path.join(autogendir, path.directory(sourcefile_g4))
        if visitor then
            table.insert(sourcefiles_cxx, path.join(sourcefile_file_dir, path.basename(sourcefile_g4) .. "Visitor.cpp"))
            table.insert(sourcefiles_cxx, path.join(sourcefile_file_dir, path.basename(sourcefile_g4) .. "BaseVisitor.cpp"))
        end
        if listener then
            table.insert(sourcefiles_cxx, path.join(sourcefile_file_dir, path.basename(sourcefile_g4) .. "Listener.cpp"))
            table.insert(sourcefiles_cxx, path.join(sourcefile_file_dir, path.basename(sourcefile_g4) .. "BaseListener.cpp"))
        end

        for _, cxx in ipairs(sourcefiles_cxx) do
            local objectfile = target:objectfile(cxx)
            table.insert(target:objectfiles(), objectfile)
            batchcmds:show_progress(opt.progress, "${color.build.object}compiling.$(mode) %s", cxx)
            batchcmds:compile(cxx, objectfile)

            if cxx == sourcefile_cxx then
                batchcmds:set_depmtime(os.mtime(objectfile))
                batchcmds:set_depcache(target:dependfile(objectfile))
            end
        end

        batchcmds:add_depfiles(sourcefile_g4)
    end)
