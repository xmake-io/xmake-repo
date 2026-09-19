function _general(package)
    local configs = {
        "-DBUILD_TESTING=OFF",
        "-DDAWN_BUILD_SAMPLES=OFF",
        "-DDAWN_BUILD_NODE_BINDINGS=OFF",
        "-DDAWN_BUILD_BENCHMARKS=OFF",
        "-DTINT_BUILD_TESTS=OFF",
        "-DDAWN_WERROR=OFF",
        "-DDAWN_ENABLE_INSTALL=ON",
        "-DDAWN_FETCH_DEPENDENCIES=OFF",
    }

    table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
    table.insert(configs, "-DDAWN_BUILD_MONOLITHIC_LIBRARY=ON")
    table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")

    table.insert(configs, "-DDAWN_ENABLE_PIC=" .. (package:config("pic") and "ON" or "OFF"))
    table.insert(configs, "-DDAWN_ENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
    table.insert(configs, "-DDAWN_ENABLE_TSAN=" .. (package:config("tsan") and "ON" or "OFF"))
    table.insert(configs, "-DDAWN_ENABLE_MSAN=" .. (package:config("msan") and "ON" or "OFF"))
    table.insert(configs, "-DDAWN_ENABLE_UBSAN=" .. (package:config("ubsan") and "ON" or "OFF"))
    return configs
end

function _tint(package)
    local configs = {}
    table.insert(configs, "-DTINT_ENABLE_INSTALL=OFF")
    table.insert(configs, "-DTINT_BUILD_CMD_TOOLS=OFF")

    table.insert(configs, "-DTINT_BUILD_SPV_READER=OFF")
    table.insert(configs, "-DTINT_BUILD_WGSL_READER=ON")
    table.insert(configs, "-DTINT_BUILD_GLSL_WRITER=OFF")
    table.insert(configs, "-DTINT_BUILD_GLSL_VALIDATOR=OFF")
    table.insert(configs, "-DTINT_BUILD_HLSL_WRITER=OFF")
    table.insert(configs, "-DTINT_BUILD_MSL_WRITER=OFF")
    table.insert(configs, "-DTINT_BUILD_SPV_WRITER=OFF")
    table.insert(configs, "-DTINT_BUILD_WGSL_WRITER=OFF")

    table.insert(configs, "-DTINT_BUILD_SYNTAX_TREE_WRITER=OFF")
    table.insert(configs, "-DTINT_BUILD_IR_BINARY=OFF")
    return configs
end

function _graphics_backend(package)
    local configs = {}
    table.insert(configs, "-DDAWN_ENABLE_D3D11=OFF")
    table.insert(configs, "-DDAWN_ENABLE_D3D12=OFF")
    table.insert(configs, "-DDAWN_ENABLE_METAL=OFF")
    table.insert(configs, "-DDAWN_ENABLE_NULL=ON")
    table.insert(configs, "-DDAWN_ENABLE_DESKTOP_GL=OFF")
    table.insert(configs, "-DDAWN_ENABLE_OPENGLES=OFF")
    table.insert(configs, "-DDAWN_ENABLE_VULKAN=OFF")
    table.insert(configs, "-DDAWN_ENABLE_SPIRV_VALIDATION=OFF")
    return configs
end

function _deps(package)
    local configs = {}
    table.insert(configs, "-DDAWN_USE_GLFW=OFF")

    return configs
end

function get(package)
    local configs = {}
    table.join2(configs, _general(package))
    table.join2(configs, _tint(package))
    table.join2(configs, _graphics_backend(package))
    table.join2(configs, _deps(package))

    if package:is_plat("wasm") then
        local emscripten = package:toolchain("emcc")
        assert(emscripten, "package(google-dawn/wasm) require emscripten toolchain")
        table.insert(configs, "-DDAWN_EMSCRIPTEN_TOOLCHAIN=" .. emscripten:config("sdkdir"))
    end

    return configs
end
