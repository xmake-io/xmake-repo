add_slang_target("slang-capability-defs", {
    kind = "object",
    fence = true,
    deps = {
        { "slang-capability-generator" }
    },
    includes = {
        { "$(buildir)/capabilities", "$(projectdir)/source/slang", { public = true } }
    },
    before_build = function()
        import("core.project.config")
        local output_dir = path.join(config.buildir(), "capabilities")
        os.mkdir(output_dir)

        for _, file_path in ipairs(os.files("$(scriptdir)/*.capdef")) do
            print("Generating capability defs for " .. file_path)
            os.vrunv("$(buildir)/generators/slang-capability-generator", {
                file_path, "--target-directory", output_dir, "--doc",
                path.join(os.projectdir(), "docs/dummy.md")
            })
        end
    end,
})

add_slang_target("slang-capability-lookup", {
    kind = "object",
    deps = {
        { "core", "slang-capability-defs" }
    },
    files = {
        { "$(buildir)/capabilities/slang-lookup-capability-defs.cpp", { always_added = true } }
    },
})

add_slang_target("slang-lookup-tables", {
    kind = "object",
    deps = {
        { "slang-lookup-generator", "slang-spirv-embed-generator" }
    },
    files = {
        {
            "$(buildir)/slang-lookup-tables/slang-lookup-GLSLstd450.cpp",
            "$(buildir)/slang-lookup-tables/slang-spirv-core-grammar-embed.cpp",
            { always_added = true }
        }
    },
    packages = {
        { "spirv-headers" }
    },
    before_build = function(target)
        import("core.project.config")
        local output_dir = path.join(config.buildir(), "slang-lookup-tables")
        local spirv_path = target:pkg("spirv-headers"):installdir():gsub("\\", "/")
        local grammar_dir = path.join(spirv_path, "include", "spirv", "unified1")

        local glsl_grammar_file = path.join(grammar_dir, "extinst.glsl.std.450.grammar.json")
        local glsl_generated_source = path.join(output_dir, "slang-lookup-GLSLstd450.cpp")
        local spirv_grammar_file = path.join(grammar_dir, "spirv.core.grammar.json")
        local spirv_generated_source = path.join(output_dir, "slang-spirv-core-grammar-embed.cpp")
        os.mkdir(output_dir)

        os.vrunv("$(buildir)/generators/slang-lookup-generator", {
            glsl_grammar_file, glsl_generated_source, "GLSLstd450", "GLSLstd450",
            "spirv/unified1/GLSL.std.450.h",
        })

        os.vrunv("$(buildir)/generators/slang-spirv-embed-generator", {
            spirv_grammar_file, spirv_generated_source
        })
    end
})

add_slang_target("slang-reflect-headers", {
    kind = "phony",
    fence = true,
    includes = {
        { "$(buildir)/ast-reflect", { public = true } }
    },
    deps = {
        { "slang-cpp-extractor", { public = false } }
    },
    before_build = function()
        import("core.project.config")
        local working_dir = path.join(os.scriptdir())
        local output_dir = path.absolute(path.join(config.buildir(), "ast-reflect"))

        os.mkdir(output_dir)

        local SLANG_REFLECT_INPUT = {
            "slang-ast-support-types.h",
            "slang-ast-base.h",
            "slang-ast-decl.h",
            "slang-ast-expr.h",
            "slang-ast-modifier.h",
            "slang-ast-stmt.h",
            "slang-ast-type.h",
            "slang-ast-val.h",
        }

        local args = {}
        for _, v in ipairs(SLANG_REFLECT_INPUT) do
            table.insert(args, path.join(working_dir, v))
        end
        table.insert(args, "-strip-prefix")
        table.insert(args, "slang-")
        table.insert(args, "-o")
        table.insert(args, path.join(output_dir, "slang-generated"))
        table.insert(args, "-output-fields")
        table.insert(args, "-mark-suffix")
        table.insert(args, "_CLASS")
        os.vrunv("$(buildir)/generators/slang-cpp-extractor", args)
    end
})

---------------------------------------------------------------------------------

local slang_link_args = {
    "core",
    "prelude",
    "compiler-core",
    "slang-capability-defs",
    "slang-capability-lookup",
    "slang-reflect-headers",
    "slang-lookup-tables",
    { public = false }
}

local slang_packages_args = {
    "spirv-headers",
    { public = false }
}

local slang_public_includes = {
    "$(projectdir)/include", { public = true },
}

add_slang_target("slang-common-objects", {
    kind = "object",
    export_macro_prefix = "SLANG",
    export_type_as = "shared",
    includes = {
        { "$(projectdir)", "$(buildir)", { public = false } }
    },
    files = {
        { "./*.cpp", "../slang-record-replay/record/*.cpp", "../slang-record-replay/util/*.cpp" }
    },
    config_files = {
        { "$(projectdir)/slang-tag-version.h.in", { filename = "slang-tag-version.h", pattern = "@(.-)@", public = true } },
    },
    defines = {
        { "SLANG_USE_SYSTEM_SPIRV_HEADER" }
    },
    deps = { slang_link_args },
    packages = { slang_packages_args },
})

add_slang_target("slang-without-embedded-core-module", {
    fence = true,
    kind = "shared",
    export_macro_prefix = "SLANG",
    includes = {
        slang_public_includes,
    },
    deps = {
        slang_link_args,
        { "slang-common-objects", "slang-no-embedded-core-module", "slang-embedded-core-module-source", { public = false } }
    },
    packages = { slang_packages_args },
    output_dir = "$(buildir)/generators",
    install_dir = "$(buildir)/generators",
})

add_slang_target("slang", {
    kind = "shared",
    includes = {
        slang_public_includes,
    },
    deps = {
        slang_link_args,
        { "slang-embedded-core-module", "slang-embedded-core-module-source", "slang-common-objects", { public = false } }
    },
    packages = { slang_packages_args },
})
