-- Generate source files from wayland protocol files.
-- Example:
--[[
    if is_plat("linux") then
        add_rules("@wayland-protocols/wayland.protocols")
        on_load(function(target)
            local pkg = target:pkg("wayland-protocols")
            local wayland_protocols_dir = path.join(target:pkg("wayland-protocols"):installdir() or "/usr", "share", "wayland-protocols")
            local protocols = {path.join("stable", "xdg-shell", "xdg-shell.xml"),
                               path.join("unstable", "xdg-decoration", "xdg-decoration-unstable-v1.xml")}
            for _, protocol in ipairs(protocols) do
                target:add("files", path.join(wayland_protocols_dir, protocol))
            end
        end)
    end
]]
-- Options:
--[[
    add_rules("@wayland-protocols/wayland.protocols", {
        outputdir = "...",  -- Path for generated files, default is `path.join(target:autogendir(), "rules", "wayland.protocols")`
        client = "...",     -- Path format for client protocol header files, default is `"%s.h"`, set to `false` to disable its generation
        server = "...",     -- Path format for server protocol header files, default is `nil`
        code = "...",       -- Path format for code files, default is `"%s.c"`
        public = false,     -- Visibility for headers and symbols in generated code, can be `false` or `true`, default is `false`
    })
]]

rule("wayland.protocols")
    set_extensions(".xml")

    on_config(function(target)
        import("core.base.option")

        local rule_name = "@wayland-protocols/wayland.protocols"

        if target:rule("c++.build") then
            local rule = target:rule("c++.build"):clone()
            rule:add("deps", rule_name, {order = true})
            target:rule_add(rule)
        end

        local public = target:extraconf("rules", rule_name, "public")

        local outputdir = target:extraconf("rules", rule_name, "outputdir") or path.join(target:autogendir(), "rules", "wayland.protocols")
        if not os.isdir(outputdir) then
            os.mkdir(outputdir)
        end
        target:add("includedirs", outputdir, {public = public})

        local dryrun = option.get("dry-run")
        local sourcebatches = target:sourcebatches()[rule_name]
        if not dryrun and sourcebatches and sourcebatches.sourcefiles then
            local client = target:extraconf("rules", rule_name, "client")
            if client == nil then
                client = "%s.h"
            end
            local server = target:extraconf("rules", rule_name, "server")
            for _, protocol in ipairs(sourcebatches.sourcefiles) do
                local basename = path.basename(protocol)

                -- For C++ module dependency discovery
                if client then
                    local clientfile = path.join(outputdir, client:format(basename))
                    os.touch(clientfile)
                end
                if server then
                    local serverfile = path.join(outputdir, server:format(basename))
                    os.touch(serverfile)
                end

                -- Add code file to target
                local code = target:extraconf("rules", rule_name, "code") or "%s.c"
                local codefile = path.join(outputdir, code:format(basename))
                target:add("files", codefile, {always_added = true})
            end
        end
    end)

    before_buildcmd_file(function(target, batchcmds, sourcefile, opt)
        import("lib.detect.find_tool")

        local rule_name = "@wayland-protocols/wayland.protocols"

        local outputdir = target:extraconf("rules", rule_name, "outputdir") or path.join(target:autogendir(), "rules", "wayland.protocols")

        local wayland_scanner = find_tool("wayland-scanner")
        assert(wayland_scanner, "wayland-scanner not found! please install wayland package")

        local basename = path.basename(sourcefile)

        -- Generate client protocol header
        local client = target:extraconf("rules", rule_name, "client")
        if client == nil then
            client = "%s.h"
        end
        if client then
            local clientfile = path.join(outputdir, client:format(basename))
            local client_args = {"client-header", sourcefile, clientfile}
            batchcmds:show_progress(opt.progress, "${color.build.object}generating.wayland.protocol.client %s", basename)
            batchcmds:vexecv(wayland_scanner.program, client_args)
        end

        -- Generate server protocol header
        local server = target:extraconf("rules", rule_name, "server")
        if server then
            local serverfile = path.join(outputdir, server:format(basename))
            local server_args = {"server-header", sourcefile, serverfile}
            batchcmds:show_progress(opt.progress, "${color.build.object}generating.wayland.protocol.server %s", basename)
            batchcmds:vexecv(wayland_scanner.program, server_args)
        end

        -- Generate code
        local public = target:extraconf("rules", rule_name, "public")
        local visibility = public and "public" or "private"

        local code = target:extraconf("rules", rule_name, "code") or "%s.c"
        local codefile = path.join(outputdir, code:format(basename))
        local code_args = {visibility .. "-code", sourcefile, codefile}
        batchcmds:show_progress(opt.progress, "${color.build.object}generating.wayland.protocol.%s %s", visibility, basename)
        batchcmds:vexecv(wayland_scanner.program, code_args)

        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(codefile))
        batchcmds:set_depcache(target:dependfile(codefile))
    end)
