package("libjpeg-turbo")
    set_homepage("https://libjpeg-turbo.org/")
    set_description("A JPEG image codec that uses SIMD instructions (MMX, SSE2, AVX2, Neon, AltiVec) to accelerate baseline JPEG compression and decompression on x86, x86-64, Arm, and PowerPC systems.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libjpeg-turbo/libjpeg-turbo.git")

    add_versions("3.1.2", "560f6338b547544c4f9721b18d8b87685d433ec78b3c644c70d77adad22c55e6")
    add_versions("3.1.1", "304165ae11e64ab752e9cfc07c37bfdc87abd0bfe4bc699e59f34036d9c84f72")
    add_versions("3.1.0", "35fec2e1ddfb05ecf6d93e50bc57c1e54bc81c16d611ddf6eff73fff266d8285")
    add_versions("3.0.4",  "0270f9496ad6d69e743f1e7b9e3e9398f5b4d606b6a47744df4b73df50f62e38")
    add_versions("3.0.3",  "a649205a90e39a548863a3614a9576a3fb4465f8e8e66d54999f127957c25b21")
    add_versions("3.0.1",  "5b9bbca2b2a87c6632c821799438d358e27004ab528abf798533c15d50b39f82")
    add_versions("2.1.4",  "a78b05c0d8427a90eb5b4eb08af25309770c8379592bb0b8a863373128e6143f")
    add_versions("2.1.3",  "dbda0c685942aa3ea908496592491e5ec8160d2cf1ec9d5fd5470e50768e7859")
    add_versions("2.1.2",  "e7fdc8a255c45bc8fbd9aa11c1a49c23092fcd7379296aeaeb14d3343a3d1bed")
    add_versions("2.1.1",  "20e9cd3e5f517950dfb7a300ad344543d88719c254407ffb5ad88d891bf701c4")
    add_versions("2.1.0",  "d6b7790927d658108dfd3bee2f0c66a2924c51ee7f9dc930f62c452f4a638c52")
    add_versions("2.0.90", "6a965adb02ad898b2ae48214244618fe342baea79db97157fdc70d8844ac6f09")
    add_versions("2.0.6",  "005aee2fcdca252cee42271f7f90574dda64ca6505d9f8b86ae61abc2b426371")
    add_versions("2.0.5", "b3090cd37b5a8b3e4dbd30a1311b3989a894e5d3c668f14cbc6739d77c9402b7")

    add_configs("jpeg", {description = "libjpeg API/ABI emulation target version.", default = "6", type = "string", values = {"6", "7", "8"}})

    if is_plat("android") then
        add_deps("make")
    end

    on_load(function (package)
        if package:is_built() then
            package:add("deps", "cmake", "nasm")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "android", "mingw", function (package)
        io.replace("sharedlib/CMakeLists.txt", "string(REGEX REPLACE \"/MT\" \"/MD\"", "#", {plain = true})
        io.replace("sharedlib/CMakeLists.txt", "set(CMAKE_MSVC_RUNTIME_LIBRARY", "#", {plain = true})
        io.replace("sharedlib/CMakeLists.txt", "/NODEFAULTLIB:LIBCMT /NODEFAULTLIB:LIBCMTD", "", {plain = true})
        if package:is_plat("windows") and not package:config("shared") then
            io.replace("release/libjpeg.pc.in", "-ljpeg", "-ljpeg-static", {plain = true})
            io.replace("release/libturbojpeg.pc.in", "-lturbojpeg", "-lturbojpeg-static", {plain = true})
        end
        if package:is_plat("windows") and package:is_arch("arm64") then
            io.replace("CMakeLists.txt", 'message(STATUS "${BITS}-bit build (${CPU_TYPE})")',
                'set(CPU_TYPE arm64)\nmessage(STATUS "${BITS}-bit build (${CPU_TYPE})")', {plain = true})
        end

        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DENABLE_SHARED=ON")
            table.insert(configs, "-DENABLE_STATIC=OFF")
        else
            table.insert(configs, "-DENABLE_SHARED=OFF")
            table.insert(configs, "-DENABLE_STATIC=ON")
        end
        if package:is_plat("windows") and package:has_runtime("MD") then
            table.insert(configs, "-DWITH_CRT_DLL=ON")
        end
        if package:is_plat("mingw") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:arch())
        end

        local jpeg = package:config("jpeg")
        if jpeg == "7" then
            table.insert(configs, "-DWITH_JPEG7=ON")
        elseif jpeg == "8" then
            table.insert(configs, "-DWITH_JPEG8=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tjSaveImage", {includes = "turbojpeg.h"}))
    end)
