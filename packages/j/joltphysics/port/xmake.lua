add_rules("mode.asan", "mode.debug", "mode.releasedbg", "mode.release")

option("cross_platform_deterministic", { default = false, description = "Turns on behavior to attempt cross platform determinism. If this is set, JPH_USE_FMADD is ignored", defines = "JPH_CROSS_PLATFORM_DETERMINISTIC" })
option("debug_renderer", { default = true, description = "Adds support to draw lines and triangles, used to be able to debug draw the state of the world", defines = "JPH_DEBUG_RENDERER"})
option("double_precision", { default = false, description = "Compiles the library so that all positions are stored in doubles instead of floats. This makes larger worlds possible", defines = "JPH_DOUBLE_PRECISION" })
option("profile", { default = false, description = "Turns on the internal profiler", defines = "JPH_PROFILE_ENABLED"})

option("inst_avx", { default = false, description = "Enable AVX CPU instructions (x86/x64 only)" })
option("inst_avx2", { default = false, description = "Enable AVX2 CPU instructions (x86/x64 only)" })
option("inst_avx512", { default = false, description = "Enable AVX512F+AVX512VL CPU instructions (x86/x64 only)" })
option("inst_f16c", { default = false, description = "Enable half float CPU instructions (x86/x64 only)" })
option("inst_fmadd", { default = false, description = "Enable fused multiply add CPU instructions (x86/x64 only)" })
option("inst_lzcnt", { default = false, description = "Enable the lzcnt CPU instruction (x86/x64 only)" })
option("inst_sse4_1", { default = false, description = "Enable SSE4.1 CPU instructions (x86/x64 only)" })
option("inst_sse4_2", { default = false, description = "Enable SSE4.2 CPU instructions (x86/x64 only)" })
option("inst_tzcnt", { default = false, description = "Enable the tzcnt CPU instruction (x86/x64 only)" })

if has_config("cross_platform_deterministic") then
    set_fpmodels("precise")
else
    set_fpmodels("fast")
end

if is_mode("asan") then
    add_defines("JPH_DISABLE_TEMP_ALLOCATOR")
    add_defines("JPH_DISABLE_CUSTOM_ALLOCATOR")
end

set_languages("c++17")

target("Jolt")
    set_kind("$(kind)")
    add_includedirs(".")
    add_headerfiles("(Jolt/**.h)", "(Jolt/**.inl)")
    add_files("Jolt/**.cpp")
    add_options("cross_platform_deterministic", "debug_renderer", "double_precision", "profile")

    if is_plat("windows") then
        add_syslinks("Advapi32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_config(function (target)
        -- handle instruction sets flags
        if is_arch("x86", "x64", "x86_64") then
            if target:has_tool("cxx", "cl") then
                target:add("cxflags", "/arch:SSE2", {force = true})
                if has_config("inst_avx512") then
                    target:add("cxflags", "/arch:AVX512", {force = true})
                elseif has_config("inst_avx2") then
                    target:add("cxflags", "/arch:AVX2", {force = true})
                elseif has_config("inst_avx") then
                    target:add("cxflags", "/arch:AVX", {force = true})
                end
                if has_config("inst_sse4_1") then
                    target:add("defines", "JPH_USE_SSE4_1")
                end
                if has_config("inst_sse4_2") then
                    target:add("defines", "JPH_USE_SSE4_2")
                end
                if has_config("inst_lzcnt") then
                    target:add("defines", "JPH_USE_LZCNT")
                end
                if has_config("inst_tzcnt") then
                    target:add("defines", "JPH_USE_TZCNT")
                end
                if has_config("inst_f16c") then
                    target:add("defines", "JPH_USE_F16C")
                end
                if has_config("inst_fmadd") and not has_config("cross_platform_deterministic") then
                    target:add("defines", "JPH_USE_FMADD")
                end
            elseif target:has_tool("cxx", "clang", "gcc") then
                if has_config("inst_avx512") then
                    target:add("cxflags", "-mavx512f", "-mavx512vl", "-mavx512dq", "-mavx2", "-mbmi", "-mpopcnt", "-mlzcnt", "-mf16c", {force = true})
                elseif has_config("inst_avx2") then
                    target:add("cxflags", "-mavx2", "-mbmi", "-mpopcnt", "-mlzcnt", "-mf16c", {force = true})
                elseif has_config("inst_avx") then
                    target:add("cxflags", "-mavx", "-mpopcnt", {force = true})
                elseif has_config("inst_sse4_2") then
                    target:add("cxflags", "-msse4.2", "-mpopcnt", {force = true})
                elseif has_config("inst_sse4_1") then
                    target:add("cxflags", "-msse4.1", {force = true})
                else
                    target:add("cxflags", "-msse2", {force = true})
                end
                if has_config("inst_lzcnt") then
                    target:add("cxflags", "-mlzcnt", {force = true})
                end
                if has_config("inst_tzcnt") then
                    target:add("cxflags", "-mbmi", {force = true})
                end
                if has_config("inst_f16c") then
                    target:add("cxflags", "-mf16c", {force = true})
                end
                if has_config("inst_fmadd") and not has_config("cross_platform_deterministic") then
                    target:add("cxflags", "-mfma", {force = true})
                end
            end
        end
        if is_plat("linux", "macosx", "mingw", "iphoneos", "wasm") then
            if target:has_tool("cxx", "gcc") then
                target:add("cxflags", "-Wno-comment", "-Wno-stringop-overflow", "-ffp-contract=off", {force = true})
            else
                target:add("cxflags", "-ffp-contract=off", {force = true})
            end
        end
    end)
