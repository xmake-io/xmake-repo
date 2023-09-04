-- Generate source files from wayland protocol files
-- for example
--[[
    if is_plat("linux") then
        add_rules("wayland-protocols@wayland.protocols")

        on_load(function(target)
            local pkg = target:pkg("wayland-protocols")
            local wayland_protocols_dir = path.join(target:pkg("wayland-protocols"):installdir() or "/usr", "share", "wayland-protocols")
            assert(wayland_protocols_dir, "wayland protocols directory not found")

            local protocols = {path.join("stable", "xdg-shell", "xdg-shell.xml"),
                                path.join("unstable", "xdg-decoration", "xdg-decoration-unstable-v1.xml")}

            for _, protocol in ipairs(protocols) do
                target:add("files", path.join(wayland_protocols_dir, protocol))
            end
        end)
    end
]]--

rule("wayland.protocols")
    set_extensions(".xml")

    on_load(function(target)
        if target:rule("c++.build") then
            local rule = target:rule("c++.build"):clone()
            rule:add("deps", "wayland.protocols", {order = true})
            target:rule_add(rule)
        end
    end)

    on_config(function(target)
        import("core.base.option")

        local outputdir = target:extraconf("rules", "wayland.protocols", "outputdir") or path.join(target:autogendir(), "rules", "wayland.protocols")
        if not os.isdir(outputdir) then
            os.mkdir(outputdir)
        end
        target:add("includedirs", outputdir)

        local dryrun = option.get("dry-run")
        local sourcebatches = target:sourcebatches()
        if not dryrun and sourcebatches["wayland.protocols"] and sourcebatches["wayland.protocols"].sourcefiles then
            for _, protocol in ipairs(sourcebatches["wayland.protocols"].sourcefiles) do
                local clientfile = path.join(outputdir, path.basename(protocol) .. ".h")
                local privatefile = path.join(outputdir, path.basename(protocol) .. ".c")

                -- for c++ module dependency discovery
                if not os.exists(clientfile) then
                    os.touch(clientfile)
                end

                target:add("files", privatefile, {always_added = true})
            end
        end
    end)

    before_build_files(function(target, batchjobs, sourcebatch, opt)
        sourcebatch.objectfiles = {}

        local outputdir = target:extraconf("rules", "wayland.protocols", "outputdir") or path.join(target:autogendir(), "rules", "wayland.protocols")

        opt.rootjob = batchjobs:group_leave() or opt.rootjob
        batchjobs:group_enter(target:name() .. "/generate_protocols", {rootjob = opt.rootjob})
        for _, protocol in ipairs(sourcebatch.sourcefiles) do
            batchjobs:addjob(target:name() .. "-generate-" .. protocol, function(index, total)
                import("utils.progress")
                import("core.base.option")
                import("core.project.depend")
                import("lib.detect.find_tool")

                opt.progress = opt.progress or (index * 100) / total

                local dryrun = option.get("dry-run")
                local dependfile = target:dependfile(protocol)
                local dependinfo = option.get("rebuild") and {} or (depend.load(dependfile) or {})

                local clientfile = path.join(outputdir, path.basename(protocol) .. ".h")
                local privatefile = path.join(outputdir, path.basename(protocol) .. ".c")

                local lastmtime = os.exists(privatefile) and os.mtime(dependfile) or 0
                if not dryrun and not depend.is_changed(dependinfo, {lastmtime = lastmtime}) then
                    return
                end

                local client_flag = "client-header"
                local private_flag = "private-code"

                local wayland_scanner = find_tool("wayland-scanner")
                assert(wayland_scanner, "wayland-scanner not found! please install wayland package")

                progress.show(opt.progress, "${color.build.object}generating.wayland.protocol.client %s", path.basename(protocol))
                vprint(wayland_scanner.program, client_flag, protocol, clientfile)

                progress.show(opt.progress, "${color.build.object}generating.wayland.protocol.private %s", path.basename(protocol))
                vprint(wayland_scanner.program, private_flag, protocol, privatefile)

                if not dryrun then
                    os.rm(clientfile)

                    dependinfo.files = {}

                    assert(os.execv(wayland_scanner.program, {client_flag, protocol, clientfile}))
                    assert(os.execv(wayland_scanner.program, {private_flag, protocol, privatefile}))

                    table.join2(dependinfo.files, protocol)
                    depend.save(dependinfo, dependfile)
                end
            end, {rootjob = opt.rootjob})
        end
    end, {batch = true})

    -- serial compilation only, usually used to support project generator
    before_buildcmd_files(function(target, batchcmds, sourcebatch, opt)
        import("lib.detect.find_tool")

        sourcebatch.objectfiles = {}

        local outputdir = target:extraconf("rules", "wayland.protocols", "outputdir") or path.join(target:autogendir(), "rules", "wayland.protocols")

        local wayland_scanner = find_tool("wayland-scanner")
        assert(wayland_scanner, "wayland-scanner not found! please install wayland package")

        for _, protocol in ipairs(sourcebatch.sourcefiles) do
            local clientfile = path.join(outputdir, path.basename(protocol) .. ".h")
            local privatefile = path.join(outputdir, path.basename(protocol) .. ".c")

            local client_flag = "client-header"
            local private_flag = "private-code"

            local client_flags = {client_flag, protocol, clientfile}
            local private_flags = {private_flag, protocol, privatefile}

            batchcmds:show_progress(opt.progress, "${color.build.object}generating.wayland.protocol.client %s", path.basename(protocol))
            batchcmds:vexecv(wayland_scanner.program, client_flags)

            batchcmds:show_progress(opt.progress, "${color.build.object}generating.wayland.protocol.private %s", path.basename(protocol))
            batchcmds:vexecv(wayland_scanner.program, private_flags)

            batchcmds:add_depfiles(protocol)
            batchcmds:set_depmtime(os.mtime(privatefile))
            batchcmds:set_depcache(target:dependfile(privatefile))
        end
    end)
