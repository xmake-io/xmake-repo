-- The rule a consumer gets from the installed package.
--
--   add_requires("xrefl")
--
--   target("mygame")
--       add_packages("xrefl")
--       add_rules("@xrefl/reflect", {
--           annotations = {
--               REFLECT  = { applies_to = "struct", args = { category = "string?" } },
--               PROPERTY = { applies_to = "field" },
--           },
--           emitters = { "@xrefl/emit_registry.lua", "tools/emit_custom.lua" },
--           headers  = { "src/**.h" },
--       })
--
-- Takes a table because a rule shipped in a package cannot add functions to
-- the description scope. Below this point it is the same code as the
-- includes() form.

rule("reflect")
    add_deps("plugin.compile_commands.autoupdate")

    -- A package rule may not use on_load. on_config still runs early enough
    -- for the generated sources to reach the build.
    on_config(function (target)
        local package = assert(target:pkg("xrefl"),
            "the @xrefl/reflect rule needs add_packages(\"xrefl\") on the target")
        local root = path.join(package:installdir(), "share", "xrefl")
        target:data_set("xrefl.emitterdir", path.join(root, "emitters"))

        -- The runtime headers the reference emitters generate against.
        target:add("includedirs", path.join(package:installdir(), "include"), {public = true})

        -- Registered rather than passed as rootdir, so the modules can import
        -- one another.
        import("core.sandbox.module")
        module.add_directories(path.join(root, "modules"))

        local conf = target:extraconf("rules", "@xrefl/reflect") or {}

        -- Written into the same target values the includes() form uses.
        for name, options in pairs(conf.annotations or {}) do
            target:add("values", "xrefl.annotations",
                       string.serialize({name = name, options = options},
                                        {strip = true, indent = false, orderkeys = true}))
        end
        for _, pattern in ipairs(table.wrap(conf.headers)) do
            target:add("values", "xrefl.headers", pattern)
        end
        for _, macro in ipairs(table.wrap(conf.ignore_macros)) do
            target:add("values", "xrefl.ignore_macros", macro)
        end
        for _, name in ipairs(table.wrap(conf.inherit)) do
            target:add("values", "xrefl.inherit", name)
        end
        if conf.publish then
            target:add("values", "xrefl.publish", "true")
        end
        for _, script in ipairs(table.wrap(conf.emitters)) do
            -- `@xrefl/name.lua` is a reference emitter shipped with the package.
            local shipped = script:match("^@xrefl/(.+)$")
            target:add("values", "xrefl.emitters",
                       shipped and path.join(target:data("xrefl.emitterdir"), shipped)
                               or path.absolute(script, target:scriptdir()))
        end

        import("xrefl.plan")
        plan.attach(target)
    end)

    before_build(function (target, opt)
        import("xrefl.generate")
        generate.run(target, opt)
    end)
