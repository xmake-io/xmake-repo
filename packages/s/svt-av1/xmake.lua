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
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIB_INSTALL_DIR=" .. package:installdir("lib"))
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "if(MINGW)", "if(TRUE)\n    check_both_flags_add(-pthread)\n  elseif(MINGW)", {plain = true})
            io.replace("CMakeLists.txt", "set(CMAKE_EXE_LINKER_FLAGS \"${CMAKE_EXE_LINKER_FLAGS} -z noexecstack -z relro -z now\")",  "", {plain = true})
            io.replace(path.join(os.curdir(), "Source", "Lib", "Decoder", "CMakeLists.txt"), "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
            io.replace(path.join(os.curdir(), "Source", "Lib", "Encoder", "CMakeLists.txt"), "list(APPEND PLATFORM_LIBS Threads::Threads)", "", {plain = true})
        elseif package:is_plat("mingw") and package:is_arch("x64", "x86_64") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=AMD64")
        elseif package:is_plat("android") and package:is_targetarch("arm64.*") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=aarch64")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("EbAv1PictureType", {includes = "svt-av1/EbSvtAv1.h"}))
    end)
