package("whisper.cpp")

    set_homepage("https://github.com/ggerganov/whisper.cpp")
    set_description("Port of OpenAI's Whisper model in C/C++")

    set_urls("https://github.com/ggerganov/whisper.cpp/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/ggerganov/whisper.cpp.git")

    add_versions("1.7.6", "166140e9a6d8a36f787a2bd77f8f44dd64874f12dd8359ff7c1f4f9acb86202e")
    add_versions("1.6.2", "da7988072022acc3cfa61b370b3c51baad017f1900c3dc4e68cb276499f66894")
    add_versions("1.6.0", "2729a83662edf909dad66115a3b616c27011cbe4c05335656034954c91ba0c92")
    add_versions("1.5.5", "27fa5c472657af2a6cee63de349a34b23d0f3781fa9b8ef301a940cf64964a79")
    add_versions("1.5.4", "06eed84de310fdf5408527e41e863ac3b80b8603576ba0521177464b1b341a3a")
    add_versions("1.4.2", "1b988dcc77fca55f188dbc4e472f971a80854c1d44309cf3eaab9d5677f175e1")

    add_patches("1.4.2", path.join(os.scriptdir(), "patches", "1.4.2", "fix.patch"), "1330bdbb769aad37f0de6998ac9b0107423ec62385bbfb0a89a98c226daace48")

    add_configs("avx", { description = "Enable AVX", default = true, type = "boolean"})
    add_configs("avx2", { description = "Enable AVX2", default = true, type = "boolean"})
    add_configs("fma", { description = "Enable FMA", default = true, type = "boolean"})
    add_configs("f16c", { description = "Enable F16c", default = true, type = "boolean"})
    if is_plat("macosx") then
        add_configs("accelerate", { description = "Enable Accelerate framework", default = true, type = "boolean"})
        add_configs("coreml", { description = "Enable Core ML framework", default = false, type = "boolean"})
        add_configs("coreml_allow_fallback", { description = "Allow non-CoreML fallback", default = false, type = "boolean"})
    else
        add_configs("openblas", { description = "Support for OpenBLAS", default = false, type = "boolean", readonly = true})
        add_configs("cublas", { description = "Support for cuBLAS", default = false, type = "boolean", readonly = true})
        add_configs("clblast", { description = "use CLBlast", default = false, type = "boolean", readonly = true})
    end
    add_configs("perf", { description = "Enable perf timings", default = false, type = "boolean"})

    add_deps("cmake")

    on_install("windows", "linux", "mingw", "msys", "android", "wasm", function (package)
        local configs = {"-DWHISPER_BUILD_TESTS=OFF", "-DWHISPER_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DWHISPER_NO_AVX=" .. (package:config("avx") and "OFF" or "ON"))
        table.insert(configs, "-DWHISPER_NO_AVX2=" .. (package:config("avx2") and "OFF" or "ON"))
        table.insert(configs, "-DWHISPER_NO_FMA=" .. (package:config("fma") and "OFF" or "ON"))
        table.insert(configs, "-DWHISPER_NO_F16C=" .. (package:config("f16c") and "OFF" or "ON"))
        if package:is_plat("macosx") then
            table.insert(configs, "-DWHISPER_NO_ACCELERATE=" .. (package:config("accelerate") and "OFF" or "ON"))
            table.insert(configs, "-DWHISPER_COREML=" .. (package:config("coreml") and "ON" or "OFF"))
            table.insert(configs, "-DWHISPER_COREML_ALLOW_FALLBACK=" .. (package:config("coreml_allow_fallback") and "ON" or "OFF"))
        else
            table.insert(configs, "-DWHISPER_OPENBLAS=" .. (package:config("openblas") and "ON" or "OFF"))
            table.insert(configs, "-DWHISPER_CUBLAS=" .. (package:config("cublas") and "ON" or "OFF"))
            table.insert(configs, "-DWHISPER_CLBLAST=" .. (package:config("clblast") and "ON" or "OFF"))
        end
        table.insert(configs, "-DWHISPER_PERF=" .. (package:config("perf") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("mingw") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:arch())
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                whisper_context* ctx = whisper_init_from_file("ggml-base.en.bin");
            }
        ]]}, {includes = {"whisper.h"}}))
    end)
