package("astc-encoder")
    set_homepage("https://developer.arm.com/graphics")
    set_description("The Arm ASTC Encoder, a compressor for the Adaptive Scalable Texture Compression data format.")
    set_license("Apache-2.0")

    add_urls("https://github.com/ARM-software/astc-encoder/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ARM-software/astc-encoder.git", {submodules = false})

    add_versions("5.2.0", "1680d440b765c3809490b6b49664a2ba0798624629615da4ff834401c0f1fe23")
    add_versions("4.8.0", "6c12f4656be21a69cbacd9f2c817283405decb514072dc1dcf51fd9a0b659852")
    add_versions("4.7.0", "a57c81f79055aa7c9f8c82ac5464284e3df9bba682895dee09fa35bd1fdbab93")
    add_versions("4.6.1", "a73c7afadb2caba00339a8f715079d43f9b7e75cf57463477e5ac36ef7defd26")

    add_configs("avx2", {description = "Enable astcenc builds for AVX2 SIMD", default = false, type = "boolean"})
    add_configs("sse41", {description = "Enable astcenc builds for SSE4.1 SIMD", default = false, type = "boolean"})
    add_configs("sse2", {description = "Enable astcenc builds for SSE2 SIMD", default = false, type = "boolean"})
    add_configs("neon", {description = "Enable astcenc builds for NEON SIMD", default = false, type = "boolean"})
    add_configs("none", {description = "Enable astcenc builds for no SIMD", default = false, type = "boolean"})
    add_configs("native", {description = "Enable astcenc builds for native SIMD", default = true, type = "boolean"})
    add_configs("decompressor", {description = "Enable astcenc builds for decompression only", default = false, type = "boolean"})
    add_configs("diagnostics", {description = "Enable astcenc builds with diagnostic trace", default = false, type = "boolean"})

    add_configs("invariance", {description = "Enable astcenc floating point invariance", default = true, type = "boolean"})
    add_configs("cli", {description = "Enable build of astcenc command line tools", default = true, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        package:config_set("cli", not package:is_cross())
        if package:is_plat("wasm", "cross") then
            package:config_set("none", true)
        end

        if package:config("shared") then
            package:add("defines", "ASTCENC_DYNAMIC_LIBRARY")
        end
    end)
    -- arm_neon_sve_bridge.h: No such file or directory
    on_install("!linux or linux|!arm64", function (package)
        io.replace("Source/cmake_core.cmake", "-Werror", "", {plain = true})
        io.replace("Source/CMakeLists.txt", "-flto", "", {plain = true})
        io.replace("Source/CMakeLists.txt", "-flto=auto", "", {plain = true})
        if package:is_plat("mingw", "android", "bsd") or package:has_tool("cxx", "clang") then
            io.replace("Source/cmake_core.cmake", "$<${is_clangcl}:-mcpu=native -march=native>", "", {plain = true})
            io.replace("Source/cmake_core.cmake", "$<${is_gnu_fe}:-mcpu=native -march=native>", "", {plain = true})
        end

        local file = io.open("Source/cmake_core.cmake", "a")
        local target_name = "${ASTCENC_TARGET}-" .. (package:config("shared") and "shared" or "static")
        file:write(format([[
            include(GNUInstallDirs)
            install(TARGETS %s
                RUNTIME DESTINATION bin
                LIBRARY DESTINATION lib
                ARCHIVE DESTINATION lib
            )
        ]], target_name))
        file:close()

        local configs = {"-DASTCENC_WERROR=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DASTCENC_SHAREDLIB=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DASTCENC_ISA_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_ISA_SSE41=" .. (package:config("sse41") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_ISA_SSE2=" .. (package:config("sse2") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_ISA_NEON=" .. (package:config("neon") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_ISA_NONE=" .. (package:config("none") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_ISA_NATIVE=" .. (package:config("native") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_DECOMPRESSOR=" .. (package:config("decompressor") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_DIAGNOSTICS=" .. (package:config("diagnostics") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_INVARIANCE=" .. (package:config("invariance") and "ON" or "OFF"))
        table.insert(configs, "-DASTCENC_CLI=" .. (package:config("cli") and "ON" or "OFF"))

        local opt = {}
        if package:is_plat("linux", "bsd") then
            opt.ldflags = "-lpthread"
            opt.shflags = "-lpthread"
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:config("shared") then
            io.replace("Source/astcenc.h",
                [[#define ASTCENC_PUBLIC extern "C" __declspec(dllexport)]],
                [[#define ASTCENC_PUBLIC extern "C" __declspec(dllimport)]], {plain = true})
        end

        os.cp("Source/astcenc.h", package:installdir("include"))
        if package:config("cli") then
            local exe_prefix = package:is_plat("mingw", "windows") and ".exe" or ""
            -- TODO: rename astcenc-neno?
            os.trymv(path.join(package:installdir("bin"), "astcenc-native" .. exe_prefix), path.join(package:installdir("bin"), "astcenc" .. exe_prefix))
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <astcenc.h>
            void test() {
                astcenc_context* context;
                astcenc_config* config = new astcenc_config();
                astcenc_error status = astcenc_context_alloc(config, 1, &context);
            }
        ]]}, {configs = {languages = "c++14"}}))
        if package:config("cli") and (not package:is_cross()) then
            os.vrun("astcenc -help")
        end
    end)
