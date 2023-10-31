package("libfacedetection")
    set_homepage("https://github.com/ShiqiYu/libfacedetection")
    set_description("An open source library for face detection in images. The face detection speed can reach 1000FPS. ")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ShiqiYu/libfacedetection/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ShiqiYu/libfacedetection.git")

    add_versions("v3.0", "66dc6b47b11db4bf4ef73e8b133327aa964dbd8b2ce9e0ef4d1e94ca08d40b6a")

    add_configs("neon", {description = "Use neon", default = is_arch("arm.*"), type = "boolean"})
    add_configs("avx512", {description = "Use avx512", default = false, type = "boolean"})
    add_configs("avx2", {description = "Use avx2", default = not is_arch("arm.*"), type = "boolean"})
    add_configs("openmp", {description = "Use openmp", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_arch("arm.*") then
            table.insert(configs, "-DENABLE_NEON=" .. (package:config("neon") and "ON" or "OFF"))
            table.insert(configs, "-DENABLE_AVX512=OFF")
            table.insert(configs, "-DENABLE_AVX2=OFF")
        else
            table.insert(configs, "-DENABLE_NEON=OFF")
            table.insert(configs, "-DENABLE_AVX512=" .. (package:config("avx512") and "ON" or "OFF"))
            table.insert(configs, "-DENABLE_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        end
        table.insert(configs, "-DUSE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("facedetect_cnn", {includes = "facedetection/facedetectcnn.h", configs = {languages = "c++11"}}))
    end)
