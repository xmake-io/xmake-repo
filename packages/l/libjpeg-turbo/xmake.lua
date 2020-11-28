package("libjpeg-turbo")

    set_homepage("https://libjpeg-turbo.org/")
    set_description("A JPEG image codec that uses SIMD instructions (MMX, SSE2, AVX2, Neon, AltiVec) to accelerate baseline JPEG compression and decompression on x86, x86-64, Arm, and PowerPC systems.")
    set_license("BSD-3-Clause")

    add_urls("https://cfhcable.dl.sourceforge.net/project/libjpeg-turbo/$(version)/libjpeg-turbo-$(version).tar.gz", {alias = "sf"})
    add_urls("https://github.com/libjpeg-turbo/libjpeg-turbo/archive/$(version).tar.gz", {alias = "github"})
    add_versions("sf:2.0.5", "16f8f6f2715b3a38ab562a84357c793dd56ae9899ce130563c72cd93d8357b5d")
    add_versions("sf:2.0.6", "d74b92ac33b0e3657123ddcf6728788c90dc84dcb6a52013d758af3c4af481bb")
    add_versions("github:2.0.5", "b3090cd37b5a8b3e4dbd30a1311b3989a894e5d3c668f14cbc6739d77c9402b7")
    add_versions("github:2.0.6", "005aee2fcdca252cee42271f7f90574dda64ca6505d9f8b86ae61abc2b426371")

    add_configs("jpeg", {description = "libjpeg API/ABI emulation target version.", default = "6", type = "string", values = {"6", "7", "8"}})

    add_deps("cmake", "nasm")

    on_install("windows", "linux", "macosx", function (package)
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
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tjSaveImage", {includes = "turbojpeg.h"}))
    end)
