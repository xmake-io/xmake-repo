package("mnn")

    set_homepage("https://www.mnn.zone/")
    set_description("MNN is a highly efficient and lightweight deep learning framework.")
    set_license("Apache-2.0")

    add_urls("https://github.com/alibaba/MNN/archive/$(version).zip",
             "https://github.com/alibaba/MNN.git")

    add_versions("1.2.2", "78698b879f796a84d1aeb02f60ee38f6860dfdd03c27d1649aaaf9e0adfc8630")
    add_versions("1.2.1", "485ae09558ff5626a63d1467ca81ebe0e17fbc60222c386d8f0e857f487c74d0")

    for _, name in ipairs({"metal", "opencl", "opengl", "vulkan", "arm82", "onednn", "avx512", "cuda", "tensorrt", "coreml"}) do
        add_configs(name, {description = "Enable " .. name .. " support.", default = false, type = "boolean"})
    end

    for _, name in ipairs({"train", "quantools", "convert"}) do
        add_configs(name, {description = "Build " .. name .. " tool.", default = false, type = "boolean"})
    end

    add_configs("thread_pool", {description = "Use MNN's own thread pool implementation. Will disabel openmp.", default = true, type = "boolean"})
    add_configs("openmp", {description = "Use OpenMP's thread pool implementation. Does not work on iOS or Mac OS.", default = false, type = "boolean"})
    add_configs("use_system_lib", {description = "When compiling OpenCL/Vulkan, it depends on the OpenCL / Vulkan library of the system.", default = false, type = "boolean"})

    add_deps("cmake")

    add_links("")

    on_load("windows", "linux", "macosx", "android", function (package)
        local mnn_path = package:installdir("include")
        local mnn_lib_dir = string.sub(mnn_path, 1, string.len(mnn_path) - 7) .. "lib"
        if package:config("shared") then
            package:add("ldflags", "-L" .. mnn_lib_dir .. " -lmnn")
            package:add("shflags", "-L" .. mnn_lib_dir .. " -lmnn")
        else
            if package:is_plat("linux", "android", "cross") then
                package:add("shflags", " -Wl,--whole-archive " .. mnn_lib_dir .. "/libMNN.a -Wl,--no-whole-archive")
                package:add("ldflags", " -Wl,--whole-archive " .. mnn_lib_dir .. "/libMNN.a -Wl,--no-whole-archive")
            elseif package:is_plat("macosx") then
                package:add("ldflags", "-Wl,-force_load " .. mnn_lib_dir .. "/libMNN.a")
                package:add("shflags", "-Wl,-force_load " .. mnn_lib_dir .. "/libMNN.a")
            elseif package:is_plat("windows") then
                package:add("linkdirs", mnn_lib_dir)
                package:add("shflags", "/WHOLEARCHIVE:MNN")
                package:add("ldflags", "/WHOLEARCHIVE:MNN")
            end
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "USING_MNN_DLL")
        end

        if package:is_plat("macosx", "iphoneos") then
            if package:config("MNN_OPENCL") then
                package:add("frameworks", "OpenCL")
            end
            if package:config("MNN_OPENGL") then
                package:add("frameworks", "OpenGL")
            end
            if package:config("MNN_METAL") then
                package:add("frameworks", "Metal")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "android", function (package)
        local configs = {"-DMNN_BUILD_TEST=OFF",
                         "-DMNN_BUILD_DEMO=OFF",
                         "-DMNN_SUPPORT_TFLITE_QUAN=ON",
                         "-DMNN_PORTABLE_BUILD=OFF",
                         "-DMNN_SEP_BUILD=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMNN_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMNN_USE_SYSTEM_LIB=" .. (package:config("use_system_lib") and "ON" or "OFF"))
        table.insert(configs, "-DMNN_USE_THREAD_POOL=" .. (package:config("thread_pool") and "ON" or "OFF"))
        table.insert(configs, "-DMNN_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        if package:config("thread_pool") and package:config("openmp") then
            print("Warning: You are using mnn's thread pool, it will disable openmp!")
        end
        for _, name in ipairs({"metal", "opencl", "opengl", "vulkan", "arm82", "onednn", "avx512", "cuda", "tensorrt", "coreml"}) do
            table.insert(configs, "-DMNN_" .. string.upper(name) .. "=" .. (package:config(name) and "ON" or "OFF"))
        end
        for _, name in ipairs({"train", "quantools", "convert"}) do
            table.insert(configs, "-DMNN_BUILD_" .. string.upper(name) .. "=" .. (package:config(name) and "ON" or "OFF"))
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DMNN_WIN_RUNTIME_MT=" .. (package:config("vs_runtime") and "ON" or "OFF"))
            io.replace("CMakeLists.txt",
                'SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi")',
                'SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")', {plain = true})
            io.replace("CMakeLists.txt",
                'SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")',
                'SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")', {plain = true})
        end
        if package:is_plat("android") then
            table.insert(configs, "-DMNN_USE_SSE=OFF")
            table.insert(configs, "-DMNN_BUILD_FOR_ANDROID_COMMAND=ON")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "bd"})
        if package:is_plat("windows") then
            os.cp("bd/Release/*.exe", package:installdir("bin"))
            os.cp("bd/Release/*.dll", package:installdir("bin"))
        elseif package:is_plat("macosx") then
            os.cp("include/MNN", package:installdir("include"))
            os.cp("bd/*.out", package:installdir("bin"))
        else
            os.cp("bd/*.out", package:installdir("bin"))
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <MNN/Interpreter.hpp>
            #include <assert.h>
            static void test() {
                MNN::Interpreter* session = MNN::Interpreter::createFromFile(nullptr);
                assert(session == nullptr);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "MNN/Interpreter.hpp"}))
    end)
