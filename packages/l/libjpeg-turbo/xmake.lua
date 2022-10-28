package("libjpeg-turbo")

    set_homepage("https://libjpeg-turbo.org/")
    set_description("A JPEG image codec that uses SIMD instructions (MMX, SSE2, AVX2, Neon, AltiVec) to accelerate baseline JPEG compression and decompression on x86, x86-64, Arm, and PowerPC systems.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libjpeg-turbo/libjpeg-turbo/archive/$(version).tar.gz",
             "https://github.com/libjpeg-turbo/libjpeg-turbo.git")
    add_versions("2.0.5",  "b3090cd37b5a8b3e4dbd30a1311b3989a894e5d3c668f14cbc6739d77c9402b7")
    add_versions("2.0.6",  "005aee2fcdca252cee42271f7f90574dda64ca6505d9f8b86ae61abc2b426371")
    add_versions("2.0.90", "6a965adb02ad898b2ae48214244618fe342baea79db97157fdc70d8844ac6f09")
    add_versions("2.1.0",  "d6b7790927d658108dfd3bee2f0c66a2924c51ee7f9dc930f62c452f4a638c52")
    add_versions("2.1.1",  "20e9cd3e5f517950dfb7a300ad344543d88719c254407ffb5ad88d891bf701c4")
    add_versions("2.1.2",  "e7fdc8a255c45bc8fbd9aa11c1a49c23092fcd7379296aeaeb14d3343a3d1bed")
    add_versions("2.1.3", "dbda0c685942aa3ea908496592491e5ec8160d2cf1ec9d5fd5470e50768e7859")
    add_versions("2.1.4", "a78b05c0d8427a90eb5b4eb08af25309770c8379592bb0b8a863373128e6143f")

    add_configs("jpeg", {description = "libjpeg API/ABI emulation target version.", default = "6", type = "string", values = {"6", "7", "8"}})

    if is_subhost("windows") and is_plat("android") then
        add_deps("make")
    end

    on_load(function (package)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake", "nasm")
        end
    end)

    on_install("windows", "linux", "macosx", "android", function (package)
        local configs = {}
        local jpeg = package:config("jpeg")
        if jpeg == "7" then
            table.insert(configs, "-DWITH_JPEG7=ON")
        elseif jpeg == "8" then
            table.insert(configs, "-DWITH_JPEG8=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DENABLE_SHARED=ON")
            table.insert(configs, "-DENABLE_STATIC=OFF")
        else
            table.insert(configs, "-DENABLE_SHARED=OFF")
            table.insert(configs, "-DENABLE_STATIC=ON")
        end
        if package:is_plat("windows") and package:config("vs_runtime"):startswith("MD") then
            table.insert(configs, "-DWITH_CRT_DLL=ON")
        end
        if package:is_plat("windows") and package:is_arch("arm64") then
            io.replace("CMakeLists.txt", 'message(STATUS "${BITS}-bit build (${CPU_TYPE})")',
                'set(CPU_TYPE arm64)\nmessage(STATUS "${BITS}-bit build (${CPU_TYPE})")', {plain = true})
        end
        table.insert(configs, "-DCMAKE_INSTALL_LIBDIR:PATH=lib")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tjSaveImage", {includes = "turbojpeg.h"}))
    end)
