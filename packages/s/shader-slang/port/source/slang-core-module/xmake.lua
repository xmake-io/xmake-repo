add_slang_target("slang-no-embedded-core-module", {
--  ── common args ─────────────────────────────────────────────────────
    kind = "object",
    export_type_as = "shared",
    export_macro_prefix = "SLANG",
    files = {
        { "./slang-embedded-core-module.cpp" }
    },
    deps = {
        { "core", { public = false } }
    },
--  ── common args end ─────────────────────────────────────────────────
})

add_slang_target("slang-embedded-core-module", {
--  ── common args ─────────────────────────────────────────────────────
    kind = "object",
    export_type_as = "shared",
    export_macro_prefix = "SLANG",
    includes = { { "$(buildir)", { public = false } } },
    files = {
        { "./slang-embedded-core-module.cpp" }
    },
    deps = {
        { "core", "slang-without-embedded-core-module", "slang-bootstrap", { public = false } }
    },
--  ── common args end ─────────────────────────────────────────────────
    defines = {
        { "SLANG_EMBED_CORE_MODULE", { public = false } }
    },
    before_build = function ()
        import("core.project.config")
        local output_dir = config.buildir()
        local generated_header = path.join(output_dir, "slang-core-module-generated.h")

        os.vrunv("$(buildir)/generators/slang-bootstrap", {
            "-archive-type", "riff-lz4", "-save-core-module-bin-source", generated_header
        })
    end
})

add_slang_target("slang-embedded-core-module-source", {
    kind = "object",
    export_macro_prefix = "SLANG",
    export_type_as = "shared",
    includes = {
        { "$(projectdir)/source/slang", "$(buildir)/core-module-meta", { public = false } }
    },
    files = {
        { "./slang-embedded-core-module-source.cpp" }
    },
    deps = {
        { "core", "slang-generate", "slang-capability-defs", "slang-reflect-headers", { public = false } }
    },
    packages = {
        { "spirv-headers" }
    },
    defines = {
        { "SLANG_EMBED_CORE_MODULE_SOURCE", { public = false } }
    },
    before_build = function ()
        import("core.project.config")
        local output_dir = path.join(config.buildir(), "core-module-meta")
        local args = {}
        for _, v in ipairs(os.files("$(projectdir)/source/slang/*.meta.slang")) do
            table.insert(args, v)
        end

        table.insert(args, "--target-directory")
        table.insert(args, output_dir)

        os.mkdir(output_dir)
        os.vrunv("$(buildir)/generators/slang-generate", args)
    end
})
-- add_slang_target("slang-no-embedded-core-module-source", core_module_source_common_args)

