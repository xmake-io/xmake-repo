package("svt-av1")
    set_homepage("https://gitlab.com/AOMediaCodec/SVT-AV1")
    set_description("Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder)")

    add_urls("https://gitlab.com/AOMediaCodec/SVT-AV1.git",
             "https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v$(version)/SVT-AV1-v$(version).tar.gz")
    add_versions("1.4.0", "0a4650b822c4eeb9656fbe96bd795e7a73cbfd1ab8c12546348ba88d8ed6b415")
    add_versions("1.4.1", "e3f7fc194afc6c90b43e0b80fa24c09940cb03bea394e0e1f5d1ded18e9ab23f")
    add_versions("1.5.0", "64e27b024eb43e4ba4e7b85584e0497df534043b2ce494659532c585819d0333")
    add_versions("1.6.0", "3bc207247568ac713245063555082bfc905edc31df3bf6355e3b194cb73ad817")

    if is_plat("wasm") then
        add_configs("shared",  {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("bsd", "linux", "wasm") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:is_targetarch("x64", "x86", "x86_64") then
            if is_host("windows") or package:is_plat("bsd") then
                package:add("deps", "nasm")
            else
                package:add("deps", "yasm")
            end
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCOVERAGE=OFF", "-DBUILD_APPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIB_INSTALL_DIR=" .. package:installdir("lib"))
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "if(MINGW)", "if(TRUE)\n    check_both_flags_add(-pthread)\n  elseif(MINGW)", {plain = true})
            io.replace("CMakeLists.txt", "set(CMAKE_EXE_LINKER_FLAGS \"${CMAKE_EXE_LINKER_FLAGS} -z noexecstack -z relro -z now\")",  "", {plain = true})
            io.replace("Source/Lib/Decoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
            io.replace("Source/Lib/Encoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
        elseif package:is_plat("mingw") and package:is_arch("x64", "x86_64") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=AMD64")
        elseif package:is_plat("android") then
            io.replace("CMakeLists.txt", "CMAKE_C_COMPILER_ID MATCHES \"Clang\" AND UNIX AND NOT APPLE", "FALSE", {plain = true})
            io.replace("Source/Lib/Decoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
            io.replace("Source/Lib/Decoder/CMakeLists.txt", "set(LIBS_PRIVATE \"-lpthread -lm\")", "set(LIBS_PRIVATE \"-lm\")", {plain = true})
            io.replace("Source/Lib/Encoder/CMakeLists.txt", "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
            io.replace("Source/Lib/Encoder/CMakeLists.txt", "set(LIBS_PRIVATE \"-lpthread -lm\")", "set(LIBS_PRIVATE \"-lm\")", {plain = true})
            io.replace("Source/Lib/Common/Codecs/EbThreads.h", "#if defined(__linux__)", "#if 0", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("svt_av1_enc_init_handle", {includes = "svt-av1/EbSvtAv1Enc.h"}))
    end)
