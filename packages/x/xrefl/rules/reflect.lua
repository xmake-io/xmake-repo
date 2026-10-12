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
-- the description scope. The includes() form takes the same table.

rule("reflect")
    add_deps("plugin.compile_commands.autoupdate")

    -- A package rule may not use on_load. on_config still runs early enough
    -- for the generated sources to reach the build.
    on_config(function (target)
        local package = assert(target:pkg("xrefl"),
            "the @xrefl/reflect rule needs add_packages(\"xrefl\") on the target")
        local root = path.join(package:installdir(), "share", "xrefl")
        local modules = path.join(root, "modules")
        import("xrefl.configure", {rootdir = modules})
        import("xrefl.plan", {rootdir = modules})

        target:data_set("xrefl.modules", modules)
        target:data_set("xrefl.emitterdir", path.join(root, "emitters"))
        configure.apply(target, target:extraconf("rules", "@xrefl/reflect"),
                        target:data("xrefl.emitterdir"))

        -- The runtime headers the reference emitters generate against.
        target:add("includedirs", path.join(package:installdir(), "include"), {public = true})
        plan.attach(target)
    end)

    before_build(function (target, opt)
        import("xrefl.generate", {rootdir = target:data("xrefl.modules")})
        generate.run(target, opt)
    end)
