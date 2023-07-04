package("joltphysics")
    set_homepage("https://github.com/jrouwe/JoltPhysics")
    set_description("A multi core friendly rigid body physics and collision detection library suitable for games and VR applications.")
    set_license("MIT")

    add_urls("https://github.com/jrouwe/JoltPhysics/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jrouwe/JoltPhysics.git")
    add_versions("v3.0.1", "7ebb40bf2dddbcf0515984582aaa197ddd06e97581fd55b98cb64f91b243b8a6")
    add_versions("v3.0.0", "f8d756ae3471a32f2ee7e07475df2f7a34752f0fdd05e9a7ed2e7ce3dcdcd574")
    add_versions("v2.0.1", "96ae2e8691c4802e56bf2587da30f2cc86b8abe82a78bc2398065bd87dd718af")
    -- patch for missing standard include (fixes Fedora compilation)
    add_patches("v3.0.1", path.join(os.scriptdir(), "patches", "v3.0.1", "fix_fedora.patch"), "12be1294669852a9f15cb01a636fde72fb5f36b59cbcc1d4f931d76c454c3150")
    add_patches("v3.0.0", path.join(os.scriptdir(), "patches", "v3.0.1", "fix_fedora.patch"), "12be1294669852a9f15cb01a636fde72fb5f36b59cbcc1d4f931d76c454c3150")
    add_patches("v2.0.1", path.join(os.scriptdir(), "patches", "v3.0.1", "fix_fedora.patch"), "12be1294669852a9f15cb01a636fde72fb5f36b59cbcc1d4f931d76c454c3150")
    -- patches for Android/ARMv7 and VS2019 ARM64 support
    add_patches("v2.0.1", path.join(os.scriptdir(), "patches", "v2.0.1", "android_fixes.patch"), "43b3d38ea5a01c281ad7b580859acaf0b30eac9a7bdc271a54199fcc88b8d491")
    add_patches("v2.0.1", path.join(os.scriptdir(), "patches", "v2.0.1", "armv7.patch"), "cbc59db0a0c786d473a05e84ed6f980c5288e531af44923864648c4471ccbd88")
    add_patches("v2.0.1", path.join(os.scriptdir(), "patches", "v2.0.1", "msvc_arm.patch"), "f6d368787ae7259dfbece7e8f1c1ba6af4d39f0f7c09a0f15186882bd827ed15")

    add_configs("cross_platform_deterministic", { description = "Turns on behavior to attempt cross platform determinism", default = false, type = "boolean" })
    add_configs("debug_renderer", { description = "Adds support to draw lines and triangles, used to be able to debug draw the state of the world", default = true, type = "boolean" })
    add_configs("double_precision", { description = "Compiles the library so that all positions are stored in doubles instead of floats. This makes larger worlds possible", default = false, type = "boolean" })
    add_configs("object_layer_bits", {description = "Number of bits to use in ObjectLayer. Can be 16 or 32.", default = "16", type = "string", values = {"16", "32"}})
    add_configs("symbols", { description = "When turning this option on, the library will be compiled with debug symbols", default = false, type = "boolean" })

    if is_arch("x86", "x64", "x86_64") then
        add_configs("inst_avx", { description = "Enable AVX CPU instructions (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_avx2", { description = "Enable AVX2 CPU instructions (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_avx512", { description = "Enable AVX512F+AVX512VL CPU instructions (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_f16c", { description = "Enable half float CPU instructions (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_fmadd", { description = "Enable fused multiply add CPU instructions (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_lzcnt", { description = "Enable the lzcnt CPU instruction (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_sse4_1", { description = "Enable SSE4.1 CPU instructions (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_sse4_2", { description = "Enable SSE4.2 CPU instructions (x86/x64 only)", default = false, type = "boolean" })
        add_configs("inst_tzcnt", { description = "Enable the tzcnt CPU instruction (x86/x64 only)", default = false, type = "boolean" })
    end

    -- jolt physics doesn't support dynamic link
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("linux", "macosx", "iphoneos", "bsd", "wasm") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        local version = package:version()
        if not version or version:ge("3.0.0") then
            package:add("deps", "cmake")
            package:add("defines", "JPH_OBJECT_LAYER_BITS=" .. package:config("object_layer_bits"))
        end
        if package:is_plat("windows") and not package:config("shared") then
            package:add("syslinks", "Advapi32")
        end
        package:add("defines", "JPH_PROFILE_ENABLED")
        if package:is_plat("windows") then
            package:add("defines", "JPH_FLOATING_POINT_EXCEPTIONS_ENABLED")
        end
        if package:config("cross_platform_deterministic") then
            package:add("defines", "JPH_CROSS_PLATFORM_DETERMINISTIC")
        end
        if package:config("debug_renderer") then
            package:add("defines", "JPH_DEBUG_RENDERER")
        end
        if package:config("double_precision") then
            package:add("defines", "JPH_DOUBLE_PRECISION")
        end
    end)

    on_install("windows", "mingw", "linux", "macosx", "iphoneos", "android", "wasm", function (package)
        -- Jolt CMakeLists had no install target/support for custom msvc runtime until 3.0.0
        local version = package:version()
        if not version or version:ge("3.0.0") then
            os.cd("Build")
            local configs = {
                "-DENABLE_ALL_WARNINGS=OFF",
                "-DINTERPROCEDURAL_OPTIMIZATION=OFF",
                "-DTARGET_UNIT_TESTS=OFF",
                "-DTARGET_HELLO_WORLD=OFF",
                "-DTARGET_PERFORMANCE_TEST=OFF",
                "-DTARGET_SAMPLES=OFF",
                "-DTARGET_VIEWER=OFF",
                "-DUSE_STATIC_MSVC_RUNTIME_LIBRARY=OFF"
            }
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DCROSS_PLATFORM_DETERMINISTIC=" .. (package:config("cross_platform_deterministic") and "ON" or "OFF"))
            table.insert(configs, "-DDOUBLE_PRECISION=" .. (package:config("double_precision") and "ON" or "OFF"))
            table.insert(configs, "-DGENERATE_DEBUG_SYMBOLS=" .. ((package:debug() or package:config("symbols")) and "ON" or "OFF"))
            table.insert(configs, "-DOBJECT_LAYER_BITS=" .. package:config("object_layer_bits"))
            table.insert(configs, "-DUSE_AVX=" .. (package:config("inst_avx") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_AVX2=" .. (package:config("inst_avx2") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_AVX512=" .. (package:config("inst_avx512") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_F16C=" .. (package:config("inst_f16c") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_FMADD=" .. (package:config("inst_fmadd") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_LZCNT=" .. (package:config("inst_lzcnt") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_SSE4_1=" .. (package:config("inst_sse4_1") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_SSE4_2=" .. (package:config("inst_sse4_2") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_TZCNT=" .. (package:config("inst_tzcnt") and "ON" or "OFF"))

            import("package.tools.cmake").install(package, configs)
        else
            os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
            local configs = {}
            configs.cross_platform_deterministic = package:config("cross_platform_deterministic")
            configs.debug_renderer = package:config("debug_renderer")
            configs.double_precision = package:config("double_precision")
            if package:is_arch("x86", "x64", "x86_64") then
                configs.inst_avx    = package:config("inst_avx")
                configs.inst_avx2   = package:config("inst_avx2")
                configs.inst_avx512 = package:config("inst_avx512")
                configs.inst_f16c   = package:config("inst_f16c")
                configs.inst_fmadd  = package:config("inst_fmadd")
                configs.inst_lzcnt  = package:config("inst_lzcnt")
                configs.inst_sse4_1 = package:config("inst_sse4_1")
                configs.inst_sse4_2 = package:config("inst_sse4_2")
                configs.inst_tzcnt  = package:config("inst_tzcnt")
            end
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                JPH::RegisterDefaultAllocator();
                JPH::PhysicsSystem physics_system;
                physics_system.OptimizeBroadPhase();
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"Jolt/Jolt.h", "Jolt/Physics/PhysicsSystem.h"}}))
    end)
