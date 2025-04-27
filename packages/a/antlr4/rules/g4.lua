-- Usage
--[[
    add_requires("antlr4", "antlr4-runtime")

    set_languages("c++17")
    set_exceptions("cxx")

    target("test")
        set_kind("object")
        add_files("src/*.g4")
        add_rules("@antlr4/g4")
        add_packages("antlr4", "antlr4-runtime")
--]]

rule("g4")
    set_extensions(".g4")

    add_deps("@find_antlr4")

    before_build_files(function (target, jobgraph, sourcebatch, opt)
        import("core.project.depend")
        import("utils.progress")

        local g4_job = target:fullname() .. "/generate/g4"
        local autogendir = path.join(target:autogendir(), "rules/antlr4")
        jobgraph:group(g4_job, function()
            for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
                local jave_job = target:fullname() .. "/generate/" .. sourcefile
                local sourcefile_dir = path.normalize(path.join(autogendir, path.directory(sourcefile)))
                target:add("includedirs", sourcefile_dir, {public = true})
                os.mkdir(sourcefile_dir)
                jobgraph:add(jave_job, function (index, total, opt)
                    local java = target:data("antlr4.tool")
                    local argv = target:data("antlr4.tool.argv")
                    table.join2(argv, target:values("antlr4.flags"))
                    table.insert(argv, "-o")
                    table.insert(argv, autogendir)
                    table.insert(argv, "-lib")
                    table.insert(argv, sourcefile_dir)
                    table.insert(argv, sourcefile)

                    depend.on_changed(function()
                        progress.show(opt.progress or 0, "${color.build.object}compiling.g4 %s", sourcefile)
                        os.vrunv(java.program, argv)
                    end, {
                        files = sourcefile,
                        dependfile = target:dependfile(sourcefile),
                        changed = target:is_rebuilt()
                    })
                end)
            end
        end)
    end, {jobgraph = true, batch = true})

    on_build_files(function (target, jobgraph, sourcebatch, opt)
        import("private.action.build.object", {alias = "build_objectfiles"})

        local build_g4 = target:fullname() .. "/obj/g4"
        jobgraph:group(build_g4, function()
            for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
                local cxx_job = target:fullname() .. "/obj/" .. sourcefile
                local sourcefile_dir = path.normalize(path.join(target:autogendir(), "rules/antlr4", path.directory(sourcefile)))
                jobgraph:add(cxx_job, function (index, total, opt)
                    local batchcxx = {
                        rulename = "c++.build",
                        sourcekind = "cxx",
                        sourcefiles = {},
                        objectfiles = {},
                        dependfiles = {}
                    }
                    -- g4 file have 3 case
                    -- lexer grammar LuaLexer;
                    -- parser grammar LuaParser;
                    -- grammar C;
                    local sourcefile_string = io.readfile(sourcefile)
                    local lexer_name = sourcefile_string:match("lexer grammar (%w+);")
                    local parser_name = sourcefile_string:match("parser grammar (%w+);")
                    -- lexer and parser same name
                    local grammar_name = sourcefile_string:match("grammar (%w+);")
                    if lexer_name or parser_name then
                        if lexer_name then
                            table.insert(batchcxx.sourcefiles, path.join(sourcefile_dir, lexer_name .. ".cpp"))
                        end
                        if parser_name then
                            table.insert(batchcxx.sourcefiles, path.join(sourcefile_dir, parser_name .. ".cpp"))
                        end
                    elseif grammar_name then
                        table.insert(batchcxx.sourcefiles, path.join(sourcefile_dir, grammar_name .. "Parser.cpp"))
                        table.insert(batchcxx.sourcefiles, path.join(sourcefile_dir, grammar_name .. "Lexer.cpp"))
                    end

                    for _, sourcefile in ipairs(batchcxx.sourcefiles) do
                        local objectfile = target:objectfile(sourcefile)
                        local dependfile = target:dependfile(objectfile)
                        table.insert(target:objectfiles(), objectfile)
                        table.insert(batchcxx.objectfiles, objectfile)
                        table.insert(batchcxx.dependfiles, dependfile)
                    end
                    build_objectfiles.build(target, batchcxx, opt)
                end)
            end
        end)
    end, {jobgraph = true, batch = true, distcc = true})

    before_buildcmd_file(function (target, batchcmds, sourcefile_g4, opt)
        local autogendir = path.join(target:autogendir(), "rules/antlr4")
        local sourcefile_dir = path.normalize(path.join(autogendir, path.directory(sourcefile_g4)))
        target:add("includedirs", sourcefile_dir, {public = true})
        os.mkdir(sourcefile_dir)

        local java = target:data("antlr4.tool")
        local argv = target:data("antlr4.tool.argv")
        table.join2(argv, target:values("antlr4.flags"))
        table.insert(argv, "-o")
        table.insert(argv, autogendir)
        table.insert(argv, "-lib")
        table.insert(argv, sourcefile_dir)
        table.insert(argv, sourcefile_g4)

        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.g4 %s", sourcefile_g4)
        batchcmds:vrunv(java.program, argv)

        local _build = function (sourcefile_cxx)
            local objectfile = target:objectfile(sourcefile_cxx)
            table.insert(target:objectfiles(), objectfile)
            batchcmds:show_progress(opt.progress, "${color.build.object}compiling.$(mode) %s", sourcefile_cxx)
            batchcmds:compile(sourcefile_cxx, objectfile)
    
            batchcmds:add_depfiles(sourcefile_g4)
            batchcmds:set_depmtime(os.mtime(objectfile))
            batchcmds:set_depcache(target:dependfile(objectfile))
        end

        -- g4 file have 3 case
        -- lexer grammar LuaLexer;
        -- parser grammar LuaParser;
        -- grammar C;
        local g4_string = io.readfile(sourcefile_g4)
        local lexer_name = g4_string:match("lexer grammar (%w+);")
        local parser_name = g4_string:match("parser grammar (%w+);")
        -- lexer and parser same name
        local grammar_name = g4_string:match("grammar (%w+);")
        if lexer_name or parser_name then
            if lexer_name then
                _build(path.join(sourcefile_dir, lexer_name .. ".cpp"))
            end
            if parser_name then
                _build(path.join(sourcefile_dir, parser_name .. ".cpp"))
            end
        elseif grammar_name then
            _build(path.join(sourcefile_dir, grammar_name .. "Lexer.cpp"))
            _build(path.join(sourcefile_dir, grammar_name .. "Parser.cpp"))
        end
    end)
