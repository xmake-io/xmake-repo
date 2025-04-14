add_slang_target("compiler-core", {
    includes = {
        { ".", { public = true } }
    },
    files = {
        { "./*.cpp" }
    },
    deps = {
        { "core", { public = false } }
    },
    defines = {
        { "SLANG_ENABLE_DXIL_SUPPORT=0", { public = true } }
    },
    windows_files = "./windows/*.cpp",
    packages = {
        { "spirv-headers", { public = true } }
    }
})


