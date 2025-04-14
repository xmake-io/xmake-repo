add_slang_target("core", {
    includes = {
        { "$(projectdir)/include", "$(projectdir)/source", { public = true } }
    },
    files = {
        { "./*.cpp" }
    },
    windows_files = "./windows/*.cpp",
    linux_files = "./unix/*.cpp",
    packages = {
        { "miniz", "lz4", { public = false } },
        { "unordered_dense", { public = true } },
    },
})


