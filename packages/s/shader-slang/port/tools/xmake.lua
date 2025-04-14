local add_generator = function(dir, options)
    options = options or {}
    if options.deps then
        table.insert(options.deps, { public = false })
    end

    if options.public_deps then
        table.insert(options.public_deps, { public = true })
    end

    add_slang_target(options.name or dir, {
        kind = "binary",
        files = {
            { dir .. "/*.cpp" }
        },
        deps = {
            options.deps or {},
            options.public_deps or {},
            { "core", { public = false } }
        },
        output_dir = "$(buildir)/generators",
        install_dir = "$(buildir)/generators",
        defines = {
            options.defines or {}
        },
        linkdirs = {
            { "$(buildir)/generators" }
        },
        links = {
            options.links or {}
        },
        fence = true,
    })
end

add_generator("slang-embed")
add_generator("slang-generate")
add_generator("slang-lookup-generator", { deps = { "compiler-core" } })
add_generator("slang-capability-generator", { deps = { "compiler-core" } })
add_generator("slang-spirv-embed-generator", { deps = { "compiler-core" } })

add_slang_target("slang-cpp-parser", {
    fence = true,
    kind = "static",
    files = { { "slang-cpp-parser/*.cpp" } },
    includes = { { ".", { public = true } } },
    deps = { { "core", "compiler-core", { public = false } } },
    output_dir = "$(buildir)/generators",
    export_macro_prefix = "SLANG",
    export_type_as = "shared",
})

add_generator("slang-cpp-extractor", { deps = { "compiler-core", "slang-cpp-parser" } })

add_generator("$(projectdir)/source/slangc", {
    name = "slang-bootstrap",
    deps = {
        "prelude",
        "slang-capability-lookup",
        "slang-lookup-tables",
    },
    public_deps = {
        "slang-without-embedded-core-module"
    },
    defines = {
        "SLANG_BOOTSTRAP=1",
    },
})


