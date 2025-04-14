add_slang_target("slang-glslang", {
    kind = "shared",
    includes = {
        { "$(projectdir)/source/slang-glslang", "$(projectdir)/include" }
    },
    files = {
        { "slang-glslang.cpp" }
    },
    packages = {
        { "glslang", "spirv-headers", "spirv-tools" }
    },
    ldflags = {
        { "-Wl,--exclude-libs,ALL" }
    }
})


