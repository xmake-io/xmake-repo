rule("parser")
    set_extensions(".g4")

    add_deps("@lexer", {order = true})

    on_config(function (target)
        local visitor = target:extraconf("rules", "@antlr4/parser", "visitor")
        local listener = target:extraconf("rules", "@antlr4/parser", "listener")
        -- add flags
        target:add("values", "antlr4.parser.flags", (visitor and "-visitor" or "-no-visitor"))
        target:add("values", "antlr4.parser.flags", (listener and "-listener" or "-no-listener"))
        -- add files
        if visitor or listener then
            local sourcefiles = {}
            for _, sourcebatch in pairs(target:sourcebatches()) do
                if sourcebatch.rulename == "@antlr4/parser" then
                    table.join2(sourcefiles, sourcebatch.sourcefiles)
                end
            end

            if #sourcefiles ~= 0 then
                local autogendir = path.join(target:autogendir(), "rules", "antlr4", "parser")
                if visitor then
                    for _, sourcefile in pairs(sourcefiles) do
                        local sourcefile_file_dir = path.join(autogendir, path.directory(sourcefile))
                        target:add("files", path.join(sourcefile_file_dir, path.basename(sourcefile) .. "Visitor.cpp"), {always_added = true})
                        target:add("files", path.join(sourcefile_file_dir, path.basename(sourcefile) .. "BaseVisitor.cpp"), {always_added = true})
                    end
                end

                if listener then
                    for _, sourcefile in pairs(sourcefiles) do
                        local sourcefile_file_dir = path.join(autogendir, path.directory(sourcefile))
                        target:add("files", path.join(sourcefile_file_dir, path.basename(sourcefile) .. "Listener.cpp"), {always_added = true})
                        target:add("files", path.join(sourcefile_file_dir, path.basename(sourcefile) .. "BaseListener.cpp"), {always_added = true})
                    end
                end
            end
        end
    end)

    before_buildcmd_file(function (target, batchcmds, sourcefile_g4, opt)
        local java = target:data("antlr4.tool")
        local argv = target:data("antlr4.tool.argv")
        table.join2(argv, target:values("antlr4.parser.flags"))

        local autogendir = path.join(target:autogendir(), "rules", "antlr4", "parser")
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
