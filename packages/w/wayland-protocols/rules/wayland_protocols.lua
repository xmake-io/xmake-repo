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

    before_buildcmd_file(function(target, batchcmds, sourcefile, opt)
        import("lib.detect.find_tool")

        local outputdir = target:extraconf("rules", "wayland.protocols", "outputdir") or path.join(target:autogendir(), "rules", "wayland.protocols")

        local wayland_scanner = find_tool("wayland-scanner")
        assert(wayland_scanner, "wayland-scanner not found! please install wayland package")

        local clientfile = path.join(outputdir, path.basename(sourcefile) .. ".h")
        local privatefile = path.join(outputdir, path.basename(sourcefile) .. ".c")

        local client_flag = "client-header"
        local private_flag = "private-code"

        local client_flags = {client_flag, sourcefile, clientfile}
        local private_flags = {private_flag, sourcefile, privatefile}

        batchcmds:show_progress(opt.progress, "${color.build.object}generating.wayland.protocol.client %s", path.basename(sourcefile))
        batchcmds:vexecv(wayland_scanner.program, client_flags)

        batchcmds:show_progress(opt.progress, "${color.build.object}generating.wayland.protocol.private %s", path.basename(sourcefile))
        batchcmds:vexecv(wayland_scanner.program, private_flags)

        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(privatefile))
        batchcmds:set_depcache(target:dependfile(privatefile))
    end)
