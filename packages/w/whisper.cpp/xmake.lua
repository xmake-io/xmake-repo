package("whisper.cpp")

    set_homepage("https://github.com/ggerganov/whisper.cpp")
    set_description("Port of OpenAI's Whisper model in C/C++")

    set_urls("https://github.com/ggerganov/whisper.cpp/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/ggerganov/whisper.cpp.git")

    add_versions("1.4.0", "b2e34e65777033584fa6769a366cdb0228bc5c7da81e58a5e8dc0ce94d0fb54e")

    if is_plat("macosx") then
        add_configs("accelerate", { description = "Enable Accelerate framework", default = true, type = "boolean"})
        add_configs("avx", { description = "Enable AVX", default = true, type = "boolean"})
        add_configs("avx2", { description = "Enable AVX2", default = true, type = "boolean"})
        add_configs("fma", { description = "Enable FMA", default = true, type = "boolean"})
        add_configs("coreml", { description = "Enable Core ML framework", default = false, type = "boolean"})
        add_configs("coreml_allow_fallback", { description = "Allow non-CoreML fallback", default = false, type = "boolean"})
    else
        add_configs("openblas", { description = "Support for OpenBLAS", default = false, type = "boolean", readonly = true})
        add_configs("cublas", { description = "Support for cuBLAS", default = false, type = "boolean", readonly = true})
    end
    add_configs("perf", { description = "Enable perf timings", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DWHISPER_BUILD_TESTS=OFF", "-DWHISPER_BUILD_EXAMPLES=OFF"}
        if package:is_plat("macosx") then
            table.insert(configs, "-DWHISPER_NO_ACCELERATE=" .. (package:config("accelerate") and "OFF" or "ON"))
            table.insert(configs, "-DWHISPER_NO_AVX=" .. (package:config("avx") and "OFF" or "ON"))
            table.insert(configs, "-DWHISPER_NO_AVX2=" .. (package:config("avx2") and "OFF" or "ON"))
            table.insert(configs, "-DWHISPER_NO_FMA=" .. (package:config("fma") and "OFF" or "ON"))
            table.insert(configs, "-DWHISPER_COREML=" .. (package:config("coreml") and "ON" or "OFF"))
            table.insert(configs, "-DWHISPER_COREML_ALLOW_FALLBACK=" .. (package:config("coreml_allow_fallback") and "ON" or "OFF"))
        else
            table.insert(configs, "-DWHISPER_OPENBLAS=" .. (package:config("openblas") and "ON" or "OFF"))
            table.insert(configs, "-DWHISPER_CUBLAS=" .. (package:config("cublas") and "ON" or "OFF"))
        end
        table.insert(configs, "-DWHISPER_PERF=" .. (package:config("perf") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "lib/static", "lib", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("whisper.h"))
    end)
