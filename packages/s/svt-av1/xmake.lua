package("svt-av1")
    set_homepage("https://gitlab.com/AOMediaCodec/SVT-AV1")
    set_description("Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder)")
    set_license("BSD-3-Clause")

    add_urls("https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/$(version)/SVT-AV1-$(version).tar.gz",
             "https://gitlab.com/AOMediaCodec/SVT-AV1.git")

    add_versions("v2.2.1", "d02b54685542de0236bce4be1b50912aba68aff997c43b350d84a518df0cf4e5")
    add_versions("v2.1.0", "72a076807544f3b269518ab11656f77358284da7782cece497781ab64ed4cb8a")
    add_versions("v1.4.0", "0a4650b822c4eeb9656fbe96bd795e7a73cbfd1ab8c12546348ba88d8ed6b415")
    add_versions("v1.4.1", "e3f7fc194afc6c90b43e0b80fa24c09940cb03bea394e0e1f5d1ded18e9ab23f")
    add_versions("v1.5.0", "64e27b024eb43e4ba4e7b85584e0497df534043b2ce494659532c585819d0333")
    add_versions("v1.6.0", "3bc207247568ac713245063555082bfc905edc31df3bf6355e3b194cb73ad817")

    add_configs("encoder", {description = "Build Encoder lib (deprecated after v2.1.1)", default = true, type = "boolean"})
    add_configs("decoder", {description = "Build Decoder lib (deprecated after v2.1.1)", default = true, type = "boolean"})
    add_configs("avx512", {description = "Enable building avx512 code", default = false, type = "boolean"})
    add_configs("minimal_build", {description = "Enable minimal build", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("android") and is_host("linux") then
        -- llvm-ar: not found
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::svt-av1")
    elseif is_plat("linux") then
        add_extsources("pacman::svt-av1", "apt::libsvtav1-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::svt-av1")
    end

    if not is_plat("windows") then
        add_configs("pgo",     {description = "Enable profile guided optimization. Creates the RunPGO and CompilePGO targets", default = false, type = "boolean"})
        add_configs("native",  {description = "Build for native performance (march=native)", default = false, type = "boolean"})
    end

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    elseif is_plat("wasm") then
        add_syslinks("pthread")
        add_ldflags("-s USE_PTHREADS=1")
    end

    add_deps("cmake", "nasm")
    add_deps("cpuinfo")

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "EB_DLL")
        end
    end)

    on_install("!cross and (!windows or windows|!arm64)", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCOVERAGE=OFF",
            "-DUSE_EXTERNAL_CPUINFO=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSVT_AV1_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DSVT_AV1_PGO=" .. (package:config("pgo") and "ON" or "OFF"))

        table.insert(configs, "-DBUILD_ENC=" .. (package:config("encoder") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DEC=" .. (package:config("decoder") and "ON" or "OFF"))
        table.insert(configs, "-DMINIMAL_BUILD=" .. (package:config("minimal_build") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_AVX512=" .. (package:config("avx512") and "ON" or "OFF"))
        table.insert(configs, "-DNATIVE=" .. (package:config("native") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_APPS=" .. (package:config("tools") and "ON" or "OFF"))

        if package:version() and package:version():lt("2.0.0") then
            if package:is_plat("wasm") then
                io.replace("CMakeLists.txt", "if(MINGW)", "if(TRUE)\n    check_both_flags_add(-pthread)\n  elseif(MINGW)", {plain = true})
                io.replace("CMakeLists.txt", "set(CMAKE_EXE_LINKER_FLAGS \"${CMAKE_EXE_LINKER_FLAGS} -z noexecstack -z relro -z now\")",  "", {plain = true})
                io.replace("Source/Lib/Decoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
                io.replace("Source/Lib/Encoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
                io.replace("Source/Lib/Decoder/Codec/EbDecHandle.c", "!geteuid()", "0", {plain = true})
                io.replace("Source/Lib/Common/Codec/EbThreads.c", "!geteuid()", "0", {plain = true})
                io.replace("Source/Lib/Encoder/Globals/EbEncHandle.c", "!geteuid()", "0", {plain = true})
            elseif package:is_plat("mingw") and package:is_arch("x64", "x86_64") then
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=AMD64")
            elseif package:is_plat("android") then
                io.replace("CMakeLists.txt", "CMAKE_C_COMPILER_ID MATCHES \"Clang\" AND UNIX AND NOT APPLE", "FALSE", {plain = true})
                io.replace("Source/Lib/Decoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
                io.replace("Source/Lib/Decoder/CMakeLists.txt", "set(LIBS_PRIVATE \"-lpthread -lm\")", "set(LIBS_PRIVATE \"-lm\")", {plain = true})
                io.replace("Source/Lib/Encoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
                io.replace("Source/Lib/Encoder/CMakeLists.txt", "set(LIBS_PRIVATE \"-lpthread -lm\")", "set(LIBS_PRIVATE \"-lm\")", {plain = true})
                io.replace("Source/Lib/Common/Codec/EbThreads.h", "#if defined(__linux__)", "#if 0", {plain = true})
            end
        end

        local opt = {}
        if package:is_plat("wasm") then
            -- https://stackoverflow.com/questions/58854858/undefined-symbol-stack-chk-guard-in-libopenh264-so-when-building-ffmpeg-wit
            -- https://github.com/emscripten-core/emscripten/issues/17030
            opt.cxflags = {"-fno-stack-protector", "-U_FORTIFY_SOURCE"}
            opt.ldflags = {"-fno-stack-protector", "-U_FORTIFY_SOURCE"}
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        local ldflags = {}
        if package:is_plat("wasm") then
            table.insert(ldflags, "-s USE_PTHREADS=1")
            table.insert(ldflags, "-s TOTAL_MEMORY=256MB")
        end

        if package:gitref() or package:version():ge("2.1.1") then
            assert(package:has_cfuncs("svt_av1_enc_init_handle", {
                includes = "svt-av1/EbSvtAv1Enc.h", configs = {ldflags = ldflags}
            }))
        else
            if package:config("encoder") then
                assert(package:has_cfuncs("svt_av1_enc_init_handle", {includes = {"stddef.h", "svt-av1/EbSvtAv1Enc.h"}}))
            end
            if package:config("decoder") then
                assert(package:has_cfuncs("svt_av1_dec_init_handle", {includes = {"stddef.h", "svt-av1/EbSvtAv1Dec.h"}}))
            end
        end
    end)
