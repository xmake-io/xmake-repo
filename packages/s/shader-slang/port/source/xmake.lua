add_requires("unordered_dense v4.5.0")
add_requires("miniz 2.2.0")
add_requires("lz4 v1.10.0")
add_requires("spirv-headers 1.4.309+0")
add_requires("spirv-tools 1.4.309+0")
add_requires("glslang 1.4.309+0")

includes("core")
includes("compiler-core")
includes("slang-core-module")
includes("slang")
includes("slang-glslang")

add_slang_target("slang-build-all", {
    kind = "phony",
    default = true,
    fence = true,
    deps = {
        { "slang", "slang-glslang" }
    },
})
