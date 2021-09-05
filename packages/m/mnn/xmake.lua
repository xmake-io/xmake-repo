package("mnn")

    set_homepage("https://www.mnn.zone/")
    set_description("MNN is a highly efficient and lightweight deep learning framework.")
    set_license("Apache-2.0")

    add_urls("https://github.com/alibaba/MNN/archive/$(version).zip",
             "https://github.com/alibaba/MNN.git")
    add_versions("1.2.1", "485ae09558ff5626a63d1467ca81ebe0e17fbc60222c386d8f0e857f487c74d0")

    for _, name in ipairs({"meta", "opencl", "opengl", "vulkan", "arm82", "onednn", "avx512", "cuda", "tensorrt", "coreml"}) do
        add_configs(name, {description = "Enable " .. name .. " support.", default = false, type = "boolean"})
    end

    for _, name in ipairs({"train", "quantools", "convert"}) do
        add_configs(name, {description = "Build " .. name .. " tool.", default = false, type = "boolean"})
    end

    add_configs("thread_pool", {description = "Use MNN's own thread pool implementation. Will disabel openmp.", default = true, type = "boolean"})
    add_configs("openmp", {description = "Use OpenMP's thread pool implementation. Does not work on iOS or Mac OS.", default = false, type = "boolean"})

    add_deps("cmake", "ninja")

    on_install("windows", "linux", "macosx", "android", "iphoneos", function (package)
        local configs = {"-DMNN_USE_SYSTEM_LIB=OFF",
                        "-DMNN_BUILD_TEST=OFF",
                        "-DMNN_BUILD_DEMO=OFF",
                        "-DMNN_SUPPORT_TFLITE_QUAN=ON",
                        "-DMNN_PORTABLE_BUILD=OFF",
                        "-DMNN_SEP_BUILD=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMNN_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMNN_USE_THREAD_POOL=" .. (package:config("thread_pool") and "ON" or "OFF"))
        table.insert(configs, "-DMNN_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        if package:config("thread_pool") and package:config("openmp") then 
            print("Warning: use mnn's thread pool, will disable openmp!")
        end
        for _, name in ipairs({"meta", "opencl", "opengl", "vulkan", "arm82", "onednn", "avx512", "cuda", "tensorrt", "coreml"}) do
            table.insert(configs, "-DMNN_" .. string.upper(name) .. "=" .. (package:config(name) and "ON" or "OFF"))
        end
        for _, name in ipairs({"train", "quantools", "convert"}) do
            table.insert(configs, "-DMNN_BUILD_" .. string.upper(name) .. "=" .. (package:config(name) and "ON" or "OFF"))
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DMNN_WIN_RUNTIME_MT=" .. (package:config("vs_runtime") and "ON" or "OFF"))
        end
        if package:is_plat("android") then
            table.insert(configs, "-DMNN_USE_SSE=OFF")
        end
        import("package.tools.cmake").install(package, configs, {buildir="build_xmake"})
        if package:is_plat("windows") then
            package:set("kind", "shared")
            os.cp("bd/Release/*.exe", package:installdir("bin"))
            os.cp("bd/Release/*.dll", package:installdir("bin"))
        else
            os.cp("bd/*.out", package:installdir("bin"))
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        --assert(package:has_cfuncs("mongoc_init", {includes = "mongoc/mongoc.h"}))
    end)
