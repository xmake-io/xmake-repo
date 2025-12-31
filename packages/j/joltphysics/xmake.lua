package("joltphysics")
    set_homepage("https://github.com/jrouwe/JoltPhysics")
    set_description("A multi core friendly rigid body physics and collision detection library suitable for games and VR applications.")
    set_license("MIT")

    add_urls("https://github.com/jrouwe/JoltPhysics/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jrouwe/JoltPhysics.git")
    add_versions("v5.5.0", "3dae862a32c9092fca5b17f8e5d32cd57e035d30c3145c00040f13ca58a866df")
    add_versions("v5.4.0", "1d2fdc33ef9a2da69efd704adc0a97da7c6ed698c2bded04b0c36f31207b0829")
    add_versions("v5.3.0", "e7f9621e480646c434150e1fbe3a9410f4ec4b04ffe54791e0678326b741b918")
    add_versions("v5.2.0", "f478afe3050c885e21403748e10ab18e3e8df8b0982c540e75f1e078ef8b2c88")
    add_versions("v5.1.0", "525c9d6fb79471b3995f9d621c9f843e71470aed286872c4d4065c1f7b7d049a")
    add_versions("v5.0.0", "5231953d1b1d5b9cb617facf86341a11337e1cd04456949af6911b917a1646cb")
    add_versions("v4.0.2", "046baf71d05e47de7a530ce5d58a587a93ea7e9ea1ef8bf3ff80238fb95650ae")
    add_versions("v4.0.1", "e0bb4fa07047ca9c38bd71262427ad2972a7f45f8dff74587f73457f3b60df82")
    add_versions("v4.0.0", "f8449ec72ffaadf423eeb80e0814f3ba14227bcf7f06cb9f3cbcfb3499a57b33")
    add_versions("v3.0.1", "7ebb40bf2dddbcf0515984582aaa197ddd06e97581fd55b98cb64f91b243b8a6")
    add_versions("v3.0.0", "f8d756ae3471a32f2ee7e07475df2f7a34752f0fdd05e9a7ed2e7ce3dcdcd574")
    add_versions("v2.0.1", "96ae2e8691c4802e56bf2587da30f2cc86b8abe82a78bc2398065bd87dd718af")
    -- patch for SSE instructions not enabled in 32bits mode
    add_patches("v5.0.0", "https://github.com/jrouwe/JoltPhysics/commit/ebccdcbfae6b60e37480aa203d0781d26e437fbc.patch", "274f3a3ccbe2af8c1d94a66a96c894340764da2b447a13c43a665930c2d56337")
    -- patch for visibility attributes (fixes compilation in shared mode on GCC <13)
    add_patches("v4.0.0", "https://github.com/jrouwe/JoltPhysics/commit/b084d8f9054d78cb50bc851cc4db505462c4c634.patch", "a8f5da0bc5d4a1011771016be2ad1cdb00d4c40dd0909ef6ae4a1d1c95e8e251")
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
    add_configs("profile", { description = "Turns on the internal profiler", default = false, type = "boolean" })
    add_configs("exceptions", { description = "Compile the library with C++ exceptions enabled. This adds some overhead and Jolt doesn't use exceptions so by default it is off.", default = false, type = "boolean" })
    add_configs("object_layer_bits", {description = "Number of bits to use in ObjectLayer. Can be 16 or 32.", default = "16", type = "string", values = {"16", "32"}})
    add_configs("object_stream", { description = "Compile the ObjectStream class and RTTI attribute information", default = true, type = "boolean" })
    add_configs("rtti", { description = "Compile the library with C++ RTTI enabled. This adds some overhead and Jolt doesn't use RTTI so by default it is off.", default = false, type = "boolean" })
    add_configs("symbols", { description = "When turning this option on, the library will be compiled with debug symbols", default = false, type = "boolean" })
    add_configs("symbol_format", { description = "Which type of debug symbols to generate", default = "", type = "string" })

    if is_arch("i386", "x86", "x64", "x86_64") then
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

    if is_plat("linux", "macosx", "iphoneos", "bsd", "wasm") then
        add_syslinks("pthread")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::jolt-physics")
    end

    on_load(function (package)
        local version = package:version()
        if not version or version:ge("3.0.0") then
            package:add("deps", "cmake")
            package:add("defines", "JPH_OBJECT_LAYER_BITS=" .. package:config("object_layer_bits"))
        end
        if package:is_plat("windows") and not package:config("shared") then
            package:add("syslinks", "advapi32")
        end
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
        if package:config("profile") then
            package:add("defines", "JPH_PROFILE_ENABLED")
        end
        if package:config("shared") then
            package:add("defines", "JPH_SHARED_LIBRARY")
        end
        if not package:is_debug() then
            package:add("defines", "JPH_NO_DEBUG")
        end
        if package:config("object_stream") then
            package:add("defines", "JPH_OBJECT_STREAM")
        end
        if package:is_arch("i386", "x86", "x64", "x86_64") then
            -- add instruction sets (from https://github.com/jrouwe/JoltPhysics/blob/4cd52055e09160affcafa557b39520331bf0d034/Jolt/Jolt.cmake#L602)
            if package:is_plat("windows") then
                if package:config("inst_avx512") then
                    package:add("cxxflags", "/arch:AVX512")
                elseif package:config("inst_avx2") then
                    package:add("cxxflags", "/arch:AVX2")
                elseif package:config("inst_avx") then
                    package:add("cxxflags", "/arch:AVX2")
                end
            else
                if package:config("inst_avx512") then
                    package:add("cxxflags", "-mavx512f", "-mavx512vl", "-mavx512dq", "-mavx2", "-mbmi", "-mpopcnt", "-mlzcnt", "-mf16c")
                elseif package:config("inst_avx2") then
                    package:add("cxxflags", "-mavx2", "-mbmi", "-mpopcnt", "-mlzcnt", "-mf16c")
                elseif package:config("inst_avx") then
                    package:add("cxxflags", "-mavx", "-mpopcnt")
                elseif package:config("inst_sse4_2") then
                    package:add("cxxflags", "-msse4.2", "-mpopcnt")
                elseif package:config("inst_sse4_1") then
                    package:add("cxxflags", "-msse4.1")
                else
                    package:add("cxxflags", "-msse2")
                end
                if package:config("inst_lzcnt") then
                    package:add("cxxflags", "-mlzcnt")
                end
                if package:config("inst_tzcnt") then
                    package:add("cxxflags", "-mbmi")
                end
                if package:config("inst_f16c") then
                    package:add("cxxflags", "-mf16c")
                end
                if package:config("inst_fmadd") and not package:config("cross_platform_deterministic") then
                    package:add("cxxflags", "-mfma")
                end
                package:add("cxxflags", "-mfpmath=sse")
            end
            if package:config("inst_avx512") then
        		package:add("defines", "JPH_USE_AVX512")
            end
            if package:config("inst_avx2") then
        		package:add("defines", "JPH_USE_AVX2")
            end
            if package:config("inst_avx") then
        		package:add("defines", "JPH_USE_AVX")
            end
        	if package:config("inst_sse4_1") then
        		package:add("defines", "JPH_USE_SSE4_1")
            end
        	if package:config("inst_sse4_2") then
        		package:add("defines", "JPH_USE_SSE4_2")
            end
        	if package:config("inst_lzcnt") then
        		package:add("defines", "JPH_USE_LZCNT")
            end
        	if package:config("inst_tzcnt") then
        		package:add("defines", "JPH_USE_TZCNT")
            end
        	if package:config("inst_f16c") then
        		package:add("defines", "JPH_USE_F16C")
            end
        	if package:config("inst_fmadd") and not package:config("cross_platform_deterministic") then
        		package:add("defines", "JPH_USE_FMADD")
            end
        end
    end)

    on_install("windows", "mingw", "linux", "macosx", "iphoneos", "android", "wasm", "bsd", function (package)
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
                "-DUSE_STATIC_MSVC_RUNTIME_LIBRARY=OFF",
                "-DOVERRIDE_CXX_FLAGS=OFF"
            }
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DCPP_EXCEPTIONS_ENABLED=" .. (package:config("exceptions") and "ON" or "OFF"))
            table.insert(configs, "-DCPP_RTTI_ENABLED=" .. (package:config("rtti") and "ON" or "OFF"))
            table.insert(configs, "-DCROSS_PLATFORM_DETERMINISTIC=" .. (package:config("cross_platform_deterministic") and "ON" or "OFF"))
            table.insert(configs, "-DDOUBLE_PRECISION=" .. (package:config("double_precision") and "ON" or "OFF"))
            table.insert(configs, "-DENABLE_OBJECT_STREAM=" .. (package:config("object_stream") and "ON" or "OFF"))
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
            if package:is_debug() or package:config("symbols") then
                table.insert(configs, "-DGENERATE_DEBUG_SYMBOLS=ON")
                table.insert(configs, "-DJPH_DEBUG_SYMBOL_FORMAT=" .. package:config("symbol_format"))
            else
                table.insert(configs, "-DGENERATE_DEBUG_SYMBOL=OFF")
            end
            -- https://github.com/jrouwe/JoltPhysics/issues/1133
            if package:is_plat("wasm") then
                table.insert(configs, "-DEMSCRIPTEN_SYSTEM_PROCESSOR=" .. package:targetarch())
            elseif package:is_plat("mingw") or (package:is_plat("linux", "macosx", "cross") and package:is_cross()) then
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:targetarch())
            end
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
            #include <cstdarg>
            void trace_impl(const char* fmt, ...) {
                va_list list;
                va_start(list, fmt);
                char buffer[1024];
                vsnprintf(buffer, sizeof(buffer), fmt, list);
                va_end(list);
            };
            bool AssertFailedImpl(const char *inExpression, const char *inMessage, const char *inFile, JPH::uint inLine)
            {
            	// Breakpoint
            	return true;
            };
            void test() {
                JPH::RegisterDefaultAllocator();
                JPH::Trace = &trace_impl;
                JPH_IF_ENABLE_ASSERTS(JPH::AssertFailed = &AssertFailedImpl;)
                JPH::PhysicsSystem physics_system;
                physics_system.OptimizeBroadPhase();
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"Jolt/Jolt.h", "Jolt/Physics/PhysicsSystem.h"}}))
    end)
