function add_slang_target(name, options)
    local from_table = function (tbl, func)
        tbl = tbl or {}
        for _, i in ipairs(tbl) do
            local args = {}
            for _, v in ipairs(i) do
                if type(v) == "string" then
                    table.insert(args, v)
                elseif type(v) == "table" then
                    table.insert(args, v)
                end
            end
            func(table.unpack(args))
        end
    end

    options = options or {}
    local kind = options.kind or "static"
    target(name)
        set_kind(kind)
        set_default(options.default or false)
        set_languages("cxx17")
        set_warnings("extra")
        add_rpathdirs("$ORIGIN")

        on_config(function (target)
            if is_mode("debug") then
                target:add("defines", "_DEBUG")
            end

            if is_plat("windows") then
                target:add("syslinks", "advapi32", "Shell32")
            elseif is_plat("linux") then
                target:add("syslinks", "dl", "pthread")
            end

            target:add("defines", "SLANG_COMPILER")
            if target:has_tool("cc", "cl") or target:has_tool("cc", "clang_cl") then
                target:add("defines", "_UNICODE", { force = true, public = true  })
                target:add("defines", "UNICODE", { force = true, public = true  })
                target:add("defines", "WIN32_LEAN_AND_MEAN", { force = true, public = true  })
                target:add("defines", "VC_EXTRALEAN", { force = true, public = true  })
                target:add("defines", "NOMINMAX", { force = true, public = true  })
                target:add("defines", "_WIN32", { force = true, public = true  })

                target:add("defines", "SLANG_VC=14", { force = true, public = true })
            elseif target:has_tool("cc", "clang") then
                target:add("defines", "SLANG_CLANG=1", { force = true, public = true })
            elseif target:has_tool("cc", "gcc") then
                target:add("defines", "SLANG_GCC=1", { force = true, public = true })
            end

            if options.on_config then
                options.on_config(target)
            end
        end)

        from_table(options.includes, add_includedirs)
        from_table(options.files, add_files)
        from_table(options.remove_files, remove_files)
        from_table(options.deps, add_deps)
        from_table(options.packages, add_packages)
        from_table(options.defines, add_defines)
        from_table(options.config_files, add_configfiles)
        from_table(options.ldflags, add_ldflags)
        from_table(options.linkdirs, add_linkdirs)
        from_table(options.links, add_links)

        if options.export_macro_prefix then
            local export_type_as = options.export_type_as or ""
            if kind == "shared" or export_type_as == "shared" then
                add_defines(options.export_macro_prefix .. "_DYNAMIC", { public = true })
                add_defines(options.export_macro_prefix .. "_DYNAMIC_EXPORT", { public = false })
            elseif kind == "static" or export_type_as == "static" then
                add_defines(options.export_macro_prefix .. "_STATIC", { public = true })
            end
        end

        if is_os("windows") and options.windows_files then
            add_files(options.windows_files)
        elseif is_os("linux") and options.linux_files then
            add_files(options.linux_files)
        end

        if options.rules then
            for _, rule in ipairs(options.rules) do
                add_rules(rule)
            end
        end

        if options.output_dir then
            set_targetdir(options.output_dir)
        end

        if options.install_dir then
            set_installdir(options.install_dir)
        end

        if options.before_build then
            before_build(options.before_build)
        end

        if options.kind == "binary" then
            add_cxxflags("-fPIE", { tools = { "clang", "gcc" } })
        else
            add_cxxflags("-fPIC", { tools = { "clang", "gcc" } })
        end

        set_enabled(not options.enabled or false)
        set_policy("build.fence", options.fence or false)
    target_end()
end


